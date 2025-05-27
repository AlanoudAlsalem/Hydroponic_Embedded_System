#line 1 "C:/Users/20210200/EMBEDDED ABOUD/MyProject.c"

unsigned char myspeed;


unsigned int adc_result;
unsigned char myVoltage;
float temp;


unsigned long timer0_overflow = 0;
unsigned int distance = 0;


unsigned char angle = 0;
unsigned int counts = 250;
unsigned char open = 0;
unsigned char moving = 0;
unsigned char high;
volatile unsigned int delay_counter = 0;
unsigned int i;


void delay10us(void){
 char i;
 for (i = 0; i < 10; i++) {
 asm NOP;
 asm NOP;
 }
}


void myDelay(unsigned int x){
 delay_counter = 0;
 while(delay_counter < x);
}


void debouncing_delay() {

 for(i = 0; i < 0xFFFF; i++){
 i = i;
 }
}


void interrupt(void) {

 if(INTCON & 0x01) {

 if(PORTB & 0x20) {
 INTCON = INTCON & 0x7F;

 debouncing_delay();
 debouncing_delay();


 TMR1H = 0;
 TMR1L = 0;

 high = 1;
 CCP1CON = 0x08;


 T1CON = 0b00110001;


 CCPR1H = 5000 >> 8;
 CCPR1L = 5000;

 PIE1 = PIE1 | 0x04;
 PIR1 = PIR1 & 0xFB;


 if(open){
 open = 0;
 }else{
 open = 1;
 }


 moving = 1;

 INTCON = INTCON & 0xFE;
 INTCON = INTCON | 0x80;
 }
 }


 if((INTCON & 0x04) == 0x04){
 TMR0 = 0;
 delay_counter++;
 timer0_overflow++;
 INTCON &= 0xFB;
 }


 if((PIR1 & 0x04) == 0x04){

 if (high) {
 TMR1H = 0;
 TMR1L = 0;

 CCPR1H = counts >> 8;
 CCPR1L = counts;

 high = 0;
 CCP1CON = 0x09;
 }

 else {
 TMR1H = 0;
 TMR1L = 0;

 CCPR1H = (5000 - counts) >> 8;
 CCPR1L = (5000 - counts);

 CCP1CON = 0x08;
 high = 1;
 }
 PIR1 = PIR1 & 0xFB;
 }


 if((PIR1 & 0x01) == 0x01){
 PIR1 &= 0xFE;
 }
}


unsigned int calculate_distance(void){
 unsigned long time;

 PORTC |= 0x10;
 delay10us();
 PORTC &= 0xEF;

 while((PORTD & 0x08) == 0x00);
 timer0_overflow = 0;

 while((PORTD & 0x08) == 0x08);
 time = timer0_overflow * 256;
 return ((time * 34) / (1000)) / 2;
}


void ADC_init(void){
 ADCON0 = 0x49;
 ADCON1 = 0xC0;
}


void PWM_init(void){
 T2CON = 0x07;
 CCP2CON = 0x0C;
 PR2 = 250;
 CCPR2L = 125;
}


void ultrasonic_init(void){
 TMR0 = 0;
 OPTION_REG = 0x80;
}


unsigned int ADC_read(unsigned char channel){
 ADCON0 = (ADCON0 & 0b11000111) | ((channel & 0x07) << 3);
 delay10us();
 ADCON0 |= 0x04;
 while(ADCON0 & 0x04);
 return ((ADRESH << 8) | ADRESL);
}

void main(){

 ADC_init();
 PWM_init();

 ultrasonic_init();
 INTCON = 0xE8;


 TRISA = 0x07;



 TRISB = 0x20;

 TRISC = 0x01;






 TRISD = 0x08;




 PORTB = 0x00;
 PORTC = 0x00;
 PORTD = 0x00;


 while(1){

 adc_result = ADC_read(0);
 if(adc_result < 900){
 PORTD |= (1 << 0);
 }else{
 PORTD &= ~(1 << 0);
 }


 adc_result = ADC_read(1);
 temp = 3950.0 /(log((1025.0 * 10 / adc_result - 10) / 10) + 3950.0 / 298.15) - 273.15;
 if(temp > 28){
 adc_result = ADC_read(2);
 CCPR2L = (((adc_result >> 2) * 250) / 255);
 }else{
 CCPR2L = 0;
 }


 if(PORTC & (1 << 0)){
 PORTC &= ~(1 << 3);
 }else{
 PORTC |= (1 << 3);
 }


 if(timer0_overflow >= 500){
 distance = calculate_distance();
 timer0_overflow = 0;
 if(distance <= 30){
 PORTC |= (1 << 6);
 }else{
 PORTC &= ~(1 << 6);
 }
 }


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
 T1CON = 0x00;
 PIE1 &= 0b11111011;
 }
 }
 counts = 250 + (angle * 25 / 18);
 }

 myDelay(100);
 }
}
