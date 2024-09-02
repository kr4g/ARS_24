(
var bufferPath = PathName.new(PathName.new(thisProcess.nowExecutingPath).parentPath ++ "buffers/calc_oscil_norm.wav");
var buffer = Buffer.read(s, bufferPath.fullPath);
var ar = Array.new;
var currentPos = 0;
var routine;

Routine({
	s.sync;
	buffer.loadToFloatArray(action: { |array|
		buffer.numChannels.do { |i|
			var channelData = array.clump(buffer.numChannels).collect({ |chanVals| chanVals[i] });
			ar = ar.add(channelData);
		};
		s.sync;
		~bufferData = ar;
	});
}).play;

~scanBuffer = { |targetPos = 0.5, scanRate = 100|
	if (routine.notNil and: { routine.isPlaying }) {
		routine.stop;
	};

	routine = Routine({
		var startIndex, endIndex, increment, scanInterval;

		startIndex = (currentPos * (~bufferData[0].size - 1)).asInteger;
		endIndex = (targetPos * (~bufferData[0].size - 1)).asInteger;
		increment = if(startIndex < endIndex, { 1 }, { -1 });
		scanInterval = scanRate / 1000;

		while({
			(increment > 0 and: { startIndex <= endIndex }) or:
			(increment < 0 and: { startIndex >= endIndex });
		}, {
			// ("Position: " ++ (startIndex / (~bufferData[0].size - 1)).asFloat ++
			// 	" Channel 1: " ++ ~bufferData[0][startIndex] ++
			// " Channel 2: " ++ ~bufferData[1][startIndex]).postln;
			~bufferSynths[\all].do { |synth|
				synth.set(
					\lag, scanInterval,
					\wipe, ~bufferData[0][startIndex],
					\width, ~bufferData[1][startIndex],
					\rateMod, ~bufferData[0][startIndex].linlin(0, 1, 0.01, 3.0),
					\direction, increment,
					\pitchMod, ~bufferData[1][startIndex].linexp(0, 1, 0.07, 5.7),
					\pitchModMin, ~bufferData[0][startIndex].linexp(0, 1, 0.5, 0.96),
					\pitchModMax, ~bufferData[1][startIndex].linlin(0, 1, 1.0, 1.83),
					\rateModMin, ~bufferData[0][startIndex].linlin(0, 1, 0.5, 0.96),
					\rateModMax, ~bufferData[1][startIndex].linlin(0, 1, 1.0, 1.67),
				);
			};

			~bufferSynths[\playBuf1].do { |synth|
				synth.set(\amp, ~bufferData[1][startIndex].linlin(0, 1, -36.dbamp, -4.dbamp));
				// synth.set(\amp, currentPos.linlin(0, 1, -28.dbamp, -4.dbamp));
			};

			~bufferSynths[\playBuf2].do { |synth|
				synth.set(\amp, ~bufferData[1][startIndex].linlin(0, 1, -6.dbamp, -42.dbamp));
				// synth.set(\amp, currentPos.linlin(0, 1, -36.dbamp, -6.dbamp));
			};

			startIndex = startIndex + increment;

			if ((increment > 0 and: { startIndex >= endIndex }) or:
				(increment < 0 and: { startIndex <= endIndex })) {
				currentPos = startIndex / (~bufferData[0].size - 1);
				("Target position reached: " ++ currentPos).postln;
				routine.stop;
			};
			scanInterval.wait;
		});
	});

	routine.play;
};
)

(
~modAmb = Routine({
	loop {
		~scanBuffer.value(rrand(0.0,1), rrand(10,100));
		rrand(10.0,45).wait;
	};
});
)

~modAmb.play;
