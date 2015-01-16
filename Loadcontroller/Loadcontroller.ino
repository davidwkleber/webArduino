#include <Wire.h>
#include <Adafruit_MCP4725.h> //the library was modified [changed to: #define MCP4726_CMD_WRITEDAC (0x58) ] to use external Vref!
//#include <math.h>

//
#define FASTADC 1
// defines for setting and clearing register bits
#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

String version = "1.0";

bool debug = false;
static uint8_t DAC_addr = 0x60;
// static char VrefSet = 0x18; //11000: Vref1;Vref0;PD1;PD0;G




int readA0;
int readA1;
int readA2;



int Number;
int readAnalog;
int resistance = 200;
int I_set;

String msg = "H";

const long buad = 9600;

Adafruit_MCP4725 dac;
float V_ref;

float Vref()
{ //Vin=3.001; Vref=Vin*1024/Vbit
	return analogRead(A2);
}



void setCurrent_R(int res)
{
	//Version 1
	//readAnalog = map(analogRead(A0),0,1023,0,4095);
	//res=constrain(res,0,200);
	//int set = constrain(round(readAnalog/res),0,4095);
	//dac.setVoltage(set,false);
	//if (debug)
	//{
	//Serial.print(readAnalog);
	//Serial.print(", ");
	//Serial.print(res);
	//Serial.print(", ");
	//Serial.println(set);
	
	
	
	int set;
	float Voltage =analogRead(A0);
	
	
	if (res)
	{
		set = constrain((int)round(4096*Voltage/(Vref()*(float)res)),0,4095);
	}
	else
	{
		set = 0;
	}
	if (debug)
	{
		Serial.print("I_set_R: ");
		Serial.println(set);
	}
	dac.setVoltage(set,false);
	
	//}
}



void setup()
{
	#if FASTADC
	// set prescale to 16
	sbi(ADCSRA,ADPS2);
	cbi(ADCSRA,ADPS1);
	cbi(ADCSRA,ADPS0);
	#endif

	TWBR = 12; // set I2C Speed to 400 kHz

	dac.begin(DAC_addr);


	Serial.begin(buad);
	Serial.println("Ready");


}

void loop()
{

	if(Serial.available()>0)
	{
		msg="";
		while(Serial.available()>0)
		{
			msg+=char(Serial.read());
			delay(10);
		}
		if (debug)
		{
			Serial.print("msg1: ");
			Serial.println(msg);
		}
		
	}
	Number = msg.substring(1).toInt();
	msg = msg.substring(0,1);
	
	if (debug)
	{
		Serial.print("Number: ");
		Serial.print(Number);
		Serial.print(", msg: ");
		Serial.println(msg);
	}
	
	
	if (msg.equals("R"))
	{
		resistance = Number;
		
		Serial.println(".");
		msg="";
		
	}
	else if (msg.equals("I"))
	{
		float current = Number;
		I_set = constrain(round(current*1365/1000),0,4095);
		if (debug)
		{
			Serial.print("I_Set_I: ");
			Serial.println(I_set);
		}
		//dac.setVoltage(I_set,false);
		msg="";
	}
	else if (msg.equals("D"))
	{
		debug=!debug;
		msg="";
	}
	else if (msg.equals("H"))
	{
		Serial.println("Loadcontroller");
		Serial.print("Firmware  Version:");
		Serial.println(version);
		Serial.println("Commands:");
		Serial.println("H    : prints this massage");
		Serial.println("Ixxxx: set Current to xxxx mA");
		Serial.println("Rxxxx: set Resistance to xxx Ohm (not Implemented yet!!!)");
		Serial.println("D    : toggle debug mode on and off");
		msg="";
		
	}
	// readA0=analogRead(A0);
	//readA1=analogRead(A1);
	//V_ref=Vref(readA2=analogRead(A2));
	if (debug)
	{
		int Reg = MCP4726_CMD_WRITEDAC;
		float VoltVref = 3.001*1024/Vref();
		Serial.print("DAC Register: ");
		Serial.println(Reg,HEX);
		Serial.print("Vref [V]: ");
		Serial.println(VoltVref);
		Serial.println(Vref());
		Serial.print("Resistance: ");
		Serial.println(resistance);
	}

	//setCurrent_R(resistance);
	dac.setVoltage(I_set,false);
}
