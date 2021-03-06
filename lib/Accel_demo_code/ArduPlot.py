
#Source:http://rwsarduino.blogspot.co.uk/2014/12/python-plots-from-serial-input.html
import matplotlib.pyplot as plt
import time
import serial
print"start.."
plt.ion()
ser = serial.Serial('COM25',57600)
line = ser.readline() # throw away any part lines
print"Start Serial.."
##while(ser.inWaiting() < 100): # make sure something is coming
##  print ser.inWaiting()
##  now = 0.0
##  print"waiting..\n"
print"initialize the data lists"
t=[] # 
d1=[]
d2=[]
d3=[]
while (ser.isOpen()):
    #print"in.."
    line = ser.readline() # read a line of text
    if (line.count(",",0,len(line)-1)== 4):
        mylist = line.split(",") # parse it into CSV tokens
        #print mylist
        
        try:
            now = float(mylist[0])/1000000 # time now in seconds
            t.append(float(mylist[0])/1000000) # from first element as milliseconds
            d1.append(float(mylist[1])+20) # six data elements added to lists
            d2.append(float(mylist[2]))
            d3.append(float(mylist[3])-20)


            if(ser.inWaiting() < 100): # redraw only if you are caught up
                plt.clf() # clear the figure
                plt.plot(t,d1) # plot a line for each set of data
                plt.plot(t,d2)
                plt.plot(t,d3)

                plt.axis([now-60,now,-50,+50])
                plt.xlabel("Time Since Boot [s]")
                
                plt.draw()
                plt.pause(0.0001)
        except:
            print mylist

    
ser.close()