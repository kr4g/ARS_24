// 0. Init Server
(
Server.killAll;
Buffer.freeAll;
s = Server.local;
// ServerOptions.devices;
s.options.outDevice_(
	// "MacBook Pro Speakers"
	"External Headphones"
	// "ZoomAudioD"
	// "Scarlett 4i4 USB"
	// "MME : Out 1-24 (MOTU Pro Audio)"
);
s.options.inDevice_("Built-in Microph");
s.options.numOutputBusChannels_(2);
s.options.numInputBusChannels_(0);
s.options.sampleRate_(48000);
s.options.memSize_(2.pow(20));
s.reboot;
)

(
var id = 185;
~amps = [];
b = Buffer.read(server: s, path: "/Users/ryanmillett/ARS_24/Buffers/c34sr" ++ id.asString ++ "_fdc.wav");
b.loadToFloatArray(action: { arg array; ~amps = array;});
// b.free;

/*~derivs = [];
c = Buffer.read(server: s, path: "/Users/ryanmillett/ARS_24/Buffers/c34st" ++ id.asString ++ "_fdc.deriv_gauss_1.wav");
c.loadToFloatArray(action: { |array|
var indices = (0..1000-1);
~derivs = ~derivs.add(indices.collect { |n| array[n].linlin(-1.0,1.0,55.0,880.0) });
// ~derivs = array;
});*/
)

~amps = ~amps.linlin(-1.0,1.0,0.0,1.0);
~amps.plot();

Buffer.freeAll;

~amps[0].size;
~derivs[0].size;

Env.new(levels: ~amps, times: 0.01, curve: 'sine').plot(size: 10000);
Env.new(levels: ~derivs[0], times: 1/1000).plot(size: 1000);
{~amps[0]}.plot();

(
var n = 1000;
var chans = 2;
SynthDef(\Envtest, {
	var sig, env, aenv, fenv;
	aenv = \envA.kr((1..999));
	fenv = Env.new(levels: \envF.kr((1..999)), times: 1/n, curve: \sine).kr(Done.freeSelf);
	sig = {LFSaw.ar(freq: 55)}!chans;
	env = Env.new(levels: aenv, times: 1/n, curve: \sine).kr(Done.freeSelf);
	sig = BPF.ar(sig, freq: fenv, rq: 0.1, mul: 8.dbamp);
	sig = sig * env;
	sig = Splay.ar(sig);
	Out.ar(\out.kr(0), sig);
}).add;
)

(
s.bind {Synth(\Envtest, [\envA, ~amps, \envF, ~amps.linlin(0.0,1.0,55.0,880.0*2)]);};
)

(
var n = 100;
5.do {
	// Env.new(levels: n.collect{rrand(-1.0,1.0)}, times: (n-1).collect{exprand(0.01,0.5)}, curve: \sine).plot();
	Env.new(levels: n.collect{rrand(-1.0, 1.0)}, times: 0.1, curve: \sine).plot();
};
)

