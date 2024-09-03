(
// var bufferPath = PathName.new(PathName.new(thisProcess.nowExecutingPath).parentPath ++ "buffers/calc_oscil_norm.wav");

var currentPath = PathName.new(thisProcess.nowExecutingPath).pathOnly;
var parentPath = PathName.new(currentPath).parentPath;
var bufferPath = PathName.new(parentPath ++ "buffers/calc_oscil_norm.wav");

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
	// "TEST".postln;
	routine = Routine({
		var startIndex, endIndex, increment, scanInterval, avg, mult;

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

			NetAddr("10.78.206.89", 9999).sendMsg("/immune", ~bufferData[0][startIndex]);
			NetAddr("127.0.0.1", 6000).sendMsg("/immune", ~bufferData[0][startIndex]);

			avg = 0.5*(~bufferData[0][startIndex] + ~bufferData[1][startIndex]);
			mult = ~bufferData[0][startIndex] * ~bufferData[1][startIndex];

			~bufferSynths[\all].do { |synth|
				synth.set(
					\lag, scanInterval,
					\wipe, rrand(0.0,~bufferData[0][startIndex].pow(0.5)),
					\width, rrand(0.0,~bufferData[0][startIndex]).pow(0.5),
					\rateMod, ~bufferData[0][startIndex].linlin(0, 1, 0.01, 3.0),
					\direction, increment,
					\pitchMod, ~bufferData[0][startIndex].linexp(0, 1, 0.07, 5.7),
					\pitchModMin, ~bufferData[0][startIndex].linexp(0, 1, 0.5, 0.96),
					\pitchModMax, ~bufferData[0][startIndex].linlin(0, 1, 1.0, 1.83),
					\rateModMin, ~bufferData[0][startIndex].linlin(0, 1, 0.5, 0.96),
					\rateModMax, ~bufferData[0][startIndex].pow(0.5).linlin(0, 1, 1.0, 1.67),
				);
			};

			// ~bufferSynths[\playBuf1].do { |synth|
			// 	// synth.set(\amp, ~bufferData[0][startIndex].linlin(0, 1, -40.dbamp, -6.dbamp));
			// 	synth.set(\amp, (startIndex / (~bufferData[0].size - 1)).linlin(0, 1, -31.dbamp, -4.dbamp));
			// };
			//
			// ~bufferSynths[\playBuf2].do { |synth|
			// 	// synth.set(\amp, ~bufferData[0][startIndex].linlin(0, 1, -4.dbamp, -31.dbamp));
			// 	synth.set(\amp, (startIndex / (~bufferData[0].size - 1)).linlin(0, 1, -4.dbamp, -31.dbamp));
			// };

			startIndex = startIndex + increment;

			if ((increment > 0 and: { startIndex >= endIndex }) or:
				(increment < 0 and: { startIndex <= endIndex })) {
				currentPos = startIndex / (~bufferData[0].size - 1);
				("Target position reached. Val: " ++ ~bufferData[0][startIndex]).postln;
				routine.stop;
			};
			scanInterval.wait;
		});
	});

	routine.play;
};
)

// ~bufferData[0].plot

/*(
OSCdef(\happyScore, { |msg|
var receivedValue = msg[1];
receivedValue.postln;
~scanBuffer.value(receivedValue, rrand(10, 100));
}, '/ch1');
)*/

(
~modPos = Routine({
	loop {
		var target = rrand(0.0, 1.0);
		var time = exprand(30.0, 120);
		var ampLag = time.linlin(30.0, 120, 5.0, 15);

		~bufferSynths[\playBuf1].do { |synth|
			synth.set(\amp, target.linlin(0, 1, -31.dbamp, -4.dbamp), \ampLag, ampLag);
		};

		~bufferSynths[\playBuf2].do { |synth|
			synth.set(\amp, target.linlin(0, 1, -4.dbamp, -31.dbamp), \ampLag, ampLag);
		};

		time.wait;
	};
});
)

~modPos.play;
// ~modPos.stop;


(
~modAmb = Routine({
	loop {
		var target = rrand(0.0, 1);
		var rate = rrand(10, 100);
		("Target Pos: " ++ target ++ ". Scanning...").postln;
		~scanBuffer.value(target, rate);
		rrand(30, rate.linlin(10,100,90,180)).wait;
	};
});
)

~modAmb.play;
// ~modAmb.stop;