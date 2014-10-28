
// Graph Multiple Sensors in Processing
 
// Takes ASCII-encoded strings from serial port and graphs them.
// Expects COMMA or TAB SEPARATED values, followed by a newline, or newline and carriage return
// Can read 10-bit values from Arduino, 0-1023 (or even higher if you wish)
 
// Last modified May 21, 2014
// by Eric Forman | www.ericforman.com | teaching.ericforman.com
 
import processing.serial.*;
Serial myPort;
 
int numValues = 3;    // number of input values or sensors
                      // * change this to match how many values your Arduino is sending *
 
float[] values   = new float[numValues];
int[]   min      = new int[numValues];
int[]   max      = new int[numValues];
color[] valColor = new color[numValues];

int minimum = -16000;
int maximum = 16000;
 
float partH;          // partial screen height
 
int xPos = 1;         // horizontal position of the graph
 
 
void setup() {
  size(1200, 700);
  partH = height / numValues;
 
  // List all the available serial ports:
  printArray(Serial.list());
  // First port [0] in serial list is usually Arduino, but *check every time*:
  myPort = new Serial(this, Serial.list()[0], 115200);
  // don't generate a serialEvent() until you get a newline character:
  myPort.bufferUntil('\n');
 
  textSize(10);
 
  background(0);
  noStroke();
 
  // initialize:
  // *edit these* to match how many values you are reading, and what colors you like
  values[0] = 0;
  min[0] = minimum;
  max[0] = maximum;  // 8-bit (0-255) example
  valColor[0] = color(255, 0, 0); // red
 
  values[1] = 0;    
  min[1] = minimum;
  max[1] = maximum; // 10-bit (0-1023) example
  valColor[1] = color(0, 255, 0); // green
 
  values[2] = 0;
  min[2] = minimum;
  max[2] = maximum;    // 1-bit (0-1) example, e.g. a digital switch
  valColor[2] = color(0, 0, 255); // blue
/*
  // example for adding a 4th value:
  values[3] = 0;
  min[3] = 0;
  max[3] = 400;  // custom range example
  valColor[3] = color(255, 0, 255); // purple
*/
}
 
 
void draw() {
  // in this example, everything happens inside serialEvent()
  // but you can also do stuff in every frame if you wish
}
 
 
void serialEvent(Serial myPort) {
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');
  //print("raw: \t" + inString);        // < - uncomment this to debug serial input from Arduino
 
  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
 
    // split the string on the delimiters and convert the resulting substrings into an float array:
    //int[] valuesTemp = int(splitTokens(inString, ", \t"));
    values = float(splitTokens(inString, ", \t"));    // delimiter can be comma space or tab
 
    // if the array has at least the # of elements as your # of sensors, you know
    // you got the whole data packet.  Map the numbers and put into the variables:
    if (values.length >= numValues) {
      for (int i=0; i<numValues ; i++) {
        //values[i] = float(valuesTemp[i]);
        //print(i + ": " + values[i]);
        // print values:
        fill(50);
        noStroke();
        rect(0, partH*i+1, 70, 12);
        fill(255);
        text(int(values[i]), 2, partH*i+10);
        fill(125);
        text(max[i], 40, partH*i+10);
 
        // map to the range of partial screen height:
        float mappedVal = map(values[i], min[i], max[i], 0, partH);
 
        // draw lines:
        stroke(valColor[i]);
        line(xPos, partH*(i+1), xPos, partH*(i+1) - mappedVal);
 
        // draw dividing line:
        stroke(255);
        line(0, partH*(i+1), width, partH*(i+1));
 
      //  println("\t"+mappedVal);   // <- uncomment this to debug values
      }
      //println();                   // <- uncomment this to debug values
 
      // if at the edge of the screen, go back to the beginning:
      if (xPos >= width) {
        xPos = 0;
        // two options for erasing screen, i like the translucent option to see "history"
        //background(0);           // erase screen with black
        fill(0,200);
        noStroke();
        rect(0,0,width,height);    // erase screen with translucent black
      }
      else {
        xPos++;                    // increment the graph's horizontal position
      }
    }
  }
}
//</numvalues>
