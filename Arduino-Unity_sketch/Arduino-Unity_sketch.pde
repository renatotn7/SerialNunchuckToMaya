/* Arduino communication with Flash - version 16-03-2009 
 * Use Arduino as an interfaceboard for Flash applications. 
 *
 * This code should be used with the following flash files :
 * Flash_arduino.fla 
 * ArduinoFO.as
 * ArduinoXML.as
 *
 * More information in the readme.txt
 *
 * Art & Technology - Saxion University of Applied Sciences
 * copyleft Kasper Kamperman / Rene Heijnen, Enschede - The Netherlands - september 2008
 * http://www.kasperkamperman.com 
 *
 * code based on : 
 * -------------------------------------------------------------------------------  
 * General Purpose computer serial IO
 * copyleft Stephen Wilson  <http://userwww.sfsu.edu/~swilson/>
 * Created October, 2006
 * 
 * SERIAL COM - HANDELING MULTIPLE BYTES inside ARDUINO - 04_function development
 * by beltran berrocal  created 16 Decembre 2005;
 * copyleft 2005 Progetto25zero1  <http://www.progetto25zero1.com>
 * ------------------------------------------------------------------------------- 
 *
 * Make sure that the pinConfig Array in this file is exactly the same as in the flash fla file.
 */

// variabels
char serInString[40];  // the received string with output information max 40 characters
char tempString[4];    // temp string for reading the pwm & output values
int tempVal;           // temp int for reading pwm values
int val;               // temp int for reading analog en digital inputs
int stringLength = 1;  // expected length of string received from Flash
int serInStringLength; // length of string received by Flash. 
int digOut = 0;        // Number of digital outputs
int digIn = 0;         // Number of digital inputs
int digInputs[12];     // array that stores which pins are used as digital inputs max 12.
int digOutputs[12];    // array that stores which pins are used as digital outputs max 12.
int digOutLastValues[12]; // array that stores the last values, an output only updates when there is a change

char pinConfig[] =  {   
  // array with the pin configuration of Arduino. Don't forget to change in Flash.
  // pin 0 and 1 are not used because they are used by the Serialport (RX/TX)

  // COPY-PASTE PIN CONFIGURATION BELOW ALSO TO FLASH --

  'i',  // Pin 2  'i' for in 'o' for out
  'i',  // Pin 3  'i' for in 'o' for out or 'p' for pwm
  'i',  // Pin 4  'i' for in 'o' for out
  'i',  // Pin 5  'i' for in 'o' for out or 'p' for pwm
  'i',  // Pin 6  'i' for in 'o' for out or 'p' for pwm
  'i',  // Pin 7  'i' for in 'o' for out
  'o',  // Pin 8  'i' for in 'o' for out
  'o',  // Pin 9  'i' for in 'o' for out or 'p' for pwm
  'o',  // Pin 10 'i' for in 'o' for out or 'p' for pwm
  'o',  // Pin 11 'i' for in 'o' for out or 'p' for pwm
  'o',  // Pin 12 'i' for in 'o' for out
  'o'   // Pin 13 LedPin 'i' for in 'o' for out 

  // ----------------------------------------------------
};

void setup() { 
  //Serial.begin(9600); 	// start serial port
  Serial.begin(19200); 	// start serial port

  // set pinconfiguration according to the pinConfig array 
  for (int i =0; i < 12; i++) { 
    //Serial.print(pinConfig[i]); 
    if (pinConfig[i] == 'i') { // input
      pinMode(i+2, INPUT);
      digInputs[digIn] = i+2;
      digIn++;
    }  
    if (pinConfig[i] == 'o') { // output
      pinMode(i+2, OUTPUT);
      digOutputs[digOut] = i+2;
      stringLength +=2; // output string part will have 2 characters
      digOut++;
    }
    if (pinConfig[i] == 'p') { // pwm output
      pinMode(i+2, OUTPUT);
      digOutputs[digOut] = i+2;
      stringLength +=4; // pwm string part will have 4 characters
      digOut++;
    }
  }
}

