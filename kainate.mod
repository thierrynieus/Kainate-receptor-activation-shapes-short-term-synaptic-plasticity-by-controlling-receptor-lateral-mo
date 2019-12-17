TITLE Kainate 

COMMENT
    Barberis, A., Sachidhanandam, S., and Mulle, C. (2008). GluR6/KA2 Kainate Receptors Mediate Slow-Deactivating Currents. Journal of Neuroscience 28,     
    6402-6406. doi:10.1523/JNEUROSCI.1204-08.2008.
ENDCOMMENT



NEURON {
	POINT_PROCESS kainate
	 
	NONSPECIFIC_CURRENT i
	RANGE g,Open
	
	RANGE gmax,Cdur,Tmax,Erev,onSET		 

    RANGE kon,koff,k1off,b2,b3,b4,a2,a3,a4,delta1,delta2,delta3,delta4,gamma

    RANGE R0,R1,R2,R3,R4,O2,O3,O4,D1,D2,D3,D4

}

UNITS {
	(nA) 	= (nanoamp)
	(mV) 	= (millivolt)
	(umho)  = (micromho)
	(mM) 	= (milli/liter)
	(pS) 	= (picosiemens)
	PI   	= (pi)(1)
}

PARAMETER {

	gmax		= 700	    (pS)	
	Cdur		= 0.3		(ms)	

    kon         =   15      (/ms/mM) 
    koff        =   0.8     (/ms) 
    k1off       =   0.16    (/ms) 
    b2          =   32      (/ms) 
    b3          =   32      (/ms) 
    b4          =   10      (/ms) 

    a2          =   0.325   (/ms) 
    a3          =   0.8     (/ms) 
    a4          =   3.1     (/ms) 

    delta1      =   0.05    (/ms) 
    delta2      =   0.25    (/ms) 
    delta3      =   1.25    (/ms) 
    delta4      =   0.8     (/ms) 
    
    gamma       =   0.0005  (/ms) 
		
	Erev		=   -65		(mV)	
	Tmax		=   1  		(mM)	: pulse amplitude, because here receptors are activated by diffusion the default is zero
	onSET		=   1

}


ASSIGNED {
	v		    (mV)	: postsynaptic voltage
	i 		    (nA)	: current = g*(v - Erev)
	g 		    (pS)	: conductance	
	Open
	T		    (mM)		 
	tspike[500]	(ms)	: will be initialized by the pointprocess
    num

    kon2        (/ms) 
    kon3        (/ms) 
    kon4        (/ms) 

    koff2       (/ms) 
    koff3       (/ms) 
    koff4       (/ms) 
    k1off2      (/ms) 
    k1off3      (/ms) 
    k1off4      (/ms) 
}

STATE {	
    R0
    R1
    R2
    R3
    R4
    O2
    O3
    O4
    D1
    D2
    D3
    D4
}

INITIAL {
	: kinetic states
    R0 = 1
    R1 = 0
    R2 = 0
    R3 = 0
    R4 = 0
    O2 = 0
    O3 = 0
    O4 = 0
    D1 = 0
    D2 = 0
    D3 = 0
    D4 = 0

    kon2=2*kon
    kon3=3*kon
    kon4=4*kon    

    koff2=2*koff
    koff3=3*koff
    koff4=4*koff    

    k1off2=2*k1off
    k1off3=3*k1off
    k1off4=4*k1off    
	  
	T	=	0 	(mM)	 
	num	=	0
	tspike[0] = 1e12 (ms)

	onSET	= 1
	
}

BREAKPOINT {
	SOLVE kstates METHOD sparse
	Open = O2 + O3 + O4 
	g = gmax * Open
	i = (1e-6) * g * ( v - Erev )
}

KINETIC kstates {
    
	: second row
	~	R0  	<-> 	R1	    (kon4*T,koff)
	~	R1  	<-> 	R2	    (kon3*T,koff2)
	~	R2  	<-> 	R3	    (kon2*T,koff3)
	~	R3  	<-> 	R4	    (kon*T,koff4)

	: third row
	~	D1  	<-> 	D2	    (kon3*T,k1off2)
	~	D2  	<-> 	D3	    (kon2*T,k1off3)
	~	D3  	<-> 	D4	    (kon*T,k1off4)
    
	: first <=> second row
	~ 	O2  	<-> 	R2	    (a2,b2)
	~ 	O3  	<-> 	R3	    (a3,b3) 
	~ 	O4  	<-> 	R4	    (a4,b4)

	: second <=> third row
	~	R1	    <->	    D1	    (delta1,gamma)
	~	R2	    <->	    D2	    (delta2,gamma)
	~	R3	    <->	    D3	    (delta3,gamma)
	~	R4	    <->	    D4	    (delta4,gamma)
	
	CONSERVE R0 + R1 + R2 + R3 + R4 + O2 + O3 + O4 + D1 + D2 + D3 + D4 = 1
}


NET_RECEIVE(weight,on, nspike,t0 (ms)) {
	INITIAL { nspike = 1 num=0 }
	if(onSET){
		: used to reset properly the model to the initial condition (on=0) in case the previous run did not (e.g. after a long pulse)
		on=0 
		onSET=0
	}
	if (flag == 0) { 
		nspike = nspike + 1
		if (!on) {
			t0 = t	
			on = 1							
			T=Tmax					 
			tspike[num]=t
			num=num+1
		}
		net_send(Cdur, nspike)		 
	}
	if (flag == nspike) { 
		T = 0
		on = 0
	}
}
