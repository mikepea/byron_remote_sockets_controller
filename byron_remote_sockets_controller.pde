
/*
 * Byron remote socket controller
 *
 * Teensy v2 version
 */

// zone switch:         A  B  C  D
uint8_t zone_pin[4] = { 7, 8, 9, 10 };

// on/off switches:     1  2  3
uint8_t plug_pin[3] = { 2, 3, 4 };

// on/off pins:         OFF ON
uint8_t onoff_pin[2] = { 6, 5 };

// useful for setup and ensuring we reset to LOW
uint8_t all_pins[9] = { 2, 3, 4, 5, 6, 7, 8, 9, 10 };

uint8_t buffer_count = 0;

#define TOTAL_PINS    9
#define NUM_ZONES    4
#define NUM_PLUGS_PER_ZONE    3
#define CODE_BUFFER_SIZE 10

#define NO_CODE 0
#define START_CODE 1
#define GOT_ONOFF 2
#define GOT_ZONE 3
#define GOT_PLUG 4


typedef struct code_record {
    //char badge_id ;
    uint8_t onoff ;
    uint8_t zone ;
    uint8_t plug ;

} code_record_t;

code_record_t global_code_buffer[CODE_BUFFER_SIZE];

void all_pins_output()
{
    for (uint8_t i=0; i<TOTAL_PINS; i++) { pinMode(all_pins[i], OUTPUT); }
}

void all_pins_low()
{
    for (uint8_t i=0; i<TOTAL_PINS; i++) { digitalWrite(all_pins[i], LOW); }
}

void setup()
{

    // We'll be using serial to talk to the device
    Serial.begin(9600);

    all_pins_output();
    all_pins_low();

}



// This version is more robust
void get_codes_from_serial() {

    // codes are of the form:
    //    @1A1 - turn on (1) zone A plug 1
    //    @0A3 - turn off (0) zone A plug 3
    int count = 0;
    uint8_t state = NO_CODE;
    boolean receiving_code = 0;

    code_record_t recd_code;

    while (count < 10) {
        count++;
        if (Serial.available()) {
            char c = Serial.read();

            switch(state) {
                case START_CODE:
                    if ( c == '0' ) {
                        recd_code.onoff = 1;
                        state = GOT_ONOFF;
                        Serial.println("Got OFF");
                    } else if ( c == '1' ) {
                        recd_code.onoff = 2;
                        state = GOT_ONOFF;
                        Serial.println("Got ON");
                    } else {
                        // junk, restart
                        Serial.println("Bah FAIL");
                        state = NO_CODE;
                    }
                    break;
                case GOT_ONOFF:
                    if ( c >= 'A' && c <= 'D' ) {
                        recd_code.zone = c - 'A';
                        Serial.print("Got ZONE: ");
                        Serial.println(c);
                        state = GOT_ZONE;
                    } else {
                        Serial.println("Bah FAIL");
                        state = NO_CODE;
                    }
                    break;
                case GOT_ZONE:
                    if ( c >= '1' && c <= '3' ) {
                        recd_code.plug = c - '1';
                        // record valid code in our buffer
                        Serial.print("Got PLUG: ");
                        Serial.println(c);
                        global_code_buffer[buffer_count] = recd_code;
                        Serial.println("Recorded code into buffer");
                        increment_buffer_counter();
                    } else {
                        Serial.println("Bah FAIL");
                        state = NO_CODE;
                    }

                    break;
                default:
                    if (c == '@') {
                        // cool, start recording the code.
                        count = 0;
                        recd_code.onoff = 0;
                        recd_code.zone = 0;
                        recd_code.plug = 0;
                        state = START_CODE;
                        Serial.println("Starting code");
                    }
                    break;
            }
        }
    }
}

void increment_buffer_counter() {
    buffer_count = ( buffer_count + 1 ) % CODE_BUFFER_SIZE;
}

//void send_code(struct code_record_t code) {
void send_code(uint8_t onoff, uint8_t zone, uint8_t plug) {

    Serial.print("Sending code: ");
    Serial.print(onoff + '0', BYTE);
    Serial.print(zone + 'A', BYTE);
    Serial.print(plug + '1', BYTE);
    Serial.println();

    all_pins_low();

    digitalWrite(zone_pin[zone], HIGH);
    digitalWrite(onoff_pin[onoff], HIGH);

    digitalWrite(plug_pin[plug], HIGH);
    delay(200);

    all_pins_low();
    delay(100);

}

void loop()
{

    get_codes_from_serial();

    for (uint8_t i=0; i<CODE_BUFFER_SIZE; i++) {
        if ( global_code_buffer[i].onoff > 0 ) {
            // woo! spew it out
            send_code(
                global_code_buffer[i].onoff - 1,
                global_code_buffer[i].zone,
                global_code_buffer[i].plug);
            global_code_buffer[i].onoff = 0; // blank that buffer slot.
        }
    }

    delay(100);

}

// vi:tabstop=4:expandtab:ai:syntax=c
