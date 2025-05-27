// === Fan PWM Variables ===
unsigned char myspeed;

// === Thermistor + Photoresistor Variables ===
unsigned int adc_result;
unsigned char myVoltage;
float temp;

// === Ultrasonic Variables ===
unsigned long timer0_overflow = 0;
unsigned int distance = 0;

// === Servo Variables ===
unsigned char angle = 0;
unsigned int counts = 250;
unsigned char open = 0;       // 1 = open, 0 = closed
unsigned char moving = 0;
unsigned char high;       // PWM signal level
volatile unsigned int delay_counter = 0;
unsigned int i;

// === 10µs Delay ===
void delay10us(void){
   char i;
   for (i = 0; i < 10; i++) {
       asm NOP;
       asm NOP;
   }
}

// === Accurate Delay Using TIMER0 ===
void myDelay(unsigned int x){ // x * 256us delay
    delay_counter = 0;
    while(delay_counter < x); // waits until TMR0 ISR increments counter
}

// === Delay For Button Press ===
void debouncing_delay() {
    // 5000 * 0.125 us = 625 us (assuming Fosc = 4 MHz)
    for(i = 0; i < 0xFFFF; i++){
        i = i;
    }
}

// === INTERRUPT ===
void interrupt(void) {
     // if a port B button is pressed, open or close
    if(INTCON & 0x01) {
      // if RB5 is pressed (0)
      if(PORTB & 0x20) {
        INTCON = INTCON & 0x7F; // disable interrupts until done

        debouncing_delay();
        debouncing_delay();

        // initialize timer1 for servo motor PWM
        TMR1H = 0;
        TMR1L = 0;

        high = 1; // PWM signal starts as high
        CCP1CON = 0x08; // Compare mode, toggle on match (initial rising edge)

        // 4 us counts (5000 counts for 20 ms)
        T1CON = 0b00110001; // TMR1: Fosc/4 with 8 prescaler, enabled

        // the panel starts opening / closing after 20 ms
        CCPR1H = 5000 >> 8; // 5000 * 0.5 us * 8 = 20 ms
        CCPR1L = 5000;

        PIE1 = PIE1 | 0x04; // enable CCP1IE
        PIR1 = PIR1 & 0xFB; // clear CCP1IF

        // opening the panel with an initial angle of zero
        if(open){
            open = 0;
        }else{
            open = 1;
        }

        // flag for moving panel
        moving = 1;

        INTCON = INTCON & 0xFE; // clear the interrupt flag
        INTCON = INTCON | 0x80; // re-enable interrupts
      }
    }

    // TMR0 overflow (every 256 us)
    if((INTCON & 0x04) == 0x04){
        TMR0 = 0;
        delay_counter++;
        timer0_overflow++;
        INTCON &= 0xFB; // clear TMR0IF
    }

    // CCP1 compare match
    if((PIR1 & 0x04) == 0x04){
        // PWM high phase
        if (high) {
            TMR1H = 0;
            TMR1L = 0;

            CCPR1H = counts >> 8;
            CCPR1L = counts;

            high = 0;
            CCP1CON = 0x09; // next: falling edge
        }
        // PWM low phase
        else {
            TMR1H = 0;
            TMR1L = 0;

            CCPR1H = (5000 - counts) >> 8;
            CCPR1L = (5000 - counts);

            CCP1CON = 0x08; // next: rising edge
            high = 1;
        }
        PIR1 = PIR1 & 0xFB; // Clear CCP1IF
    }

    // TMR1 overflow
    if((PIR1 & 0x01) == 0x01){
        PIR1 &= 0xFE; // clear TMR1IF
    }
}

// === Ultrasonic Distance Measurement Using Timer1 ===
unsigned int calculate_distance(void){
    unsigned long time;

    PORTC |= 0x10;
    delay10us();
    PORTC &= 0xEF;

    while((PORTD & 0x08) == 0x00);        // Wait for echo start
    timer0_overflow = 0;

    while((PORTD & 0x08) == 0x08);         // Wait for echo end
    time = timer0_overflow * 256; // time in microseconds (estimate)
    return ((time * 34) / (1000)) / 2;
}

// === ADC Initializer ===
void ADC_init(void){
    ADCON0 = 0x49; // ADC ON, Don't GO, Channel 1, Fosc/16
    ADCON1 = 0xC0; // All channels Analog, 500 KHz, right justified
}

