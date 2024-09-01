
(
~bufferSynths = Dictionary.new;

~playBuffer = {
	|synthName, path, rate = 1.0, amp = 0.2, chan=0|
	var buffer, synth, start, direction;

	{
		buffer = Buffer.read(s, path);
		s.sync;

		start = rrand(0, buffer.numFrames);
		direction = [-1, 1].choose;

		synth = Synth(synthName, [
			\bufnum, buffer.bufnum,
			\rate, rate,
			\direction, direction,
			\start, start,
			\amp, amp,
			\out, chan
		]);

		~bufferSynths[path] = synth;
	}.fork;
};
)

// s.record("/Users/ryanmillett/ARS_24/ambience3.wav", numChannels:2, duration: 60*10);
(
Routine({
	var amp = -4.dbamp;

	s.bind{ ~fx = Synth.tail(nil, \verb); };

	~playBuffer.value(\playBuf1, "/Users/ryanmillett/ARS_24/FB1_L.wav", amp: amp, chan: 0);
	// rrand(1, 5).wait();
	~playBuffer.value(\playBuf1, "/Users/ryanmillett/ARS_24/FB1_R.wav", amp: amp, chan: 1);
	// rrand(1, 5).wait();
	~playBuffer.value(\playBuf2, "/Users/ryanmillett/ARS_24/FB2_L.wav", amp: amp, chan: 2);
	// rrand(1, 5).wait();
	~playBuffer.value(\playBuf2, "/Users/ryanmillett/ARS_24/FB2_R.wav", amp: amp, chan: 3);
	// rrand(1, 5).wait();
}).play;
)

~fx.set(\mix, 0.3, \room, 0.5);


// TESTING
(
Routine({
	loop {
		~bufferSynths.do { |synth|
			synth.set(
				\rateMod, exprand(0.1, 3.0),
				\direction, [-1,1].choose,
				\pitchMod, exprand(0.01, 3.5),
				\pitchModMin, rrand(0.5, 0.9),
				\pitchModMax, rrand(1.1, 1.7),
				\maxLPF, rrand(1000, 5000),
				\amp, rrand(-12.dbamp, -4.dbamp)
			);
		};
		rrand(5, 15).wait;
	};
}).play;
)


