
//
#define FASTADC 1
// defines for setting and clearing register bits
#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

int readA0;
int readA1;
int readA2;
//int readA3;
//int readA4;
//int readA5;

long nowTime=0;
long lastTime=0;
long deltaTime=0;

int readAnalog[3];
//int readPort[] = {0,1,2}
int vConv[]={16,3,11};


long buad = 115200;




void setup()
{
	#if FASTADC
	// set prescale to 16
	sbi(ADCSRA,ADPS2);
	cbi(ADCSRA,ADPS1);
	cbi(ADCSRA,ADPS0);
	#endif


	Serial.begin(buad);
	//Serial.println("Ready");

}

void loop()
{
	nowTime = micros();
	deltaTime = nowTime - lastTime;
	if (deltaTime>=1600)
	{
for (int i=0; i<3;i++)
{
	readAnalog[i] = analogRead(i)*vConv[i];
	Serial.print(readAnalog[i],DEC);
	Serial.print(",");
}
	Serial.println(deltaTime);
	lastTime=nowTime;
}

}




