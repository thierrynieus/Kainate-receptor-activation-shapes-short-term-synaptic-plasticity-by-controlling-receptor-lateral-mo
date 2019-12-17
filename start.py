from neuron import h
from neuron import gui
import numpy as np
import pylab as plt

soma       = h.Section() 
soma.nseg  = 1 
soma.diam  = 10 
soma.cm    = 1  

SynTrigger          =   h.SpikeGenerator2(soma(0.5))
SynTrigger.start    =   50
SynTrigger.time[0]  =   0
SynTrigger.time[1]  =   1e12
SynTrigger.end      =   1e12
ExtraTime=200


tvec=np.arange(6800)

record_time=h.Vector()
record_time.record(h._ref_t) 

record=h.Vector()

synType='Kainate'   #

if synType=='Kainate':
    syn=h.kainate(soma(0.5))
    record.record(syn._ref_Open) 

    factDES=0.1 # 0.2 #0.5 #0.1 #0.2
    fact_ko=0.9
    syn.kon=15
    syn.koff=2*fact_ko
    syn.k1off=1*fact_ko
    syn.b2=24
    syn.b3=24
    syn.b4=24
    syn.a2=0.8
    syn.a3=0.8
    syn.a4=0.8
    syn.delta1=1.25*factDES
    syn.delta2=2.5*factDES
    syn.delta3=5*factDES
    syn.delta4=10*factDES
    syn.gamma=0.0008

   
syn.Tmax=1
conn=h.NetCon(SynTrigger,syn,-20,0,1,sec=soma)

def update_stim(SynTrigger,npulse=100,ISI=10,PrePulse=0,FinalPulse=50):
    '''
    '''
    global tstop
    SynTrigger.time[0]=0 
    if PrePulse: 
        SynTrigger.time[1]=PrePulse
        K=2
    else:
        K=1
    for i in (K+np.arange(npulse)): SynTrigger.time[i]=ISI
    SynTrigger.time[i]=FinalPulse  
    SynTrigger.time[i+1]=1e12
    h.tstop=SynTrigger.start+PrePulse+npulse*ISI+FinalPulse+ExtraTime


