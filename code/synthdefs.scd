(
SynthDef(\playBuf1, {
	var modulatedRate, sig, direction, chain, binSwapped, ampLFO, pitchRange, lag, feedback;
	lag = \lag.kr(5);
	direction = \direction.kr(1);
	modulatedRate = \rate.kr(1) * direction * LFNoise1.ar(\rateMod.kr(0.001, lag)).range(\rateModMin.kr(0.667, lag), \rateModMax.kr(1.167, lag));

	sig = PlayBuf.ar(1, \bufnum.kr(0), modulatedRate, startPos: \start.kr(0), doneAction: 2, loop: 1);

	ampLFO = SinOsc.ar(ExpRand(0.0667, 0.167), \phase.kr(1.5pi)).range(0, 1);
	sig = sig * ampLFO;

	chain = FFT(LocalBuf(2048), sig);
	binSwapped = PV_BinScramble(chain,
		wipe: \wipe.kr(0.9, lag),
		width: \width.kr(0.9, lag)
	);
	sig = IFFT(binSwapped);

	feedback = LocalIn.ar(1);
	pitchRange = LFNoise0.ar(LFNoise1.kr(\pitchMod.kr(0.2, lag)).range(0.0167, 0.67)).range(\pitchModMin.kr(0.833, lag), \pitchModMax.kr(1.167, lag));
	feedback = PitchShift.ar(sig,
		windowSize: 0.2,
		pitchRatio: pitchRange,
		pitchDispersion: ExpRand(0.01, 0.03),
		timeDispersion: ExpRand(0.01, 0.1)
	);

	// sig = FreqShift.ar(sig, freq: LFNoise1.kr(ExpRand(0.1, 0.167)).range(-350, 350));

	sig = sig + (feedback * 0.5);

	LocalOut.ar(sig);

	sig = LPF.ar(sig, SinOsc.kr(ExpRand(0.03, 0.17)).range(500, \maxLPF.kr(2000, lag)));
	sig = sig * EnvGen.kr(Env.asr(2, 1, 2), \gate.kr(1), doneAction: 2) * \amp.kr(0.2, lag);
	sig = PanAz.ar(5, sig, LFNoise1.kr(SinOsc.kr(ExpRand(0.067, 0.333)).range(0.5, 1.5)), width: 2, orientation: 0.5);
	sig = Limiter.ar(sig, \limitLevel.kr(0.8), \releaseTime.kr(0.01));
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\playBuf2, {
	var modulatedRate, sig, direction, feedback, comb, ampLFO, pitchRange, lag;
	lag = \lag.kr(5);
	direction = \direction.kr(1);
	modulatedRate = \rate.kr(1) * direction * LFNoise1.ar(\rateMod.kr(0.001, lag)).range(\rateModMin.kr(0.333, lag), \rateModMax.kr(1.333, lag));

	sig = PlayBuf.ar(1, \bufnum.kr(0), modulatedRate, startPos: \start.kr(0), doneAction: 2, loop: 1);

	ampLFO = SinOsc.ar(ExpRand(0.0667, 0.167), \phase.kr(1.5pi)).range(0, 1);
	sig = sig * ampLFO;

	feedback = LocalIn.ar(1);
	pitchRange = LFNoise1.ar(LFNoise0.kr(\pitchMod.kr(0.5, lag)).range(0.2, 0.7)).range(\pitchModMin.kr(0.333, lag), \pitchModMax.kr(1.667, lag));
	feedback = PitchShift.ar(feedback,
		windowSize: 0.2,
		pitchRatio: pitchRange,
		pitchDispersion: ExpRand(0.01, 0.03),
		timeDispersion: ExpRand(0.01, 0.1)
	);
	comb = CombN.ar((feedback + (sig * 0.5)).tanh, maxdelaytime: 0.9, delaytime: LFNoise0.kr(0.1).range(0.3,0.9), decaytime: 3);
	//
	feedback = LPF.ar(comb, LFNoise0.kr(ExpRand(0.1, 0.3)).range(900, \maxLPF.kr(2500)));

	LocalOut.ar(feedback * 0.5);

	sig = sig + feedback;
	sig = sig * EnvGen.kr(Env.asr(2, 1, 2), \gate.kr(1), doneAction: 2) * \amp.kr(0.2, lag) * -3.dbamp;
	sig = PanAz.ar(5, sig, LFNoise1.kr(SinOsc.kr(ExpRand(0.067, 0.333)).range(0.5, 1.5)), width: 2, orientation: 0.5);
	sig = Limiter.ar(sig, \limitLevel.kr(0.8), \releaseTime.kr(0.01));
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\plucks, {
	var sig, freq;
	// freq = \freq.kr(500, \freqLag.kr(0.1));
	freq = LFNoise1.kr(ExpRand(0.1,0.5) ! 2).range(500,1500);
	sig = Pluck.ar(WhiteNoise.ar(0.1), Impulse.kr(\impRate.kr(5, \impLag.kr(0.1))), freq.reciprocal, freq.reciprocal, decaytime: \decay.kr(0.6), coef: \coef.kr(0.5, \coefLag.kr(0.1)));
	sig = Mix.ar(sig, PitchShift.ar(sig, pitchRatio: 0.25));
	sig = sig * EnvGen.kr(Env.asr(0.1, 1, 2), \gate.kr(1), doneAction: 2) * \amp.kr(1);
	sig = PanAz.ar(5, sig, LFNoise1.kr(ExpRand(0.7, 1.2)), width: 2);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\boing, {
	var sig, freq;
	freq = XLine.kr(ExpRand(400,500) ! 2, ExpRand(1000,1500) ! 2, ExpRand(0.1,0.167)) * LFNoise1.kr(XLine.kr(5,21,1)).bipolar(1).midiratio;
	sig = Pluck.ar(WhiteNoise.ar(0.1), Impulse.kr(0), freq.reciprocal, freq.reciprocal, decaytime: \decay.kr(10), coef: XLine.kr(0.6,0.03,0.08));
	sig = Mix.ar(sig, PitchShift.ar(sig, pitchRatio: 0.5));
	sig = sig * Env.perc(releaseTime: \duration.kr(10)).kr(Done.freeSelf) * \amp.kr(1);
	sig = CombN.ar(Mix.ar(sig, PitchShift.ar(sig, pitchRatio: 0.5)), 2, ExpRand(0.0667, 0.167), 5);
	// sig = Mix.ar(sig, CombN.ar(PitchShift.ar(sig, pitchRatio: 0.25), 2, ExpRand(0.07,0.4), 5));
	sig = PanAz.ar(5, sig, LFNoise1.kr(ExpRand(1.3, 2.9)), width: 2);
	Out.ar(\out.kr(0), sig * -3.dbamp);
}).add;

// SynthDef(\heat, {
// 	var sig;
// 	sig = VarSaw.ar(50 /** [0.33.midiratio, 0.67.midiratio]*/, width: LFNoise1.ar(ExpRand(1.1, 2.6)).range(0.15,0.75));
// 	sig = HPF.ar(sig, \hpfFreq.kr(1000, \hpfLag.kr(0.0)));
// 	sig = sig * LFNoise1.ar(ExpRand(1.3, 2.6)).range(0,1) * \amp.kr(1) /** -3.dbamp*/;
// 	// sig = JPverb.ar(sig, t60: 2, size: 2, high: 0.67);
// 	sig = sig * EnvGen.kr(Env.asr(5, 1, 2), \gate.kr(1), doneAction: 2);
// 	sig = PanAz.ar(5, sig, LFNoise1.kr(ExpRand(0.3, 0.9)), width: 2);
// 	Out.ar(\out.kr(0), sig);
// }).add;

SynthDef(\heat, {
	var sig, detunes, panPositions;

	detunes = [0.33.midiratio, 0.67.midiratio];
	panPositions = detunes.collect { LFNoise1.kr(ExpRand(0.3, 0.9)) };

	sig = VarSaw.ar(50 * detunes, width: LFNoise1.ar(ExpRand(1.1, 2.6)).range(0.15, 0.75));
	sig = HPF.ar(sig, \hpfFreq.kr(1000, \hpfLag.kr(0.0)));
	sig = sig * LFNoise1.ar(ExpRand(1.3, 2.6)).range(0, 1) * \amp.kr(1);
	sig = sig * EnvGen.kr(Env.asr(5, 1, 2), \gate.kr(1), doneAction: 2);
	sig = Mix(PanAz.ar(5, sig, panPositions, width: 2));
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\rumbler, {
    var sig, freqs;
    freqs = Array.fill(10, { ExpRand(30, 60) });
    sig = Mix.fill(freqs.size, { |i| SinOsc.ar(freqs[i]) });
    sig = sig * LFNoise1.ar(ExpRand(1.3, 2.6)).range(0, 1) * \amp.kr(1) * -48.dbamp;
    sig = sig * EnvGen.kr(Env.asr(5, 1, 2), \gate.kr(1), doneAction: 2);
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\tumbler, {
    var sig, freqs;
    freqs = Array.fill(10, { ExpRand(30, 60) });
    sig = Mix.fill(freqs.size, { |i| SinOsc.ar(freqs[i]) });
	sig = sig * LFNoise1.ar(SinOsc.kr(ExpRand(0.167, 0.333)).range(0.067, 0.667)).range(0, 1) * \amp.kr(1) * -48.dbamp;
    sig = sig * EnvGen.kr(Env.asr(5, 1, 2), \gate.kr(1), doneAction: 2);
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\verb, {
	var sig;
	sig = In.ar(0, 1);
	sig = FreeVerb.ar(sig, \mix.kr(0.8), \room.kr(0.93), \damp.kr(0.01));
	sig = Limiter.ar(sig, 0.8, 0.01);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\hall, {
	var sig;
	sig = In.ar(0, 1);
	sig = JPverb.ar(sig, size: 2);
	sig = SplayAz.ar(5, sig, spread: 5, width: 5);
	sig = Limiter.ar(sig, 0.8, 0.01);
	Out.ar(\out.kr(0), sig);
}).add;
)