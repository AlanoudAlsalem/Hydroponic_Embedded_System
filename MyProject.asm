
_delay10us:

;MyProject.c,23 :: 		void delay10us(void){
;MyProject.c,25 :: 		for (i = 0; i < 10; i++) {
	CLRF       R1+0
L_delay10us0:
	MOVLW      10
	SUBWF      R1+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_delay10us1
;MyProject.c,26 :: 		asm NOP;
	NOP
;MyProject.c,27 :: 		asm NOP;
	NOP
;MyProject.c,25 :: 		for (i = 0; i < 10; i++) {
	INCF       R1+0, 1
;MyProject.c,28 :: 		}
	GOTO       L_delay10us0
L_delay10us1:
;MyProject.c,29 :: 		}
L_end_delay10us:
	RETURN
; end of _delay10us

_myDelay:

;MyProject.c,32 :: 		void myDelay(unsigned int x){ // x * 256us delay
;MyProject.c,33 :: 		delay_counter = 0;
	CLRF       _delay_counter+0
	CLRF       _delay_counter+1
;MyProject.c,34 :: 		while(delay_counter < x); // waits until TMR0 ISR increments counter
L_myDelay3:
	MOVF       FARG_myDelay_x+1, 0
	SUBWF      _delay_counter+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__myDelay41
	MOVF       FARG_myDelay_x+0, 0
	SUBWF      _delay_counter+0, 0
L__myDelay41:
	BTFSC      STATUS+0, 0
	GOTO       L_myDelay4
	GOTO       L_myDelay3
L_myDelay4:
;MyProject.c,35 :: 		}
L_end_myDelay:
	RETURN
; end of _myDelay

_debouncing_delay:

;MyProject.c,38 :: 		void debouncing_delay() {
;MyProject.c,40 :: 		for(i = 0; i < 0xFFFF; i++){
	CLRF       _i+0
	CLRF       _i+1
L_debouncing_delay5:
	MOVLW      255
	SUBWF      _i+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__debouncing_delay43
	MOVLW      255
	SUBWF      _i+0, 0
L__debouncing_delay43:
	BTFSC      STATUS+0, 0
	GOTO       L_debouncing_delay6
;MyProject.c,41 :: 		i = i;
;MyProject.c,40 :: 		for(i = 0; i < 0xFFFF; i++){
	INCF       _i+0, 1
	BTFSC      STATUS+0, 2
	INCF       _i+1, 1
;MyProject.c,42 :: 		}
	GOTO       L_debouncing_delay5
L_debouncing_delay6:
;MyProject.c,43 :: 		}
L_end_debouncing_delay:
	RETURN
; end of _debouncing_delay

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;MyProject.c,46 :: 		void interrupt(void) {
;MyProject.c,48 :: 		if(INTCON & 0x01) {
	BTFSS      INTCON+0, 0
	GOTO       L_interrupt8
;MyProject.c,50 :: 		if(PORTB & 0x20) {
	BTFSS      PORTB+0, 5
	GOTO       L_interrupt9
;MyProject.c,51 :: 		INTCON = INTCON & 0x7F; // disable interrupts until done
	MOVLW      127
	ANDWF      INTCON+0, 1
;MyProject.c,53 :: 		debouncing_delay();
	CALL       _debouncing_delay+0
;MyProject.c,54 :: 		debouncing_delay();
	CALL       _debouncing_delay+0
;MyProject.c,57 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;MyProject.c,58 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;MyProject.c,60 :: 		high = 1; // PWM signal starts as high
	MOVLW      1
	MOVWF      _high+0
;MyProject.c,61 :: 		CCP1CON = 0x08; // Compare mode, toggle on match (initial rising edge)
	MOVLW      8
	MOVWF      CCP1CON+0
;MyProject.c,64 :: 		T1CON = 0b00110001; // TMR1: Fosc/4 with 8 prescaler, enabled
	MOVLW      49
	MOVWF      T1CON+0
;MyProject.c,67 :: 		CCPR1H = 5000 >> 8; // 5000 * 0.5 us * 8 = 20 ms
	MOVLW      19
	MOVWF      CCPR1H+0
;MyProject.c,68 :: 		CCPR1L = 5000;
	MOVLW      136
	MOVWF      CCPR1L+0
;MyProject.c,70 :: 		PIE1 = PIE1 | 0x04; // enable CCP1IE
	BSF        PIE1+0, 2
;MyProject.c,71 :: 		PIR1 = PIR1 & 0xFB; // clear CCP1IF
	MOVLW      251
	ANDWF      PIR1+0, 1
;MyProject.c,74 :: 		if(open){
	MOVF       _open+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt10
;MyProject.c,75 :: 		open = 0;
	CLRF       _open+0
;MyProject.c,76 :: 		}else{
	GOTO       L_interrupt11
L_interrupt10:
;MyProject.c,77 :: 		open = 1;
	MOVLW      1
	MOVWF      _open+0
;MyProject.c,78 :: 		}
L_interrupt11:
;MyProject.c,81 :: 		moving = 1;
	MOVLW      1
	MOVWF      _moving+0
;MyProject.c,83 :: 		INTCON = INTCON & 0xFE; // clear the interrupt flag
	MOVLW      254
	ANDWF      INTCON+0, 1
;MyProject.c,84 :: 		INTCON = INTCON | 0x80; // re-enable interrupts
	BSF        INTCON+0, 7
;MyProject.c,85 :: 		}
L_interrupt9:
;MyProject.c,86 :: 		}
L_interrupt8:
;MyProject.c,89 :: 		if((INTCON & 0x04) == 0x04){
	MOVLW      4
	ANDWF      INTCON+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt12
;MyProject.c,90 :: 		TMR0 = 0;
	CLRF       TMR0+0
;MyProject.c,91 :: 		delay_counter++;
	MOVF       _delay_counter+0, 0
	ADDLW      1
	MOVWF      R0+0
	MOVLW      0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      _delay_counter+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      _delay_counter+0
	MOVF       R0+1, 0
	MOVWF      _delay_counter+1
;MyProject.c,92 :: 		timer0_overflow++;
	MOVF       _timer0_overflow+0, 0
	MOVWF      R0+0
	MOVF       _timer0_overflow+1, 0
	MOVWF      R0+1
	MOVF       _timer0_overflow+2, 0
	MOVWF      R0+2
	MOVF       _timer0_overflow+3, 0
	MOVWF      R0+3
	INCF       R0+0, 1
	BTFSC      STATUS+0, 2
	INCF       R0+1, 1
	BTFSC      STATUS+0, 2
	INCF       R0+2, 1
	BTFSC      STATUS+0, 2
	INCF       R0+3, 1
	MOVF       R0+0, 0
	MOVWF      _timer0_overflow+0
	MOVF       R0+1, 0
	MOVWF      _timer0_overflow+1
	MOVF       R0+2, 0
	MOVWF      _timer0_overflow+2
	MOVF       R0+3, 0
	MOVWF      _timer0_overflow+3
;MyProject.c,93 :: 		INTCON &= 0xFB; // clear TMR0IF
	MOVLW      251
	ANDWF      INTCON+0, 1
;MyProject.c,94 :: 		}
L_interrupt12:
;MyProject.c,97 :: 		if((PIR1 & 0x04) == 0x04){
	MOVLW      4
	ANDWF      PIR1+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt13
;MyProject.c,99 :: 		if (high) {
	MOVF       _high+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt14
;MyProject.c,100 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;MyProject.c,101 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;MyProject.c,103 :: 		CCPR1H = counts >> 8;
	MOVF       _counts+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR1H+0
;MyProject.c,104 :: 		CCPR1L = counts;
	MOVF       _counts+0, 0
	MOVWF      CCPR1L+0
;MyProject.c,106 :: 		high = 0;
	CLRF       _high+0
;MyProject.c,107 :: 		CCP1CON = 0x09; // next: falling edge
	MOVLW      9
	MOVWF      CCP1CON+0
;MyProject.c,108 :: 		}
	GOTO       L_interrupt15
L_interrupt14:
;MyProject.c,111 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;MyProject.c,112 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;MyProject.c,114 :: 		CCPR1H = (5000 - counts) >> 8;
	MOVF       _counts+0, 0
	SUBLW      136
	MOVWF      R3+0
	MOVF       _counts+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBLW      19
	MOVWF      R3+1
	MOVF       R3+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR1H+0
;MyProject.c,115 :: 		CCPR1L = (5000 - counts);
	MOVF       R3+0, 0
	MOVWF      CCPR1L+0
;MyProject.c,117 :: 		CCP1CON = 0x08; // next: rising edge
	MOVLW      8
	MOVWF      CCP1CON+0
;MyProject.c,118 :: 		high = 1;
	MOVLW      1
	MOVWF      _high+0
;MyProject.c,119 :: 		}
L_interrupt15:
;MyProject.c,120 :: 		PIR1 = PIR1 & 0xFB; // Clear CCP1IF
	MOVLW      251
	ANDWF      PIR1+0, 1
;MyProject.c,121 :: 		}
L_interrupt13:
;MyProject.c,124 :: 		if((PIR1 & 0x01) == 0x01){
	MOVLW      1
	ANDWF      PIR1+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt16
;MyProject.c,125 :: 		PIR1 &= 0xFE; // clear TMR1IF
	MOVLW      254
	ANDWF      PIR1+0, 1
;MyProject.c,126 :: 		}
L_interrupt16:
;MyProject.c,127 :: 		}
L_end_interrupt:
L__interrupt45:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_calculate_distance:

;MyProject.c,130 :: 		unsigned int calculate_distance(void){
;MyProject.c,133 :: 		PORTC |= 0x10;
	BSF        PORTC+0, 4
;MyProject.c,134 :: 		delay10us();
	CALL       _delay10us+0
;MyProject.c,135 :: 		PORTC &= 0xEF;
	MOVLW      239
	ANDWF      PORTC+0, 1
;MyProject.c,137 :: 		while((PORTD & 0x08) == 0x00);        // Wait for echo start
L_calculate_distance17:
	MOVLW      8
	ANDWF      PORTD+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_calculate_distance18
	GOTO       L_calculate_distance17
L_calculate_distance18:
;MyProject.c,138 :: 		timer0_overflow = 0;
	CLRF       _timer0_overflow+0
	CLRF       _timer0_overflow+1
	CLRF       _timer0_overflow+2
	CLRF       _timer0_overflow+3
;MyProject.c,140 :: 		while((PORTD & 0x08) == 0x08);         // Wait for echo end
L_calculate_distance19:
	MOVLW      8
	ANDWF      PORTD+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      8
	BTFSS      STATUS+0, 2
	GOTO       L_calculate_distance20
	GOTO       L_calculate_distance19
L_calculate_distance20:
;MyProject.c,141 :: 		time = timer0_overflow * 256; // time in microseconds (estimate)
	MOVF       _timer0_overflow+2, 0
	MOVWF      R0+3
	MOVF       _timer0_overflow+1, 0
	MOVWF      R0+2
	MOVF       _timer0_overflow+0, 0
	MOVWF      R0+1
	CLRF       R0+0
;MyProject.c,142 :: 		return ((time * 34) / (1000)) / 2;
	MOVLW      34
	MOVWF      R4+0
	CLRF       R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Mul_32x32_U+0
	MOVLW      232
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Div_32x32_U+0
	MOVF       R0+0, 0
	MOVWF      R4+0
	MOVF       R0+1, 0
	MOVWF      R4+1
	MOVF       R0+2, 0
	MOVWF      R4+2
	MOVF       R0+3, 0
	MOVWF      R4+3
	RRF        R4+3, 1
	RRF        R4+2, 1
	RRF        R4+1, 1
	RRF        R4+0, 1
	BCF        R4+3, 7
	MOVF       R4+0, 0
	MOVWF      R0+0
	MOVF       R4+1, 0
	MOVWF      R0+1
;MyProject.c,143 :: 		}
L_end_calculate_distance:
	RETURN
; end of _calculate_distance

_ADC_init:

;MyProject.c,146 :: 		void ADC_init(void){
;MyProject.c,147 :: 		ADCON0 = 0x49; // ADC ON, Don't GO, Channel 1, Fosc/16
	MOVLW      73
	MOVWF      ADCON0+0
;MyProject.c,148 :: 		ADCON1 = 0xC0; // All channels Analog, 500 KHz, right justified
	MOVLW      192
	MOVWF      ADCON1+0
;MyProject.c,149 :: 		}
L_end_ADC_init:
	RETURN
; end of _ADC_init

_PWM_init:

;MyProject.c,152 :: 		void PWM_init(void){
;MyProject.c,153 :: 		T2CON = 0x07; // Enable Timer2 at Fosc/4 with 1:16 prescaler (8 uS percount)
	MOVLW      7
	MOVWF      T2CON+0
;MyProject.c,154 :: 		CCP2CON = 0x0C; // Enable PWM for CCP2
	MOVLW      12
	MOVWF      CCP2CON+0
;MyProject.c,155 :: 		PR2 = 250; // 250 counts = 8uS * 250 = 2ms period
	MOVLW      250
	MOVWF      PR2+0
;MyProject.c,156 :: 		CCPR2L = 125;
	MOVLW      125
	MOVWF      CCPR2L+0
;MyProject.c,157 :: 		}
L_end_PWM_init:
	RETURN
; end of _PWM_init

_ultrasonic_init:

;MyProject.c,160 :: 		void ultrasonic_init(void){
;MyProject.c,161 :: 		TMR0 = 0;
	CLRF       TMR0+0
;MyProject.c,162 :: 		OPTION_REG = 0x80; // Timer0 gets no prescaler (1:2), INT edge = falling
	MOVLW      128
	MOVWF      OPTION_REG+0
;MyProject.c,163 :: 		}
L_end_ultrasonic_init:
	RETURN
; end of _ultrasonic_init

_ADC_read:

;MyProject.c,166 :: 		unsigned int ADC_read(unsigned char channel){
;MyProject.c,167 :: 		ADCON0 = (ADCON0 & 0b11000111) | ((channel & 0x07) << 3); // Mask out CHS2:CHS0 bits (bits 5-3), then set new channel
	MOVLW      199
	ANDWF      ADCON0+0, 0
	MOVWF      R3+0
	MOVLW      7
	ANDWF      FARG_ADC_read_channel+0, 0
	MOVWF      R2+0
	MOVF       R2+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	IORWF      R3+0, 0
	MOVWF      ADCON0+0
;MyProject.c,168 :: 		delay10us(); // Allow time for the input voltage to stabilize
	CALL       _delay10us+0
;MyProject.c,169 :: 		ADCON0 |= 0x04; // Start conversion
	BSF        ADCON0+0, 2
;MyProject.c,170 :: 		while(ADCON0 & 0x04); // Wait for conversion to finish
L_ADC_read21:
	BTFSS      ADCON0+0, 2
	GOTO       L_ADC_read22
	GOTO       L_ADC_read21
L_ADC_read22:
;MyProject.c,171 :: 		return ((ADRESH << 8) | ADRESL); // Return 10-bit result
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;MyProject.c,172 :: 		}
L_end_ADC_read:
	RETURN
; end of _ADC_read

_main:

;MyProject.c,174 :: 		void main(){
;MyProject.c,176 :: 		ADC_init();
	CALL       _ADC_init+0
;MyProject.c,177 :: 		PWM_init();
	CALL       _PWM_init+0
;MyProject.c,179 :: 		ultrasonic_init();
	CALL       _ultrasonic_init+0
;MyProject.c,180 :: 		INTCON = 0xE8; // GIE, PEIE, INTE (RB0), TMR0IE
	MOVLW      232
	MOVWF      INTCON+0
;MyProject.c,183 :: 		TRISA = 0x07;
	MOVLW      7
	MOVWF      TRISA+0
;MyProject.c,187 :: 		TRISB = 0x20;
	MOVLW      32
	MOVWF      TRISB+0
;MyProject.c,189 :: 		TRISC = 0x01;
	MOVLW      1
	MOVWF      TRISC+0
;MyProject.c,196 :: 		TRISD = 0x08;
	MOVLW      8
	MOVWF      TRISD+0
;MyProject.c,201 :: 		PORTB = 0x00;
	CLRF       PORTB+0
;MyProject.c,202 :: 		PORTC = 0x00;
	CLRF       PORTC+0
;MyProject.c,203 :: 		PORTD = 0x00;
	CLRF       PORTD+0
;MyProject.c,206 :: 		while(1){
L_main23:
;MyProject.c,208 :: 		adc_result = ADC_read(0); // Read analog input from photoresistor (RA0)
	CLRF       FARG_ADC_read_channel+0
	CALL       _ADC_read+0
	MOVF       R0+0, 0
	MOVWF      _adc_result+0
	MOVF       R0+1, 0
	MOVWF      _adc_result+1
;MyProject.c,209 :: 		if(adc_result < 900){ // Check if light intensity is low
	MOVLW      3
	SUBWF      R0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main52
	MOVLW      132
	SUBWF      R0+0, 0
L__main52:
	BTFSC      STATUS+0, 0
	GOTO       L_main25
;MyProject.c,210 :: 		PORTD |= (1 << 0); // Turn on Light Intensity LED (RD0)
	BSF        PORTD+0, 0
;MyProject.c,211 :: 		}else{
	GOTO       L_main26
L_main25:
;MyProject.c,212 :: 		PORTD &= ~(1 << 0); // Turn off Light Intensity LED (RD0)
	BCF        PORTD+0, 0
;MyProject.c,213 :: 		}
L_main26:
;MyProject.c,216 :: 		adc_result = ADC_read(1); // Read analog input from thermistor (RA1)
	MOVLW      1
	MOVWF      FARG_ADC_read_channel+0
	CALL       _ADC_read+0
	MOVF       R0+0, 0
	MOVWF      _adc_result+0
	MOVF       R0+1, 0
	MOVWF      _adc_result+1
;MyProject.c,217 :: 		temp = 3950.0 /(log((1025.0 * 10 / adc_result - 10) / 10) + 3950.0 / 298.15) - 273.15; // Equation to calculate temperature in celsius
	CALL       _word2double+0
	MOVF       R0+0, 0
	MOVWF      R4+0
	MOVF       R0+1, 0
	MOVWF      R4+1
	MOVF       R0+2, 0
	MOVWF      R4+2
	MOVF       R0+3, 0
	MOVWF      R4+3
	MOVLW      0
	MOVWF      R0+0
	MOVLW      40
	MOVWF      R0+1
	MOVLW      32
	MOVWF      R0+2
	MOVLW      140
	MOVWF      R0+3
	CALL       _Div_32x32_FP+0
	MOVLW      0
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVLW      32
	MOVWF      R4+2
	MOVLW      130
	MOVWF      R4+3
	CALL       _Sub_32x32_FP+0
	MOVLW      0
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVLW      32
	MOVWF      R4+2
	MOVLW      130
	MOVWF      R4+3
	CALL       _Div_32x32_FP+0
	MOVF       R0+0, 0
	MOVWF      FARG_log_x+0
	MOVF       R0+1, 0
	MOVWF      FARG_log_x+1
	MOVF       R0+2, 0
	MOVWF      FARG_log_x+2
	MOVF       R0+3, 0
	MOVWF      FARG_log_x+3
	CALL       _log+0
	MOVLW      78
	MOVWF      R4+0
	MOVLW      249
	MOVWF      R4+1
	MOVLW      83
	MOVWF      R4+2
	MOVLW      130
	MOVWF      R4+3
	CALL       _Add_32x32_FP+0
	MOVF       R0+0, 0
	MOVWF      R4+0
	MOVF       R0+1, 0
	MOVWF      R4+1
	MOVF       R0+2, 0
	MOVWF      R4+2
	MOVF       R0+3, 0
	MOVWF      R4+3
	MOVLW      0
	MOVWF      R0+0
	MOVLW      224
	MOVWF      R0+1
	MOVLW      118
	MOVWF      R0+2
	MOVLW      138
	MOVWF      R0+3
	CALL       _Div_32x32_FP+0
	MOVLW      51
	MOVWF      R4+0
	MOVLW      147
	MOVWF      R4+1
	MOVLW      8
	MOVWF      R4+2
	MOVLW      135
	MOVWF      R4+3
	CALL       _Sub_32x32_FP+0
	MOVF       R0+0, 0
	MOVWF      _temp+0
	MOVF       R0+1, 0
	MOVWF      _temp+1
	MOVF       R0+2, 0
	MOVWF      _temp+2
	MOVF       R0+3, 0
	MOVWF      _temp+3
;MyProject.c,218 :: 		if(temp > 28){ // If temperature is greater than 27 degrees celsius
	MOVF       R0+0, 0
	MOVWF      R4+0
	MOVF       R0+1, 0
	MOVWF      R4+1
	MOVF       R0+2, 0
	MOVWF      R4+2
	MOVF       R0+3, 0
	MOVWF      R4+3
	MOVLW      0
	MOVWF      R0+0
	MOVLW      0
	MOVWF      R0+1
	MOVLW      96
	MOVWF      R0+2
	MOVLW      131
	MOVWF      R0+3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main27
;MyProject.c,219 :: 		adc_result = ADC_read(2);  // Read analog input from potentiometer (RA2)
	MOVLW      2
	MOVWF      FARG_ADC_read_channel+0
	CALL       _ADC_read+0
	MOVF       R0+0, 0
	MOVWF      _adc_result+0
	MOVF       R0+1, 0
	MOVWF      _adc_result+1
;MyProject.c,220 :: 		CCPR2L = (((adc_result >> 2) * 250) / 255); // Turn on fan
	MOVF       R0+0, 0
	MOVWF      R4+0
	MOVF       R0+1, 0
	MOVWF      R4+1
	RRF        R4+1, 1
	RRF        R4+0, 1
	BCF        R4+1, 7
	RRF        R4+1, 1
	RRF        R4+0, 1
	BCF        R4+1, 7
	MOVLW      250
	MOVWF      R0+0
	CLRF       R0+1
	CALL       _Mul_16X16_U+0
	MOVLW      255
	MOVWF      R4+0
	CLRF       R4+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      CCPR2L+0
;MyProject.c,221 :: 		}else{
	GOTO       L_main28
L_main27:
;MyProject.c,222 :: 		CCPR2L = 0; // Turn off fan
	CLRF       CCPR2L+0
;MyProject.c,223 :: 		}
L_main28:
;MyProject.c,226 :: 		if(PORTC & (1 << 0)){ // Check if water level is low (RC0)
	BTFSS      PORTC+0, 0
	GOTO       L_main29
;MyProject.c,227 :: 		PORTC &= ~(1 << 3); // Turn on water pump (RC3)
	BCF        PORTC+0, 3
;MyProject.c,228 :: 		}else{
	GOTO       L_main30
L_main29:
;MyProject.c,229 :: 		PORTC |= (1 << 3); // Turn off water pump (RC3)
	BSF        PORTC+0, 3
;MyProject.c,230 :: 		}
L_main30:
;MyProject.c,233 :: 		if(timer0_overflow >= 500){ // every 1.28 seconds
	MOVLW      0
	SUBWF      _timer0_overflow+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main53
	MOVLW      0
	SUBWF      _timer0_overflow+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main53
	MOVLW      1
	SUBWF      _timer0_overflow+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main53
	MOVLW      244
	SUBWF      _timer0_overflow+0, 0
L__main53:
	BTFSS      STATUS+0, 0
	GOTO       L_main31
;MyProject.c,234 :: 		distance = calculate_distance(); // Get distance reading from ultrasonic
	CALL       _calculate_distance+0
	MOVF       R0+0, 0
	MOVWF      _distance+0
	MOVF       R0+1, 0
	MOVWF      _distance+1
;MyProject.c,235 :: 		timer0_overflow = 0;
	CLRF       _timer0_overflow+0
	CLRF       _timer0_overflow+1
	CLRF       _timer0_overflow+2
	CLRF       _timer0_overflow+3
;MyProject.c,236 :: 		if(distance <= 30){ // Check if any plants are detected
	MOVF       R0+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main54
	MOVF       R0+0, 0
	SUBLW      30
L__main54:
	BTFSS      STATUS+0, 0
	GOTO       L_main32
;MyProject.c,237 :: 		PORTC |= (1 << 6); // Turn on harvest LED
	BSF        PORTC+0, 6
;MyProject.c,238 :: 		}else{
	GOTO       L_main33
L_main32:
;MyProject.c,239 :: 		PORTC &= ~(1 << 6); // Turn off harvest LED
	BCF        PORTC+0, 6
;MyProject.c,240 :: 		}
L_main33:
;MyProject.c,241 :: 		}
L_main31:
;MyProject.c,244 :: 		if(moving){
	MOVF       _moving+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main34
;MyProject.c,245 :: 		if(open){
	MOVF       _open+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main35
;MyProject.c,246 :: 		angle += 2;
	MOVLW      2
	ADDWF      _angle+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	MOVWF      _angle+0
;MyProject.c,247 :: 		if(angle >= 180){
	MOVLW      180
	SUBWF      R1+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_main36
;MyProject.c,248 :: 		moving = 0;
	CLRF       _moving+0
;MyProject.c,249 :: 		angle = 180;
	MOVLW      180
	MOVWF      _angle+0
;MyProject.c,250 :: 		}
L_main36:
;MyProject.c,251 :: 		}else{
	GOTO       L_main37
L_main35:
;MyProject.c,252 :: 		angle -= 2;
	MOVLW      2
	SUBWF      _angle+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	MOVWF      _angle+0
;MyProject.c,253 :: 		if(angle <= 0){
	MOVF       R1+0, 0
	SUBLW      0
	BTFSS      STATUS+0, 0
	GOTO       L_main38
;MyProject.c,254 :: 		moving = 0;
	CLRF       _moving+0
;MyProject.c,255 :: 		angle = 0;
	CLRF       _angle+0
;MyProject.c,256 :: 		T1CON = 0x00; // turn off timer1 after closing
	CLRF       T1CON+0
;MyProject.c,257 :: 		PIE1 &= 0b11111011; // disable CCPIE
	MOVLW      251
	ANDWF      PIE1+0, 1
;MyProject.c,258 :: 		}
L_main38:
;MyProject.c,259 :: 		}
L_main37:
;MyProject.c,260 :: 		counts = 250 + (angle * 25 / 18); // adjust counts based on angle
	MOVF       _angle+0, 0
	MOVWF      R0+0
	MOVLW      25
	MOVWF      R4+0
	CALL       _Mul_8X8_U+0
	MOVLW      18
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16x16_S+0
	MOVF       R0+0, 0
	ADDLW      250
	MOVWF      _counts+0
	MOVLW      0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      R0+1, 0
	MOVWF      _counts+1
;MyProject.c,261 :: 		}
L_main34:
;MyProject.c,263 :: 		myDelay(100); // 25600us delay between checks
	MOVLW      100
	MOVWF      FARG_myDelay_x+0
	MOVLW      0
	MOVWF      FARG_myDelay_x+1
	CALL       _myDelay+0
;MyProject.c,264 :: 		}
	GOTO       L_main23
;MyProject.c,265 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
