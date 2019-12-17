'''
numpul=50;SynTrigger.start=50+numpul*10;update_stim(SynTrigger,npulse=100-numpul);h.run();plt.plot(record_time.x,record.x,'r-',lw=1)
'''

from uti import NicePlot

plt.ioff()

PrePulse=5000    

w=0.68

fpathPlotSave='' 

ttest=1090+PrePulse  # time of test stimulus 
np_Start=1  
np_End=100
Nexchange=float(np_End-np_Start+1)
SavePlotFormat='pdf'
plotIt=False

# immobilized response 
tstart=50

SynTrigger.start=tstart
update_stim(SynTrigger,npulse=100,PrePulse=PrePulse)
h.run()
t=np.array(record_time.x)
OrefWhole=np.array(record.x)

# mobile response 
curr_list=[]
for numpul in np.arange(np_Start,np_End):
    SynTrigger.start=tstart+numpul*10+PrePulse   
    update_stim(SynTrigger,npulse=100-numpul,PrePulse=0)
    h.run()

    if plotIt:
        # plot 
        plt.figure()
        plt.plot(t,OrefWhole,'k-',lw=1,label='immobilized')
        plt.plot(t,np.array(record.x),'r-',lw=1,label='mobilized')
        plt.legend()
        plt.xlabel('time (ms)',fontsize=14)
        plt.ylabel('Cumulative open states',fontsize=14)
        plt.savefig('%s%d.%s'%(fpathPlotSave,numpul,SavePlotFormat))
        
        # zoom - hard coded 
        plt.xlim(1200+PrePulse-200,1400+PrePulse-200)
        plt.ylim(0,0.1)
        plt.xlabel('time (ms)',fontsize=14)
        plt.ylabel('Cumulative open states',fontsize=14)
        plt.savefig('%s%d_zoom.%s'%(fpathPlotSave,numpul,SavePlotFormat))
        plt.close()    

    # update 
    idx=np.where(t<SynTrigger.start)[0]
    v=np.array(record.x)
    v[idx]=np.copy(OrefWhole[idx])
    curr_list.append(v)

curr_mat=np.array(curr_list)
mTOT=curr_mat.mean(axis=0)
y_mobile=w*OrefWhole+(1-w)*mTOT

N=100
N_mobile=(1-w)*N
N_immobile=w*N
n_mobile=curr_mat.shape[0]   
n_immobile=int(round(n_mobile*w/(1-w)))
for k in range(n_immobile): curr_list.append(OrefWhole)

plt.plot(t,OrefWhole,'k-',label='rec immobilized',lw=2)
 
curr_mat=np.array(curr_list)
mTOT2=curr_mat.mean(axis=0)
sTOT2=curr_mat.std(axis=0)/np.sqrt(N)
NicePlot(t,mTOT2,sTOT2,OverSample=1,colbk='r',colbound='r',colLine='r',thelabel='mean mobile',alpha=0.2)
 
plt.ion()
plt.show()
 