// === Fan PWM Initializer ===
void PWM_init(void){
    T2CON = 0x07; // Enable Timer2 at Fosc/4 with 1:16 prescaler (8 uS percount)
    CCP2CON = 0x0C; // Enable PWM for CCP2
    PR2 = 250; // 250 counts = 8uS * 250 = 2ms period
    CCPR2L = 125;
}

// === Ultrasonic Initializer ===
void ultrasonic_init(void){
    TMR0 = 0;
    OPTION_REG = 0x80; // Timer0 gets no prescaler (1:2), INT edge = falling
}

// === ADC Reading From Specific Channel ===
unsigned int ADC_read(unsigned char channel){
    ADCON0 = (ADCON0 & 0b11000111) | ((channel & 0x07) << 3); // Mask out CHS2:CHS0 bits (bits 5-3), then set new channel
    delay10us(); // Allow time for the input voltage to stabilize
    ADCON0 |= 0x04; // Start conversion
    while(ADCON0 & 0x04); // Wait for conversion to finish
    return ((ADRESH << 8) | ADRESL); // Return 10-bit result
}

void main(){
    // Call Intitializers
    ADC_init();
    PWM_init();

    ultrasonic_init();
    INTCON = 0xE8; // GIE, PEIE, INTE (RB0), TMR0IE

    // SETUP INPUTS + OUTPUTS
    TRISA = 0x07;
    // RA0 analog input (Photoresistor)
    // RA1 analog input (Thermistor)
    // RA2 analog input (Potentiometer)
    TRISB = 0x20;
    // RB5 input (Servo Button)
    TRISC = 0x01;
    // RC0 input (Water Level Sensor)
    // RC1 output (DC Fan)
    // RC2 PWM output (Servo)
    // RC3 output (Water Pump)
    // RC4 output (Ultrasonic Trigger)
    // RC6 output (Harvest LED)
    TRISD = 0x08;
    // RD0 output (Light Intesity LED)
    // RD3 input (Ultrasonic Echo)

    // INITIALIZE PORT VALUES
    PORTB = 0x00;
    PORTC = 0x00;
    PORTD = 0x00;

    // INFINITE LOOP
    while(1){
        // PHOTORESISTORCHECK + LED TURN ON/OFF
        adc_result = ADC_read(0); // Read analog input from photoresistor (RA0)
        if(adc_result < 900){ // Check if light intensity is low
            PORTD |= (1 << 0); // Turn on Light Intensity LED (RD0)
        }else{
            PORTD &= ~(1 << 0); // Turn off Light Intensity LED (RD0)
        }

        // THERMISTOR CHECK + FAN TURN ON/OFF
        adc_result = ADC_read(1); // Read analog input from thermistor (RA1)
        temp = 3950.0 /(log((1025.0 * 10 / adc_result - 10) / 10) + 3950.0 / 298.15) - 273.15; // Equation to calculate temperature in celsius
        if(temp > 28){ // If temperature is greater than 27 degrees celsius
            adc_result = ADC_read(2);  // Read analog input from potentiometer (RA2)
            CCPR2L = (((adc_result >> 2) * 250) / 255); // Turn on fan
        }else{
            CCPR2L = 0; // Turn off fan
        }

        // WATER LEVEL CHECK + WATER PUMP TURN ON/OFF
        if(PORTC & (1 << 0)){ // Check if water level is low (RC0)
            PORTC &= ~(1 << 3); // Turn on water pump (RC3)
        }else{
            PORTC |= (1 << 3); // Turn off water pump (RC3)
        }

        // ULTRASONIC CHECK + HARVEST LED TURN ON/OFF
        if(timer0_overflow >= 500){ // every 1.28 seconds
            distance = calculate_distance(); // Get distance reading from ultrasonic
            timer0_overflow = 0;
            if(distance <= 30){ // Check if any plants are detected
                PORTC |= (1 << 6); // Turn on harvest LED
            }else{
                PORTC &= ~(1 << 6); // Turn off harvest LED
            }
        }

        // MOVE SERVO SLOWLY
        if(moving){
            if(open){
                angle += 2;
                if(angle >= 180){
                    moving = 0;
                    angle = 180;
                }
            }else{
                angle -= 2;
                if(angle <= 0){
                    moving = 0;
                    angle = 0;
                    T1CON = 0x00; // turn off timer1 after closing
                    PIE1 &= 0b11111011; // disable CCPIE
                }
            }
            counts = 250 + (angle * 25 / 18); // adjust counts based on angle
        }

        myDelay(100); // 25600us delay between checks
    }
}