
Buffer.freeAll;
(
~rate = 20;
// ~buffersPath = PathName.new(PathName.new(thisProcess.nowExecutingPath).parentPath ++ "buffers/dopamine/spikes");
~currentPath = PathName.new(thisProcess.nowExecutingPath).pathOnly;
~projectPath = PathName.new(~currentPath).parentPath;
~buffersPath = PathName.new(~projectPath ++ "buffers/dopamine/spikes");

~rt = Routine({
	var bufferPath = ~buffersPath.entries.select({ |file| file.extension == "wav" }).choose.fullPath;
	var buffer = Buffer.read(s, bufferPath);
	var ar = Array.new;
	s.sync;
	bufferPath.postln;
	buffer.loadToFloatArray(action: { |array|
		buffer.numChannels.do { |i|
			var channelData = array.clump(buffer.numChannels).collect({ |chanVals| chanVals[i] });
			ar = ar.add(channelData);
		};
	});
	s.sync;

	s.bind{ ~plucks = Synth(\plucks, [\amp, -8.dbamp]); };

	ar[0].size.do { |i|
		var val = ar[2][i];
		var interval = ~rate / ar[0].size;
		var freq=500, coef=0.7, decay=0.5;
		// ar[0][i].postln;
		if (i == ar[0].minIndex,
			{
				s.bind{ Synth(\boing, [\amp, -8.dbamp]); };
				s.bind{ ~plucks.set(\gate, 0); };

				s.bind{ ~steam = Synth(\heat, [\amp, 0.8]); };
				s.bind{ ~rumb = Synth(\rumbler, [\out, 5, \amp, 0.3]); };
				// "BOING!".postln;
			},
			{
				if (i < ar[0].minIndex,
					{
						s.bind{
							~plucks.set(
								// \freq, val.linexp(0.001, 1, 500, 900),
								// \freqLag, interval*0.8,
								\impRate, val.pow(0.75).linexp(0.001, 1, 5, 30),
								\impLag, interval*0.8,
								\coef, val.linlin(0.001, 1, 0.9, 0.4),
								// \amp, -6.dbamp,
							);
						};
					},
					{
						s.bind{
							~steam.set(
								\hpfFreq, ar[1][i].linexp(0,1,200,1000),
								\hpfLag, interval,
								\amp, ar[3][i].linlin(ar[3].minItem, ar[3].maxItem, 0, 1),
								// \width, ar[3][i].linlin(ar[3].minItem, ar[3].maxItem, -0.8, 0.8)
							);
						};
					}
				)
			}
		);
		(interval).wait;
	};
	// ~plucks.set(\gate, 0);
	s.bind{ ~steam.set(\gate, 0); };
	s.bind{ ~rumb.set(\gate, 0); };
	buffer.free;
	(~rate * rrand(2,10)).wait;
});
)

(
~afm_events = Routine({
	loop {
		~rt.reset;
		~rt.play;
		(~rate * rrand(5.0,10)).wait;
	}
});
)

~afm_events.play;

~rt.stop();

