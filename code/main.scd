ServerOptions.devices;
(
s = Server.local;
s.options.outDevice_(
	// "MacBook Pro Speakers"
	// "External Headphones"
	// "Scarlett 4i4 USB"
	// "Klipsch One II"
	"UMC1820"
);
s.options.inDevice_("Built-in Microph");
s.options.numOutputBusChannels_(6);
s.options.numInputBusChannels_(0);
s.options.sampleRate_(48000);
s.options.memSize_(2.pow(20));
s.newBusAllocators;
// ServerBoot.removeAll;
// ServerTree.removeAll;
// ServerQuit.removeAll;
s.reboot;
)
Synth(\default)

thisProcess.openUDPPort(1010);
thisProcess.openPorts;

(
SynthDef(\pinkTest, {
	var sig;
	sig = PinkNoise.ar(0.05);
	sig = sig * Env.linen(sustainTime: \duration.kr(1), releaseTime: 0.0).kr(Done.freeSelf);
	Out.ar(\out.kr(0), sig);
}).add;
)

(
var chans = 6;
var dur = 0.5;
Routine({
	inf.do { |i|
		Synth(\pinkTest, [\duration, dur, \out, i % chans]);
		dur.wait;
	}
}).play;
)
