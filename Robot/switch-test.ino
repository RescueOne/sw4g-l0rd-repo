////////////////////////////////////////////////
// TINAH Template Program - UBC Engineering Physics 253
// (nakane, 2015 Jan 2)  - Updated for use in Arduino IDE (1.0.6)
/////////////////////////////////////////////////


#include <phys253.h>          
#include <LiquidCrystal.h>    


void setup()
{  
  #include <phys253setup.txt>
  Serial.begin(9600) ;
  
}




void loop()
{
  int pinNumber = 0;
  int variable = LOW;
  LCD.clear();  LCD.home() ;
  LCD.setCursor(0,0); LCD.print("Switch Test");
  LCD.setCursor(0,1);
  

      variable = digitalRead(pinNumber);
      if(variable == HIGH){
        LCD.print("open");
      }
      else {
        LCD.print("close");
      }
delay(50);
  
}

