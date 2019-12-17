import pylab as plt
import numpy as np
from scipy.interpolate import spline

def NicePlot(x,y,yerr,Nstd=1,OverSample=10,colbk='g',colbound='k',colLine='w',thelabel='',alpha=0.4):
    '''
        NicePlot: generates a plot with colored and splined error bands
        x,y,yerr:                       data 
        OverSample:                     oversampling factor used to build splines
        Nstd:                           number of std to consider
        colbk,colbound,colLine:         colors
        thelabel:                       label for the data
    '''
    time=x
    yMED=y
    ySUP=y+Nstd*yerr
    yINF=y-Nstd*yerr

    NumP=OverSample*len(time)

    tI=time[0]
    tS=time[-1]
    
    if OverSample>1:    
        time_new=np.linspace(tI,tS,NumP)
        ySUP_new = spline(time,ySUP,time_new)
        yINF_new = spline(time,yINF,time_new)
        yMED_new = spline(time,yMED,time_new)
    else:
        time_new = time 
        ySUP_new = ySUP
        yINF_new = yINF
        yMED_new = yMED
        
    plt.hold(1)
    plt.plot(time_new,ySUP_new,'%s-'%(colbound))
    plt.plot(time_new,yINF_new,'%s-'%(colbound))     
    plt.fill_between(time_new, yINF_new, ySUP_new,color='%s'%(colbk),alpha=alpha)
    plt.plot(time_new,yMED_new,'%s-'%(colLine),linewidth=2,label=thelabel)
