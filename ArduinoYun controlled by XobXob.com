////////////////////////////////////////////////////////////////////////////
//
//  XOBXOB Blink :: Arduino Yún
// 
//  This sketch connects to the XOBXOB IoT platform using an Arduino Yún. 
// 
//  The MIT License (MIT)
//  
//  Copyright (c) 2013-2014 Robert W. Gallup, XOBXOB
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.// 
#include <Servo.h>
#include <Process.h>
#include <XOBXOB.h>

///////////////////////////////////////////////////////////
//
// Change this for your APIKey
//
// NOTE: Your APIKey will be found on your account dashboard when you
// login to XOBXOB)
//

String APIKey = "xxxxxxxxxxxxxxx";

///////////////////////////////////////////////////////////


// Create XOBXOB object (for the Ethernet shield)
XOBXOB xClient (APIKey);

// Variables for request timing
boolean lastResponseReceived = true;
long lastRequestTime = -20000;
Servo myservo;
void setup() {
  
  Bridge.begin();
  
  // Set the LED pin for output and turn it off
   pinMode(1, OUTPUT);
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
  pinMode(8, OUTPUT);
  myservo.attach(11);
  pinMode(10, OUTPUT);
  pinMode(9, OUTPUT);
  pinMode(12, OUTPUT);
  pinMode(13, OUTPUT);
  digitalWrite(1, LOW);
  digitalWrite (2, LOW);
  digitalWrite(3, LOW);
  digitalWrite (4, LOW);  
  digitalWrite (5, LOW);
  digitalWrite (6, LOW);
  digitalWrite (7, LOW);
  digitalWrite (8, LOW);
  digitalWrite (9, LOW);
  digitalWrite (10, LOW);
  digitalWrite (13, LOW);
  myservo.write(90);
  
}

void loop()
{
    
  // New XOB request every 4 seconds (if previous response has been received)
  if (lastResponseReceived && (abs(millis() - lastRequestTime) > 2*1000)) {
 
    // Reset timer and response flags. Then, request "XOB" contents
    lastResponseReceived = false;
    lastRequestTime = millis();
    
    xClient.requestXOB("XOB");

  }

  // Check the response each time through. If a full response received, 
  // get the "switch" message from the XOB and turn the LED on/off
  if (!lastResponseReceived && xClient.checkResponse()) {

    lastResponseReceived = true;

    String LED = xClient.getMessage("switch");
    if (LED == "\"W\"") {
      digitalWrite (4, HIGH);
      digitalWrite (6, HIGH);
      digitalWrite (7, HIGH);
      digitalWrite (9, HIGH);
      digitalWrite (3, LOW);
      digitalWrite (5, LOW);
      digitalWrite (8, LOW);
      digitalWrite (10, LOW);
      
    } else if (LED == "\"S\"") {
     digitalWrite (3, HIGH);
      digitalWrite (5, HIGH);
      digitalWrite (8, HIGH);
      digitalWrite (10, HIGH);
      digitalWrite (4, LOW);
      digitalWrite (6, LOW);
      digitalWrite (7, LOW);
      digitalWrite (9, LOW);
    }
    else if (LED == "\"A\""){
      digitalWrite (3, HIGH);
      digitalWrite (5, HIGH);
      digitalWrite (7, HIGH);
      digitalWrite (9, HIGH);
      digitalWrite (4, LOW);
      digitalWrite (6, LOW);
      digitalWrite (8, LOW);
      digitalWrite (10, LOW);
    }
    else if (LED == "\"D\"")
     { digitalWrite (4, HIGH);
      digitalWrite (6, HIGH);
      digitalWrite (8, HIGH);
      digitalWrite (10, HIGH);
      digitalWrite (3, LOW);
      digitalWrite (5, LOW);
      digitalWrite (7, LOW);
      digitalWrite (9, LOW);
        }
        else if (LED == "\"F0\"")
     { myservo.write(0);
        }
         else if (LED == "\"F180\"")
     { myservo.write(180);
        }
         else if (LED == "\"F45\"")
     { myservo.write(45);
        }
         else if (LED == "\"F90\"")
     { myservo.write(90);
        }
         else if (LED == "\"F135\"")
     { myservo.write(135);
        }
        else { 
          digitalWrite (4, LOW);
      digitalWrite (6, LOW);
      digitalWrite (8, LOW);
      digitalWrite (10, LOW);
      digitalWrite (3, LOW);
      digitalWrite (5, LOW);
      digitalWrite (7, LOW);
      digitalWrite (9, LOW);
      myservo.write(90);
        }
  }

}
