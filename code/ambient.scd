
(
~bufferSynths = Dictionary.new;

~playBuffer = {
	|synthName, path, rate = 1.0, amp = 0.2|
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
			// \out, chan
		]);

		~bufferSynths[path] = synth;

		if (~bufferSynths[synthName].isNil) {
			~bufferSynths[synthName] = Dictionary.new;
		};

		~bufferSynths[synthName][path] = synth;

		if (~bufferSynths[\all].isNil) {
			~bufferSynths[\all] = Dictionary.new;
		};

		~bufferSynths[\all][path] = synth;

	}.fork;
};
)

(
~ambience = Routine({
	var amp1 = -20.dbamp;
	var amp2 = -24.dbamp;

	s.bind{ ~fx = Synth.tail(nil, \verb); };
	// s.bind{ ~fx = Synth.tail(nil, \hall); };

	~playBuffer.value(\playBuf1, "/Users/ryanmillett/ARS_24/FB1_L.wav", amp: amp1);
	~playBuffer.value(\playBuf1, "/Users/ryanmillett/ARS_24/FB1_R.wav", amp: amp1);
	~playBuffer.value(\playBuf1, "/Users/ryanmillett/ARS_24/FB1b_L.wav", amp: amp1);
	~playBuffer.value(\playBuf1, "/Users/ryanmillett/ARS_24/FB1b_R.wav", amp: amp1);

	~playBuffer.value(\playBuf2, "/Users/ryanmillett/ARS_24/FB2_L.wav", amp: amp2);
	~playBuffer.value(\playBuf2, "/Users/ryanmillett/ARS_24/FB2_R.wav", amp: amp2);
	~playBuffer.value(\playBuf2, "/Users/ryanmillett/ARS_24/FB2b_L.wav", amp: amp2);
	~playBuffer.value(\playBuf2, "/Users/ryanmillett/ARS_24/FB2b_R.wav", amp: amp2);

	Synth(\tumbler, [\amp, 0.2, \out, 5]);
});
)

~ambience.play;

// TESTING
// (
// Routine({
// 	loop {
// 		var time = rrand(5, 15);
// 		~bufferSynths.do { |synth|
// 			synth.set(
// 				\lag, time,
// 				\wipe, rrand(0.1, 0.9),
// 				\width, rrand(0.1, 0.9),
// 				\rateMod, exprand(0.001, 1.0),
// 				\direction, [-1,1].choose,
// 				\pitchMod, exprand(0.07, 5.7),
// 				\pitchModMin, rrand(0.5, 0.96),
// 				\pitchModMax, rrand(1.0, 1.83),
// 				\rateModMin, rrand(0.5, 0.96),
// 				\rateModMax, rrand(1.0, 1.67),
// 				\maxLPF, rrand(1000, 5000),
// 				\amp, rrand(-36.dbamp, -8.dbamp)
// 			);
// 			exprand(1, 5).wait;
// 		};
// 		time.wait;
// 	};
// }).play;
// )
