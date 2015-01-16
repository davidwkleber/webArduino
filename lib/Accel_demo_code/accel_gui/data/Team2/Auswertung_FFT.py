# coding=utf-8


import csv,os,sys
from pylab import *
import platform
#from scipy.interpolate import spline
import matplotlib.pyplot as plt

print platform.python_version()
print'###############'

thr_scaler = 0.3


#Konstanten

def read_csvfile(filename):
    '''liest die Daten in eine Liste ein.'''

    data =[]
    for row in csv.reader(open(filename),delimiter='\t'):
        data.append(row)
    return data

def process_data(data):
    '''Bearbeitet die Daten des Experiments.
    Gibt ein Tupple von Arrays zurück: 
    '''
    deltaTime=[]
    g_x = []
    g_y = []
    g_z = []
    for row in data:
        try:
            deltaTime.append(float(row[0])/1000000) # convert to sec
            g_x.append(float(row[1]))             # milli g
            g_y.append(float(row[2]))
            g_z.append(float(row[3]))
        except:
            pass
    return(array(deltaTime), array(g_x), array(g_y), array(g_z))

def plotFFT( G,deltaTime,sampleTime,sampleRate,contTime, headerNum):
    hann = hanning(len(G))
    t = arange(0,len(deltaTime)*sampleTime,sampleTime)
    # print len(deltaTime)
    # print len(t)
    # #print t
    # hold(True)
    # plot(t,hann_X*g_x,label="with Hanning Window")
    # #plot(deltaTime,g_x,label="Raw Data")
    # hold(False)
    # grid()
    # legend()

    
    figure()
    g_hann = fft(G*hann)    
    #Nyquist Frequency
    g_length = len(g_hann)/2+1
    g_Hz = linspace(0, sampleRate/2,g_length,endpoint=True)
    suptitle(header[0][headerNum][:-8], fontsize=12)
    #subplot(131)
    
    plot(contTime,G)
    grid()
    xlim(0,contTime[-1])
    ylim(0,max(G)*1.1)
    title("Time Domain Signal")
    xlabel('Time ($s$)')
    ylabel('Amplitude ($mg$)')
    
    #subplot(132)
    figure()
    subplot2grid((1,3),(0,0),colspan=2)
    suptitle(header[0][headerNum][:-8], fontsize=12)
    grid()
    hold(True)
    abs_g_hann = 2.0*abs(g_hann[:g_length])/g_length
    plot(g_Hz, abs_g_hann, label="FFT")
    
    #peak detection
    thr =  max(abs_g_hann)*thr_scaler
    I = find(abs_g_hann>thr)
    
    #plotting
    plot(g_Hz[I],abs_g_hann[I], 'ro', label="Peaks")
    plot([0, g_Hz[-1]], [thr, thr], 'g--')
    xlim(0,g_Hz[-1])
    ylim(1.1*min(abs_g_hann),1.1*max(abs_g_hann))
    # annotate the threshold
    text(2, thr+.2, 'Threshold='+str(int(thr))+" mg", va='bottom')
    legend(loc='best')
    
    title('Frequency Domain Signal')
    xlabel('Frequency ($Hz$)')
    ylabel('Amplitude ($mg$)')
    hold(False)
    
    #Peaktable
    f=subplot2grid((1,3),(0,2))
    f.axes.get_xaxis().set_visible(False)
    f.axes.get_yaxis().set_visible(False)
    #ylim(-1,0)
    columns=('Frequency [Hz]','Amplitude [mg]')
    rows= ['%d' % x for x in range(1,len(I)+1)]
    # print len(I)
    # print(I)
    # print len(rows)
    # print rows
    len (g_Hz[I])
    # print g_Hz[I]
    len(abs_g_hann[I])
    # print abs_g_hann[I]
    
    cell_text=[]
    cell_text= column_stack((g_Hz[I],abs_g_hann[I]))
    # print "Sze: " ,len(cell_text)
    print header[0][headerNum][:-8]
    print columns[0],columns[1]
    print cell_text[:]
    # for row in range(len(I)):
        # cell_text.append(
    #colors = plt.cm.BuPu(np.linspace(0, 0.5, len(columns)))
    # print len(colors)
    # print colors
    # print "len coloumns: ",len(columns)
    # print columns
    the_table = plt.table(cellText=cell_text[:][:]
    ,colLabels=columns,loc='upper center')
    #the_table.set_fontsize(20)
    
    
    
    #tight_layout()
    return()
    
    
    
    
    
def Main(filename):
    data = filename
    (deltaTime, g_x, g_y, g_z) = process_data(data)
    contTime=[]
    contTime.append(0)
    for i in  range(len(deltaTime)-1):
        contTime.append(contTime[i]+deltaTime[i+1])
    #print i,contTime
        #contTime[i+1]=
    # print contTime[0:10]
    # print"############################"
    # print contTime[-10:]
    sampleTime = mean(deltaTime)
    sampleRate= 1/sampleTime
    print"######################################"
    print"Samplerate: %f Hz"% sampleRate
    print"######################################"
    plotFFT(g_x,deltaTime,sampleTime,sampleRate,contTime,1)
    plotFFT(g_y,deltaTime,sampleTime,sampleRate,contTime,2)
    plotFFT(g_z,deltaTime,sampleTime,sampleRate,contTime,3)
    
    return()

# print sys.argv
if len(sys.argv)!=1:
    for arg in sys.argv:
        if arg!=sys.argv[0]:
            arg=arg.replace('\\','/')            
            datei=[]
            header=[]
            #b=True
            data=read_csvfile(arg)
            counter=0
            for line in data:
                #print (len(line))
                if counter!=0:
                    datei.append((float(line[0]),float(line[1]),float(line[2]),float(line[3])))
                else:
                    header.append((line[0],line[1],line[2],line[3]))
                counter+=1
            #print datei

#print datei
arg=arg.split('/')[-1]
# print header
print"######################################"
print "FFT calculation of file: ", arg
print"######################################"
print
print

# print arg
Main(datei)
show()
