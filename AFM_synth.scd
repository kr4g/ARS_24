// 0. Get output devices
ServerOptions.devices;

// 1. Init Server
(
Server.killAll;
Buffer.freeAll;
s = Server.local;
s.options.outDevice_(
	// "MacBook Pro Speakers"
	// "External Headphones"
	"ZoomAudioD"
	// "Scarlett 4i4 USB"
	// "MME : Out 1-24 (MOTU Pro Audio)"
);
s.options.inDevice_("Built-in Microph");
s.options.numInputBusChannels_(0);
s.options.numOutputBusChannels_(2);
s.options.sampleRate_(48000);
s.options.memSize_(2.pow(20));
s.reboot;
)

// 2. Load buffers
(
var projectPath = PathName.new(thisProcess.nowExecutingPath).parentPath;
var id = "sr" ++ 166;

~afm = [];
b = Buffer.read(server: s, path: projectPath ++ "Buffers/c34" ++ id ++ "_fdc.wav");
b.loadToFloatArray(action: { |array|
	b.numChannels.do { |i|
		var channelData = Array.fill(b.numFrames, { |j| array[j * b.numChannels + i] });
		channelData = channelData.linlin(channelData.minItem, channelData.maxItem, 0.0, 1.0);
		~afm = ~afm.add(channelData);
	};
});

~afm_dx = [];
c = Buffer.read(server: s, path: projectPath ++ "Buffers/c34" ++ id ++ "_fdc_dx.wav");
c.loadToFloatArray(action: { |array|
	c.numChannels.do { |i|
		var channelData = Array.fill(b.numFrames, { |j| array[j * c.numChannels + i] });
		channelData = channelData.linlin(channelData.minItem, channelData.maxItem, 0.0, 1.0);
		~afm_dx = ~afm_dx.add(channelData);
	};
});
)

~afm.plot(bounds: 800);
~afm_dx.plot(bounds: 800);

Buffer.freeAll;

(
// var n = ~afm[0].size;
var n = 1000;
var chans = 2;

SynthDef(\imp, {
	var sig, fundFreq, fundFreqEnv, freqLvls, fltFreqLvls, fltFreqEnv, duration;
	duration = \dur.kr(1);
	fundFreq = \freq.kr(880);
	freqLvls = \freqLvls.kr([0] ++ (n-2).collect{ exprand(3,30) } ++ [0]);
	fundFreqEnv = Env(levels: freqLvls, times: duration/n, curve: \sine).ar;
	sig = Pluck.ar(WhiteNoise.ar(0.5), Impulse.ar(fundFreqEnv * [1.0,1.5]), fundFreq.reciprocal, fundFreq.reciprocal, decaytime: 1.0, coef: [0.75, 0.5], mul: 9.dbamp);
	fltFreqLvls = \fltFreqLvls.kr(n.collect{ exprand(4400,10000) });
	fltFreqEnv = Env(levels: fltFreqLvls, times: duration/n, curve: \sine).ar;
	sig = BPF.ar(sig, freq: fltFreqEnv, rq: 0.1, mul: 12.dbamp);
	sig = sig.sum;
	sig = sig.tanh;
	sig = sig * Env.linen(0.01, duration, 0.01, curve: -4).kr(Done.freeSelf);
	sig = Splay.ar(sig);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\dialup, {
	var snd, duration;
	duration = \duration.kr(0.3);
	snd = SinOsc.ar(TIRand.ar(0, 5, Impulse.ar(100 ! 3)).linexp(0, 5, 200, 16050));
	snd = Splay.ar(snd);
	snd = LPF.ar(snd, XLine.ar(8000, 100, duration));
	snd = snd + (RHPF.ar(Hasher.ar(Sweep.ar), 1520, 0.3) * Env.linen(0, 0.02, 0).ar * (1 + Env.perc(0, 0.01).ar) * -2.dbamp);
	snd = snd * Env.linen(0, duration, 0.001, curve: -4).kr(Done.freeSelf);
	snd = snd * \amp.kr(-7.dbamp);
	Out.ar(\out.kr(0), snd);
}).add;

SynthDef(\reverb, {
	var inSig, verb;
	inSig = In.ar(\in.kr(0), chans);
	verb = FreeVerb.ar(inSig, mix: 0.65, room: 0.9, damp: 0.15);
	Out.ar(\out.kr(0), verb);
}).add;
)


(
var i = 2;
var dur = 7;
var peakIdx = ~afm[i].minIndex;
var timeStep = dur/1000;
var peakTime = timeStep*(peakIdx);
var frqLvl = ~afm[i].linexp(0.0,1.0,50.0,3.0);
var fltFrqLvl = ~afm_dx[i].linexp(0.0,1.0,90.0,5000.0);
s.bind {~fx = Synth.tail(nil, \reverb); };
Routine({
	s.bind {
		Synth(\imp, [
			\freq, 1760,
			\dur, dur,
			\freqLvls, frqLvl,
			\fltFreqLvls, fltFrqLvl,
		]);
	};
	peakTime.wait;
	s.bind {
		Synth(\dialup, [\amp, -18.dbamp]);
		"boop!".postln;
	};
	((dur - peakTime)*2).wait;
	"done".postln;
	s.bind { ~fx.free; };
}).play;
)
