/*
ARDUINO CODE TO TRIGGER A SEQUENCER
*/
int inByte;
int buttonState;             // the current reading from the input pin
int lastButtonState = LOW;   // the previous reading from the input pin
// the setup function runs once when you press reset or power the board
unsigned long lastDebounceTime = 0;  // the last time the output pin was toggled
unsigned long debounceDelay = 50;    // the debounce time; increase if the output flickers
boolean startLED = false;
int sensorValue = 0;
void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(13, OUTPUT);
  pinMode(12, OUTPUT);
  pinMode(11, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(2, INPUT);
  Serial.begin(9600);
}

// the loop function runs over and over again forever
void loop() {
  sensorValue = analogRead(0); // Read sensor input at analog pin 0 and assign to variable
  sensorValue = map(sensorValue, 0, 1023, 0, 255); // re-map analog sensor value from range 0-1023 to range 0-255
  // read the state of the button switch into a local variable:
  int reading = digitalRead(2);
  if (reading != lastButtonState) {
    // reset the debouncing timer
    lastDebounceTime = millis();
  }

  if ((millis() - lastDebounceTime) > debounceDelay) {
    // whatever the reading is at, it's been there for longer than the debounce
    // delay, so take it as the actual current state:

    // if the button state has changed:
    if (reading != buttonState) {
      buttonState = reading;
      if(buttonState == HIGH) {
        startLED = !startLED;
      }
    }
  }
  
  if(Serial.available() > 0) {
    inByte = Serial.read();
  }

  if(startLED == true) {
    if (inByte == 97) digitalWrite(13, HIGH); // letter 'a' turns LED on
    if (inByte == 98) digitalWrite(12, HIGH); // letter 'b' turns LED on
    if (inByte == 99) digitalWrite(11, HIGH); // letter 'c' turns LED on
    if (inByte == 100) digitalWrite(10, HIGH); // letter 'd' turns LED on
    
    if (inByte == 101) { // letter 'e' turns LED off
      digitalWrite(13, LOW); 
      digitalWrite(12, LOW); 
      digitalWrite(11, LOW); 
      digitalWrite(10, LOW); 
      }
  } else { // turn off LED's if startLED = false
      digitalWrite(13, LOW); 
      digitalWrite(13, LOW); 
      digitalWrite(12, LOW); 
      digitalWrite(11, LOW); 
      digitalWrite(10, LOW); 
  }
  // Write the following message into the serial output
  // startLED sensorValue
  Serial.print(startLED); 
  Serial.write(32); // ASCII value for space
  Serial.println(sensorValue);
  
  // save the reading. Next time through the loop, it'll be the lastButtonState:
  lastButtonState = reading;  
}
