
/*
 * Byron remote socket controller
 * 
 * Teensy v2 version
 */

// zone switch:     A  B  C  D
int zone_pin[4] = { 7, 8, 9, 10 }

// on/off switches: 1  2  3
int plug_pin[3] = { 2, 3, 4 }

// on/off pins:     ON  OFF
int onoff_pin[2] = { 5,  6 }

// useful for setup and ensuring we reset to LOW
int all_pins[9] = { 2, 3, 4, 5, 6, 7, 8, 9, 10 }
#define TOTAL_PINS = 9

int on_pin = 5;
int off_pin = 6;

void setup()
{

  // We'll be using serial to talk to the device
  Serial.begin(9600);

  all_pins_output();
  all_pins_low();

}

void all_pins_output() 
{
  for (i=0; i<TOTAL_PINS; i++) { pinMode(all_pins[i], OUTPUT); }
}

void all_pins_low() 
{
  for (i=0; i<TOTAL_PINS; i++) { digitalWrite(all_pins[i], LOW); }
}

void loop()
{

  /*
  digitalWrite(zone_d_pin, HIGH);
  digitalWrite(on_pin, HIGH);
    
  digitalWrite(one_pin, HIGH);
  delay(500);
  digitalWrite(one_pin, LOW);
  delay(500);
  
  digitalWrite(on_pin, LOW);
  digitalWrite(off_pin, HIGH);
  delay(1000);
  digitalWrite(one_pin, HIGH);
  delay(500);
  digitalWrite(one_pin, LOW);
  delay(500);
  digitalWrite(off_pin, LOW);
  //digitalWrite(one_pin, HIGH);
  //delay(500);
  //digitalWrite(one_pin, LOW);
  delay(1000);
  */

}

