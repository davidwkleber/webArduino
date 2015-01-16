
// Graph Multiple Sensors in Processing

// Takes ASCII-encoded strings from serial port and graphs them.
// Expects COMMA or TAB SEPARATED values, followed by a newline, or newline and carriage return
// Can read 10-bit values from Arduino, 0-1023 (or even higher if you wish)

// Last modified May 21, 2014
// by Eric Forman | www.ericforman.com | teaching.ericforman.com

// fft with Processing and arduino:
// https://www.linkedin.com/groups/FFT-Arduino-Processing-1268377.S.95470862


import processing.serial.*;
import ddf.minim.*;
import ddf.minim.analysis.*;


Table table;
PrintWriter output;
Serial myPort;
FFT fftX;
FFT fftY;
FFT fftZ;

//fft stuff
int fftSize =8;
int fftCounter=1;
float pointsX[] = new float[fftSize]; //datavector
float pointsY[] = new float[fftSize]; //datavector
float pointsZ[] = new float[fftSize]; //datavector
boolean fftReady = false;
float timeCounter=0;
float sampleRate=185;
WindowFunction windowName = FFT.HAMMING;


int numLinesToSave= 1024*1; //ca 5,6 sec * x

int minimum = -6000;
int maximum = 6000;

int buad = 115200;

int numValues = 3;    // number of input values or sensors
// * change this to match how many values your Arduino is sending *

int[] values   = new int[numValues];
int[]   min      = new int[numValues];
int[]   max      = new int[numValues];
color[] valColor = new color[numValues];
float[] oldY = new float[numValues];
int oldX =0; 
int[] maxValue = new int[numValues];
int[] minValue = new int[numValues];



//width-60,partH*3+10,50,70






float partH;          // partial screen height
float TextH;

int xPos = 0;         // horizontal position of the graph
//int counter = 0; 


PFont f;
String typing = "";
String saved  = "";

int ButtonX;
int ButtonY;
int rectWidth;
int rectHeight;
boolean rectOver = false;
boolean Save = false;
boolean recording= false;
boolean saveButton= false;

String S_Message = "Record";
String R_Message = "Recording";
String Message="";
color recordColor, baseColor;
String dataLine= "";

String column1 = "g_x in [mg]";
String column2 = "g_y in [mg]";
String column3 = "g_z in [mg]";
String column4 = "delta-t in [microseconds]";
String filename="";

String FileNameText="" ;


String column[]= {
  column4, column1, column2, column3
};

float width2;
float rectSizeY, rectSizeX;




void setup() {
  // init the csv Table
  table = new Table();
  table.addColumn(column[0]);
  table.addColumn(column[1]);  
  table.addColumn(column[2]);
  table.addColumn(column[3]);




  f = createFont("Arial", 16, true);

  //Screen size stuff
  size(displayWidth-100, displayHeight-100);
  partH = (height*0.95)/ numValues;
  TextH =partH*3+(height-partH*3)/2;
  width2=width*0.75;
  rectSizeX = width - width2;
  rectSizeY= partH;


  /*
 println("DispHeight: ",displayHeight); 
   println("TextH: ",partH*3);
   println("Height: ", height);
   */


  //initializing the peak detector
  emptyPeakArray();

  //setting the y start value for the lines
  for (int i = 0; i< numValues; i++)
  {
    oldY[i]= partH*(i+1)-partH/2;
  }


  //Button settings
  ButtonX = width-70;
  ButtonY =(int(partH)*3)+10;
  rectWidth  = 60;
  rectHeight = 30;

  //record Button setting
  recordColor = color(255, 0, 0);
  baseColor  = color(0);

  // List all the available serial ports:
  printArray(Serial.list());
  // First port [0] in serial list is usually Arduino, but *check every time*:
  myPort = new Serial(this, Serial.list()[0], buad);
  // don't generate a serialEvent() until you get a newline character:
  myPort.bufferUntil('\n');





  //setting and  initializing Inputdata  Arrays
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


  textSize(12); 
  background(0);
  noStroke();
  println("ready..");
}


