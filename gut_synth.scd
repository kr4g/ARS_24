s.boot;

(
var buffPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "tst2.wav";

~buf = Buffer.read(s, buffPath);

SynthDef(\scramble, {
	var sig, chain, size=2048;
	sig = PlayBuf.ar(2, \buf.kr(0), BufRateScale.ir(\buf.kr(0)), loop: 1);
	chain = FFT(LocalBuf(size), sig);
	chain = PV_BinScramble(chain, \wipe.kr(0), \width.kr(0), \trig.kr(0));
	sig = IFFT(chain) * \amp.kr(0.5)!2;
	sig = sig * \amp.kr(0.5);
	Out.ar(\out.kr(0), sig);
}).add;
)

x = Synth(\scramble, [\buf, ~buf, \amp, 0.9]);
x.set(\wipe, 0.75, \width, 0.75, \trig, 1);