// Function to read a string from the serialport and store it in an array
void readSerialString (char *strArray) 
{ 
  int i = 0;				
  if(Serial.available()){                
    while (Serial.available()) {        
      strArray[i] = Serial.read();	                                        
      i++;			        
    }
  }
  serInStringLength=i;	
} 

// Function to find out wether the array is empty or not
boolean isStringEmpty(char *strArray) 
{ 
  if (strArray[0] == 0) return true;
  else 			return false;
}


void sendInputsToFlash(boolean error)
{ 
  if(error) {  
    Serial.print("e,");
    Serial.print(stringLength);
    Serial.print(",");
    Serial.print(serInStringLength);
    Serial.print(",");
  }
  else  Serial.print("i,");

  // read the defined digital inputs
  for (int i=0; i < digIn; i++) {    
    val = digitalRead(digInputs[i]); 
    if (val == HIGH) { 
      Serial.print(val,BIN);
    }
    if (val == LOW) { 
      Serial.print(val,BIN);
    }
    Serial.print(","); 
  }

  // read the 6 analog inputs    
  for (int i=0; i < 6; i++) {       
    val = analogRead(i);
    ///*
    if(i != 5){
      Serial.print(val,DEC);
      Serial.print(",");
    }else{
      Serial.println(val,DEC);
    }
    //*/
    //Serial.print(val,DEC);
    //Serial.print(",");
  } 

  //Serial.println(0, BYTE); // close with a zero byte for XML Flash
  
  // Commented because Unity does NOT like these zero bytes
}

void updateArduinoOutputs()
{ // position of the current character in the serInstring 
  //int serInStringPosition = 1;
  int serInStringPosition = 2;

  // set the defined outputs

  for (int i=0; i < digOut; i++) { 

    // check if next character is ',' then it is a digital output 
    // because a pwm value has three characters

    if (serInString[serInStringPosition + 1]==',' ) { 
      tempString[0] = serInString[serInStringPosition];
      tempString[1] = 0;
      tempString[2] = 0;
      tempVal = atoi(tempString);

      // check if this output has changed
      // this prevents outputs to "flicker"
      if(digOutLastValues[i]!=tempVal) 
      { 
        if(tempVal==1) digitalWrite(digOutputs[i], HIGH);
        if(tempVal==0) digitalWrite(digOutputs[i], LOW);
        digOutLastValues[i]=tempVal;
      }
      serInStringPosition += 2; 
    }

    // next pin is not ',' so its a pwm value
    else { 
      tempString[0] = serInString[serInStringPosition];
      tempString[1] = serInString[serInStringPosition+1];
      tempString[2] = serInString[serInStringPosition+2];
      tempVal = atoi(tempString); 

      if(digOutLastValues[i]!=tempVal)
      { 
        analogWrite(digOutputs[i],tempVal);
        digOutLastValues[i]=tempVal;
      }
      serInStringPosition +=4; 
    }
  }

}

void eraseStrings()
{ // erase contents in the serInString array
  for (int i=0; i < 40; i++) {  
    serInString[i]=0;    
  }
  // erase contents in the tempString array
  for (int i=0; i < 4; i++) {
    tempString[i]=0;
  }
}

void loop () { 
  // Serial.println("Arduino is alive !!!");
  // read the serial port and create a string out of what you read
  readSerialString(serInString); 

  // check if there data is received if isStringEmpty is true do nothing. 
  if(isStringEmpty(serInString) == false) { 

    /* check if the received string starts with an o            
     check if string length is the same as expected length (defined outputs)
     if true : return I (input), send input info to flash and update the Arduino outputs
     if false: return E (error) and the part of the string that is received (to debug)
     
     check if the received string start with an n
     send only input information ( no new info from Flash )       
     */

    if(serInString[0]==111) //o
    {
      if(serInStringLength>=stringLength)
      { //the received information is complete
        updateArduinoOutputs();
        sendInputsToFlash(false);
      }
      // receive info incomplete error is true
      else sendInputsToFlash(true);
    }
    else if(serInString[0]==110) //n
    {
      sendInputsToFlash(false);
    }
    // no o or n as start character, start with error info
    else sendInputsToFlash(true);

    eraseStrings();     
  }
  // short delay before making sure serial.read is not called to soon again
  delay(20);    
} 