void draw() {
  // in this example, everything happens inside serialEvent()
  // but you can also do stuff in every frame if you wish

  update(mouseX, mouseY);
  if (saveButton)
  {
    Message= R_Message;
    Save = true;
    filename = "data/"+str(year())+nf(month(), 2)+nf(day(), 2)+"-"+nf(hour(), 2)+nf(minute(), 2)+nf(second(), 2)+"_"+saved+".csv";
    println("Saving to ", filename);
    saveButton=false;
  } else
  {
    Message = S_Message;
    //Save = false;
  }
  //FFT stuff
}



/*------------------------Main Action-----------------------------------*/
void serialEvent(Serial myPort) {

  TableRow newRow = table.addRow();
  if (!Save)
  {
    table.clearRows();
  }
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');
  //print("raw: \t" + inString);        // < - uncomment this to debug serial input from Arduino
  textAlign(LEFT);
  fill(64);
  stroke(255, 0, 0);  
  rect(0, partH*3+1, width-80, height);
  fill(255);
  stroke(0, 255, 0);
  text("Enter Filename: ", 10, TextH-6, width*.08, height-TextH);
  text(typing, width*.08+7, TextH-6, width*.25-width*.08-10, height-TextH);
  text("Actual Filename: ", width*.25, TextH-6, width*.29-width*.1, height-TextH);
  text(saved, width*.33+2, TextH-6, width*.4-width*.2-1, height-TextH);
  text("Saved "+  str(numLinesToSave) + " Lines to: ", width*.5+5, TextH-6, width*.51-width*.28, height-TextH);
  text(filename, width*.6+10, TextH-6, width-width*.6-100, height-TextH);


  fill(128);
  stroke(255);
  rect(ButtonX, ButtonY, rectWidth, rectHeight);
  if (Save)
  {
    fill(recordColor);
    Message= R_Message;
  } else
  {
    fill(baseColor);
  }
  textAlign(CENTER, CENTER);
  text(Message, ButtonX, ButtonY, rectWidth, rectHeight);



  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);

    // split the string on the delimiters and convert the resulting substrings into an float array:
    //int[] valuesTemp = int(splitTokens(inString, ", \t"));
    values = int(splitTokens(inString, ", \t"));    // delimiter can be comma space or tab

    // if the array has at least the # of elements as your # of sensors, you know
    // you got the whole data packet.  Map the numbers and put into the variables:
    if (values.length >= numValues) {
      for (int i=0; i<numValues; i++) {
        //values[i] = float(valuesTemp[i]);
        //println(i + ": " + values[i]);
        //println( values);

        //Peak detection
        if (values[i]>maxValue[i])
        {
          maxValue[i]=values[i];
        }
        if (values[i]<minValue[i])
        {
          minValue[i]=values[i];
        }
/*
        //collecting fft aray
        if (fftCounter<=fftSize)
        {
          println("FFTCounter: ", fftCounter);
          if (i==0)
          {
            pointsX[fftCounter-1]=values[i];
            //println("X: ", pointsX[fftCounter-1]);
          } else if (i==1)
          {
            pointsY[fftCounter-1]=values[i];
            //println("Y: ", pointsY[fftCounter-1]);
          } else if (i==2)
          {
            pointsZ[fftCounter-1]=values[i];
            //println("Z: ", pointsZ[fftCounter-1]);
          }
          //fftCounter++;


          if (fftCounter!=1)
          {
            timeCounter+=values[4];
            println("TimeCounter1: ", timeCounter);
            
            println("FFTcounter: ", fftCounter);
          } else 
          {
            timeCounter=values[4] ;
            println("TimeCounter2: ", timeCounter);
            
          }
        } 
        else
        {
          fftCounter=1;  
          fftReady=true;
          sampleRate= timeCounter/ fftSize;
        }
//fftCounter++;


        //}
/*
        //little Textbox upper left corner
        textAlign(CENTER);
        fill(50);
        //noStroke();
        stroke(255, 0, 0);
        strokeWeight(1);
        rect(0, partH*i+1, 120, 20);
        fill(255);
        text(int(values[i]), 20, partH*i+15);
        fill(128);
        text(minValue[i]+", "+maxValue[i], 80, partH*i+15);

*/

        if (Save)
        {
          newRow.setInt(column[i+1], values[i]);
          recording = true;
        }
        // map to the range of partial screen height:
        float mappedVal = map(values[i], min[i], max[i], 0, partH);


        // draw Data lines (Timedomain):
        stroke(valColor[i]);
        strokeWeight(1);
        xPos=int(oldX)+int(float(values[numValues])/1000.0);        //line(xPos, partH*(i+1), xPos, partH*(i+1) - mappedVal);
        // println("Time: ",values[numValues-1]);
        //println("xPos: ",xPos);
        // println("oldX: ",oldX);
        line(oldX, oldY[i], xPos, partH*(i+1) - mappedVal);
        oldY[i] = partH*(i+1) - mappedVal;

        // draw dividing line:
        stroke(255);
        line(0, partH*(i+1), width, partH*(i+1));
        stroke(128, 8);
        line(0, partH*(i+1)-partH/2, width2, partH*(i+1)-partH/2);
        stroke(255);
        line(width2, 0, width2, partH*numValues);

        //println("\t"+mappedVal);   // <- uncomment this to debug values

          //FFT Stuff
        if (fftReady)
        {
          if (i==0)
          {
            fftX = new FFT(fftSize, sampleRate);
            fftX.window(windowName);
            for (int h=0; h< fftX.specSize (); h++)
            {
              float mappedSizeX = mapping(fftX.getBand(i), fftX.specSize());   //map(fft.getBand(i),0,fft.specSize(),0,rectSizeY);
              colorMode(HSB, rectSizeX-1);
              stroke(i/2, (rectSizeX-1)*0.75, (rectSizeX-1)*0.75);
              colorMode(RGB);
              line(width2+h, partH*(i+1), width2+h, partH*(i+1) - mappedSizeX);
            }
          } 
          /*
          else if (i==1)
           {
           fftY = new FFT(fftSize, sampleRate);
           fftY.window(windowName);
           } 
           else if (i==2)
           { 
           fftZ = new FFT(fftSize, sampleRate);
           fftZ.window(windowName);
           }
           
           */

          fftReady=false;
        }
      }
      //println(str(values[values.length-1]));
      if (Save)
      {
        newRow.setInt(column[0], values[values.length-1]);
        recording=true;
      }


      //println("Values: ",values);                   // <- uncomment this to debug values

      // if at the edge of the screen, go back to the beginning:
      if (xPos >= width2) {
        //noLoop();

        xPos = 0;
        oldX=0;
        // two options for erasing screen, i like the translucent option to see "history"
        //background(0);           // erase screen with black
        fill(0, 200);
        noStroke();
        rect(0, 0, width, partH*3-1);    // erase screen with translucent black
        emptyPeakArray();
      } else {
        oldX = xPos;
        //xPos+=2;                    // increment the graph's horizontal position
      }
    }
  }
  //println(dataLine);

  if (Save && table.getRowCount()>=numLinesToSave)
  {

    saveTable(table, filename, "tsv");
    table.clearRows();
    Save=false;
    recording = false;
    println("Done...");
  }
}

