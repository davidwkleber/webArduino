//Add the SPI library so we can communicate with the ADXL345 sensor
#include <SPI.h>

//Assign the Chip Select signal to pin 10.
int CS=10;

//This is a list of some of the registers available on the ADXL345.
//To learn more about these and the rest of the registers on the ADXL345, read the datasheet!
char POWER_CTL = 0x2D;	//Power Control Register
char DATA_FORMAT = 0x31;
char DATAX0 = 0x32;	//X-Axis Data 0
char DATAX1 = 0x33;	//X-Axis Data 1
char DATAY0 = 0x34;	//Y-Axis Data 0
char DATAY1 = 0x35;	//Y-Axis Data 1
char DATAZ0 = 0x36;	//Z-Axis Data 0
char DATAZ1 = 0x37;	//Z-Axis Data 1
char BW_Rate = 0x2c; //Set BW

long buad = 115200;

//This buffer will hold values read from the ADXL345 registers.
char values[10];
//These variables will be used to hold the x,y and z axis accelerometer values.
int x,y,z;
int xg,yg,zg;
int g;

//mg conversion (10-bit mode)
//+-2000 mg mode 3.90625 (DATA_FORMAT,0x00)
//+-4000 mg mode 7.8125 (DATA_FORMAT,0x01)
//+-8000 mg mode 15.625 (DATA_FORMAT,0x02)
//+-16000 mg mode 31.25 (DATA_FORMAT,0x03)
float multiplier= 3.90625; // in fullResMode multipliere is like -+2000mg mode
int g_correction = 0;



void setup(){
	//Initiate an SPI communication instance.
	SPI.begin();
	//Configure the SPI connection for the ADXL345.
	SPI.setDataMode(SPI_MODE3);
	//Create a serial connection to display the data on the terminal.
	Serial.begin(buad);
	
	//Set up the Chip Select pin to be an output from the Arduino.
	pinMode(CS, OUTPUT);
	//Before communication starts, the Chip Select pin needs to be set high.
	digitalWrite(CS, HIGH);
	
	//Put the ADXL345 set the g range 0x0b is full res +-16g Mode
	writeRegister(DATA_FORMAT, 0x0b);
	//Set the Bandwidth to 200Hz
	writeRegister(BW_Rate,0x0f);
	//Put the ADXL345 into Measurement Mode by writing 0x08 to the POWER_CTL register.
	writeRegister(POWER_CTL, 0x08);  //Measurement mode

}

void loop(){
	//Reading 6 bytes of data starting at register DATAX0 will retrieve the x,y and z acceleration values from the ADXL345.
	//The results of the read operation will get stored to the values[] buffer.
	readRegister(DATAX0, 6, values);

	//The ADXL345 gives 10-bit acceleration values, but they are stored as bytes (8-bits). To get the full value, two bytes must be combined for each axis.
	//The X value is stored in values[0] and values[1].
	x = (int)((byte)values[1]<<8)|(byte)values[0];
	//The Y value is stored in values[2] and values[3].
	y = (int)((byte)values[3]<<8)|(byte)values[2];
	//The Z value is stored in values[4] and values[5].
	z = (int)((byte)values[5]<<8)|(byte)values[4];
	
	xg = (int)((float)x * multiplier)-g_correction;
	yg = (int)((float)y * multiplier)-g_correction;
	zg = (int)((float)z * multiplier)-g_correction;
	//g = sqrt(pow(xg,2)+pow(yg,2)+pow(zg,2));
	
	//Print the results to the terminal.
	//Serial.print("x: ");
	//Serial.print((byte)values[1],BIN);
	//Serial.print(", ");
	//Serial.print((byte)values[0],BIN);
	//Serial.print(", ");
	//Serial.println(x);
	//Serial.print("y: ");
	//Serial.print((byte)values[3],BIN);
	//Serial.print(", ");
	//Serial.print((byte)values[2],BIN);
	//Serial.print(", ");
	//Serial.println(y);
	//Serial.print("z: ");
	//Serial.print((byte)values[5],BIN);
	//Serial.print(", ");
	//Serial.print((byte)values[4],BIN);
	//Serial.print(", ");
	//Serial.println(z);
	
	Serial.print(xg, DEC);
	Serial.print(',');
	Serial.print(yg, DEC);
	Serial.print(',');
	Serial.println(zg, DEC);
	//Serial.print(',');
	//Serial.println(g,DEC);
	delay(2);
}

//This function will write a value to a register on the ADXL345.
//Parameters:
//  char registerAddress - The register to write a value to
//  char value - The value to be written to the specified register.
void writeRegister(char registerAddress, char value){
	//Set Chip Select pin low to signal the beginning of an SPI packet.
	digitalWrite(CS, LOW);
	//Transfer the register address over SPI.
	SPI.transfer(registerAddress);
	//Transfer the desired register value over SPI.
	SPI.transfer(value);
	//Set the Chip Select pin high to signal the end of an SPI packet.
	digitalWrite(CS, HIGH);
}

//This function will read a certain number of registers starting from a specified address and store their values in a buffer.
//Parameters:
//  char registerAddress - The register addresse to start the read sequence from.
//  int numBytes - The number of registers that should be read.
//  char * values - A pointer to a buffer where the results of the operation should be stored.
void readRegister(char registerAddress, int numBytes, char * values){
	//Since we're performing a read operation, the most significant bit of the register address should be set.
	char address = 0x80 | registerAddress;
	//If we're doing a multi-byte read, bit 6 needs to be set as well.
	if(numBytes > 1)address = address | 0x40;
	
	//Set the Chip select pin low to start an SPI packet.
	digitalWrite(CS, LOW);
	//Transfer the starting register address that needs to be read.
	SPI.transfer(address);
	//Continue to read registers until we've read the number specified, storing the results to the input buffer.
	for(int i=0; i<numBytes; i++){
		values[i] = SPI.transfer(0x00);
	}
	//Set the Chips Select pin high to end the SPI packet.
	digitalWrite(CS, HIGH);
}
