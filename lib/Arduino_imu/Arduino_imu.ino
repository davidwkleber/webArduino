// Maurice Ribble 
// 6-28-2009
// http://www.glacialwanderer.com/hobbyrobotics

// This app just probes two external sensors (ADXL330 and IDG300) and 
// then sends that data over a serial connection.  I used a sparkfun
// breakout board to make using these chips easier.
// http://www.sparkfun.com/commerce/product_info.php?products_id=741

// I wrote a processing.org app that reads in this data and graphs it
// on a pc.

#define X_ACCEL_APIN 0
#define Y_ACCEL_APIN 1
#define Z_ACCEL_APIN 2
#define V_REF_APIN   3
#define Y_RATE_APIN  4
#define X_RATE_APIN  5

void setup()
{
  Serial.begin(115200);
}

// If this is defined it prints out the FPS that we can send a
// complete set of data over the serial port.
//#define CHECK_FPS

void loop()
{
  int xAccel=0, yAccel=0, zAccel=0, vRef=0, xRate=0, yRate=0;
  unsigned int startTag = 0xDEAD;  // Analog port maxes at 1023 so this is a safe termination value
  int loopCount;

#ifdef CHECK_FPS  
  unsigned long startTime, endTime;
  startTime = millis();
#endif
  
  // Can't do more than 64 loops or could overflow the 16 bit ints
  // This just averages together as many sensor reads as we can in
  // order to reduce sensor noise.  Might want to introduce add
  // a smarter filter her in the future.
  loopCount = 12;  // 12 gives a little over 100 FPS
  for(int i = 0; i< loopCount; ++i)
  {
    // It takes 100 us (0.0001 s) to read an analog input
    xAccel += analogRead(X_ACCEL_APIN);
    yAccel += analogRead(Y_ACCEL_APIN);
    zAccel += analogRead(Z_ACCEL_APIN);
    vRef   += analogRead(V_REF_APIN);
    xRate  += analogRead(X_RATE_APIN);
    yRate  += analogRead(Y_RATE_APIN);
  }
  xAccel /= loopCount;
  yAccel /= loopCount;
  zAccel /= loopCount;
  vRef   /= loopCount;
  xRate  /= loopCount;
  yRate  /= loopCount;

  Serial.write( (unsigned byte*)&startTag, 2);
  Serial.write((unsigned byte*)&xAccel, 2);
  Serial.write((unsigned byte*)&yAccel, 2);
  Serial.write((unsigned byte*)&zAccel, 2);
  Serial.write((unsigned byte*)&vRef, 2);
  Serial.write((unsigned byte*)&xRate, 2);
  Serial.write((unsigned byte*)&yRate, 2);
  
#ifdef CHECK_FPS  
  endTime = millis();
  Serial.print(" - FPS: ");
  Serial.println(1.f / (endTime-startTime) * 1000);
#endif
}

