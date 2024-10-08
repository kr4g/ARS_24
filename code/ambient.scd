
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
	var projectPath = PathName.new(PathName.new(thisProcess.nowExecutingPath).parentPath).parentPath;
	var audioPath = projectPath ++ "buffers/audio/";

	s.bind{ ~fx = Synth.tail(nil, \verb); };

	~playBuffer.value(\playBuf1, audioPath ++ "FB1_L.wav", amp: amp1);
	~playBuffer.value(\playBuf1, audioPath ++ "FB1_R.wav", amp: amp1);
	~playBuffer.value(\playBuf1, audioPath ++ "FB1b_L.wav", amp: amp1);
	~playBuffer.value(\playBuf1, audioPath ++ "FB1b_R.wav", amp: amp1);

	~playBuffer.value(\playBuf2, audioPath ++ "FB2_L.wav", amp: amp2);
	~playBuffer.value(\playBuf2, audioPath ++ "FB2_R.wav", amp: amp2);
	~playBuffer.value(\playBuf2, audioPath ++ "FB2b_L.wav", amp: amp2);
	~playBuffer.value(\playBuf2, audioPath ++ "FB2b_R.wav", amp: amp2);

	Synth(\tumbler, [\amp, 0.2, \out, 5]);
});
)

~ambience.play;

// (
// OSCdef(\forwardAmp, { |msg|
// 	var ampVal;
// 	ampVal = msg[3];
// 	NetAddr("10.78.206.89", 9999).sendMsg("/ampEnv", ampVal);
// }, "/ampEnv").add;
// )
