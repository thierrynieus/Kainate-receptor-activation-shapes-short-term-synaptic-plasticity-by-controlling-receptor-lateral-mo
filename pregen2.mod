: $Id: pregen.mod,v 1.3 2000/05/16 11:16:56 hines Exp $
: comments at end

NEURON	{ 
  POINT_PROCESS SpikeGenerator2
  RANGE y
  RANGE start, end, on
  RANGE time
}

PARAMETER {
	:burst_len	= 40		: burst length (# spikes)
	start		= 100 (ms)	: start of first interburst interval
	end		= 1e10 (ms)	: time to stop bursting
}

ASSIGNED {
	y
	event (ms)
	:toff (ms)
	on

	time[200] (ms)	
	indice
}

:PROCEDURE inits(){
:}

INITIAL {	
	:init()
	indice=0
	on = 1
	:toff = 1e9
	y = -90
	event = start 
	event_time()
	while (on == 1 && event < 0) {
		event_time()
	}
	if (on == 1) {
		net_send(event, 1)
	}
}	

PROCEDURE event_time() {
	event=event+time[indice] 
	indice=indice+1
	if (event > end) {
		on = 0
	}
}

NET_RECEIVE (w) {
    :printf("Pregen receive t=%g flag=%g on=%g \n", t, flag, on) 
	if (flag == 1 && on == 1) {
		y = 20
		net_event(t)
		event_time()
		net_send(event - t, 1)
		net_send(.1, 2)
	}
	if (flag == 2) {
		y = -90
	}
}


