// This #include statement was automatically added by the Particle IDE.
#include "IRremote.h"

int commadDevice(String args);
int windSensor(String args);
int windValue;
 
IRsend irsend(D3); // hardwired to pin 3; use a transistor to drive the IR LED for maximal range
int ledstate;
// Use the raw code you recorded from your device, in this example the length of the code is 37
unsigned int rawCodes[] = {8850,4450,550,1650,550,550,600,550,550,550,550,550,550,550,550,550,550,1700,550,550,550,1650,550,1700,550,550,550,550,550,1650,600,1650,550,550,550,1700,550,550,550,550,550,550,550,550,550,550,600,550,500,1700,550,550,550,1700,550,1650,550,1700,550,1650,550,1700,550,1650,550,550,600};
unsigned int decodedCode = 0xC1E3EAAB;

STARTUP(WiFi.selectAntenna(ANT_EXTERNAL));

void setup()
{
    ledstate = 1;
  Spark.function("toggle", commadDevice);
  Spark.function("wind",windSensor);
  Spark.variable("windValue", &windValue, INT);
  pinMode(D7,OUTPUT);
  pinMode(A0, INPUT);
  //digitalWrite(D7, HIGH);
}

void loop()
{
    windValue = analogRead(A0);
}
 
int commadDevice(String args)
{
    int rawSize = sizeof(rawCodes)/sizeof(int); // In this example, rawSize would evaluate to 37
    irsend.sendRaw(rawCodes, rawSize, 38);
//    irsend.sendSony(decodedCode,38);
    // delay(500);
    // irsend.sendRC5(decodedCode, 38);
    // delay(500);
    // irsend.sendRC6(decodedCode, 38);
    // delay(500);
    // irsend.sendDISH(decodedCode, 38);
    // if (ledstate == 0)
    // {
    //     digitalWrite(D7, LOW);
    //     ledstate = 1;
    // }
    // else {
    //     digitalWrite(D7, LOW);
    //     ledstate = 0;
    // }
    digitalWrite(D7,HIGH);
    delay(500);
    digitalWrite(D7,LOW);
    return 1;
}

int windSensor(String args)
{
    windValue = analogRead(A0);
    return windValue;
}

