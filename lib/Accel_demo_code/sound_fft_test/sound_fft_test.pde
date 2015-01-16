import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioInput in;
FFT fft;

PImage fade;
PFont font;

int rectX,rectY,rectSizeX,rectSizeY;
int hVal;
int b;

float rWidth,rHeight;
boolean save= false;
boolean saved= true;

float peakX;
float peakY;
float frequency;


void setup()
{
 size(displayWidth-100, displayHeight-100);
 //size(640,480);
 minim = new Minim(this);
 in = minim.getLineIn(Minim.STEREO,4096);

 fft = new FFT(in.bufferSize(), in.sampleRate());
 println("Buffersize: ", in.bufferSize());
 println("Samplerate: ", in.sampleRate());
// stroke(255);
 background(0);
 fade = get();
 
 rectX = 0;
 rectY=0;
 rectSizeX = width/1;
 rectSizeY = height/1;
 
 hVal=0;
 println("rectSizeX: ",rectSizeX);
 
 rWidth= width*0.995;
rHeight =height* 0.995;
 
 b=300000;
 peakX=0;
 peakY=0;
 strokeWeight(5);
 font = createFont("Arial-BoldMT-12",12,true);
 textFont(font);
 textSize( 12 );
}

void draw()
{
  background(0);
  //tint(255,01);
  
  
  image(fade,(width -rWidth )/2,(height-rHeight)/2,rWidth,rHeight);
  //noTint();

 fft.forward(in.mix);
 //println(in.mix);
  //println(fft.specSize());
//stroke(255);
fill(0);
//rect(rectX-1,rectY+1,rectSizeX,rectSizeY);
//noFill();
// stroke(255);
// line(rectX,rectY+rectSizeY-10,rectX+rectSizeX ,rectY+rectSizeY-10 );
 //atroke(0);
 for (int i = 0; i< fft.specSize(); i++)
 {
  float mappedSize = mapping(fft.getBand(i));//map(fft.getBand(i),0,fft.specSize(),0,rectSizeY);

  colorMode(HSB,rectSizeX-1);
  stroke(i/2,(rectSizeX-1)*0.75,(rectSizeX-1)*0.75);
  colorMode(RGB);
  line(rectX+i,rectY+rectSizeY,rectX+i,rectY+rectSizeY - mappedSize*20);   
  
  //print and find PEak frequency  
  if (fft.getBand(i)>peakY)
  {
   peakY=fft.getBand(i);
   peakX=i;
  }
 
 stroke(255);
 strokeWeight(10);
 point(rectX+peakX,rectY+rectSizeY - mapping(peakY)*20);
 strokeWeight(1);

  
  if (b>0)
  {
    b--;
  
  //println("b: ", b);
 }
  if (i== fft.specSize()-1&!save&saved&b==0)
 {
   println("save is true");
   save= true;
 }

 }

 //text(frequency,rectX+peakX,rectY+rectSizeY - mapping(peakY)*20+10);
 
 
 
 //fade=get(0,0,1,1);
 fade=get(0,0,width,height);
 if (save)
 {
  fade.save("output.png");
  saved= false; 
 save=false;
 }
 

 frequency = fft.indexToFreq(int(peakX));
 //println(peakX);
 //println(peakY);
 fill(255);
 stroke(255);
 strokeWeight(5);
// println(frequency);
 text(frequency,0,20);

 
// background(0);
 //image(fade,0,0);
 for (int i = 0; i< fft.specSize(); i++)
 {
  float mappedSize= map(fft.getBand(i),0,fft.specSize(),0,rectSizeY);

  colorMode(HSB,rectSizeX-1);
  stroke(i/2,(rectSizeX-1),(rectSizeX-1));
  colorMode(RGB);
  line(rectX+i,rectY+rectSizeY,rectX+i,rectY+rectSizeY - mappedSize*15-10); 
  stroke(0);
  strokeWeight(2);
  point(rectX+i,rectY+rectSizeY - mappedSize*20);
    strokeWeight(1);
  
 }
  stroke(255);
 line(rectX,rectY+rectSizeY-9,rectX+rectSizeX ,rectY+rectSizeY-9 );
 
 peakX=0;
 peakY=0;
}



float mapping( float mapVal)
{
 return map(mapVal,0,fft.specSize(),0,rectSizeY);  
}