/*-------------------------------End of Main Action----------------------------------------*/

/*--------------------------------Functions------------------------------------------------*/

void keyPressed() {
  // If the return key is pressed, save the String and clear it
  if (key == '\n' ) {
    if (typing.length()>0)
    {

      saved = typing;
      // A String can be cleared by setting it equal to ""
      typing = "";
    }
  } else if (key ==BACKSPACE)
  {
    if (typing.length()>0)
    {
      typing = typing.substring(0, typing.length()-1);
    }
  } else if (typing.length()<=20)
  {
    // Otherwise, concatenate the String
    // Each character typed by the user is added to the end of the String variable.
    typing = typing + key;
  }
}


void update(int x, int y) {
  if ( overRect(ButtonX, ButtonY, rectWidth, rectHeight) ) {
    rectOver = true;
  } else {
    rectOver = false;
  }
}

void mousePressed() {
  if (mousePressed && (mouseButton == LEFT) && rectOver  && !recording) {    
    saveButton=true;
  } else
    saveButton=false;
}

boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

void emptyPeakArray() {
  for (int i=0; i<numValues; i++)
  {
    minValue[i]=0;
    maxValue[i]=0;
  }
}


float mapping( float mapVal, float specSize)
{
  return map(mapVal, 0, specSize, 0, partH);
}

