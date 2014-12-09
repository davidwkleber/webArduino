
// Graph Multiple Sensors in Processing
 
// Takes ASCII-encoded strings from serial port and graphs them.
// Expects COMMA or TAB SEPARATED values, followed by a newline, or newline and carriage return
// Can read 10-bit values from Arduino, 0-1023 (or even higher if you wish)
 
// Last modified May 21, 2014
// by Eric Forman | www.ericforman.com | teaching.ericforman.com
 
import processing.serial.*;
Table table;
PrintWriter output;
Serial myPort;

int numLinesToSave= 1024*4; //ca 5,6 sec * x

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
float oldX =0; 
int[] maxValue = new int[numValues];
int[] minValue = new int[numValues];



//width-60,partH*3+10,50,70





 
float partH;          // partial screen height
float TextH;
 
int xPos = 1;         // horizontal position of the graph
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
String R_Message = "Stop";
String Message="";
color recordColor, baseColor;
String dataLine= "";

String column1 = "g_x in [mg]";
String column2 = "g_y in [mg]";
String column3 = "g_z in [mg]";
String column4 = "delta-t in [microseconds]";
String filename="";

String FileNameText="" ;


String column[]={column4,column1,column2,column3};




void setup() {
  
  table = new Table();
  table.addColumn(column[0]);
  table.addColumn(column[1]);  
  table.addColumn(column[2]);
  table.addColumn(column[3]);
  

  
  recordColor = color(255,0,0);
  baseColor  = color(0);
  f = createFont("Arial",16,true);
  size(displayWidth-100, displayHeight-100);
  partH = (height*0.95)/ numValues;
  TextH =partH*3+(height-partH*3)/2;
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


  // List all the available serial ports:
  printArray(Serial.list());
  // First port [0] in serial list is usually Arduino, but *check every time*:
  myPort = new Serial(this, Serial.list()[0], buad);
  // don't generate a serialEvent() until you get a newline character:
  myPort.bufferUntil('\n');
 
 

 
  textSize(12);
 
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
  /*
  fill(10,150);
  //stroke(255,0,0);  
  rect(0,partH*3+1,width,height);
  fill(255);
  //stroke(0,255,0);
  text("Filename: ",0,TextH,width/3+1,height);
  text(typing,width/3,TextH,width*2/3+1,height);
  text(saved,width*2/3,TextH,width,height);
 */
  update(mouseX,mouseY);
  if (saveButton)
  {
    Message= S_Message;
    Save = true;
    filename = "data/"+str(year())+nf(month(),2)+nf(day(),2)+"-"+nf(hour(),2)+nf(minute(),2)+nf(second(),2)+"_"+saved+".csv";
    println("Saving to ",filename);
    saveButton=false;
  }
  else
  {
    Message = S_Message;
    //Save = false;
  }
  

  
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
  stroke(255,0,0);  
  rect(0,partH*3+1,width-80,height);
  fill(255);
  stroke(0,255,0);
  text("Enter Filename: ",10,TextH-6,width*.08,height-TextH);
  text(typing,width*.08+7,TextH-6,width*.25-width*.08-10,height-TextH);
  text("Actual Filename: ",width*.25,TextH-6,width*.29-width*.1,height-TextH);
  text(saved,width*.33+2,TextH-6,width*.4-width*.2-1,height-TextH);
  text("Saved "+  str(numLinesToSave) + " Lines to: ",width*.5+5,TextH-6,width*.51-width*.28,height-TextH);
  text(filename,width*.6+10,TextH-6,width-width*.6-100,height-TextH);
  
 //rectMode(CORNERS);
 /*
int ButtonX = width-60
int ButtonY =partH*3+10;
int rectWidth  = 70;
int rectHeight = 50;
*/


 fill(128);
 stroke(255);
 rect(ButtonX,ButtonY,rectWidth,rectHeight);
 if (Save)
{
   fill(recordColor);
   
}
else
{
 fill(baseColor); 
}
textAlign(CENTER, CENTER);
text(Message, ButtonX,ButtonY,rectWidth,rectHeight);

 
 
  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
 
    // split the string on the delimiters and convert the resulting substrings into an float array:
    //int[] valuesTemp = int(splitTokens(inString, ", \t"));
    values = int(splitTokens(inString, ", \t"));    // delimiter can be comma space or tab
 
    // if the array has at least the # of elements as your # of sensors, you know
    // you got the whole data packet.  Map the numbers and put into the variables:
    if (values.length >= numValues) {
      for (int i=0; i<numValues ; i++) {
        //values[i] = float(valuesTemp[i]);
        //print(i + ": " + values[i]);
        // print values:
        
        //Peak detection
        if(values[i]>maxValue[i])
        {
        maxValue[i]=values[i];
        }
        if(values[i]<minValue[i])
        {
        minValue[i]=values[i];
        }
        
        
        //little Textbox upper left corner
        fill(50);
        //noStroke();
        stroke(255,0,0);
        strokeWeight(1);
        rect(0, partH*i+1, 120, 24);
        fill(255);
        text(int(values[i]), 10, partH*i+12);
        fill(128);
        text(minValue[i]+", "+maxValue[i], 80, partH*i+12);
        
        if (Save)
        {
        newRow.setInt(column[i+1],values[i]);
        recording = true;
        }
        // map to the range of partial screen height:
        float mappedVal = map(values[i], min[i], max[i], 0, partH);
 
        // draw lines:
        stroke(valColor[i]);
        strokeWeight(1);
        //line(xPos, partH*(i+1), xPos, partH*(i+1) - mappedVal);
        line(oldX, oldY[i], xPos, partH*(i+1) - mappedVal);
        oldY[i] = partH*(i+1) - mappedVal;
        
        // draw dividing line:
        stroke(255);
        line(0, partH*(i+1), width, partH*(i+1));
	line(0,partH*(i+1)/2,width, partH*(i+1)/2);
 
        //println("\t"+mappedVal);   // <- uncomment this to debug values
       
      }
       //println(str(values[values.length-1]));
      if(Save)
      {
        newRow.setInt(column[0],values[values.length-1]);
        recording=true;
      }
      
     
      //println();                   // <- uncomment this to debug values
 
      // if at the edge of the screen, go back to the beginning:
      if (xPos >= width) {
        //noLoop();
        
        xPos = 0;
        oldX=0;
        // two options for erasing screen, i like the translucent option to see "history"
        //background(0);           // erase screen with black
        fill(0,220);
        noStroke();
        rect(0,0,width,partH*3-1);    // erase screen with translucent black
        emptyPeakArray();
      }
      else {
        oldX = xPos;
        xPos+=2;                    // increment the graph's horizontal position
    
    }
      
    }
    
  }
  //println(dataLine);
  
  if(Save && table.getRowCount()>=numLinesToSave)
  {
  
  saveTable(table,filename,"tsv");
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
  } 
  
  
  else if(key ==BACKSPACE)
  {
    if(typing.length()>0)
    {
    typing = typing.substring(0,typing.length()-1);
    }
  }
  else if(typing.length()<=20)
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
  }
  else
  saveButton=false;
}

boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

void emptyPeakArray(){
  for (int i=0;i<numValues;i++)
  {
      minValue[i]=0;
      maxValue[i]=0;
  
  }

}
