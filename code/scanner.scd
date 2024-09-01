(
var bufferPath = "/Users/ryanmillett/Downloads/presentation_examples/audio/1_cps_ex1b_navigations_43.wav";
var buffer = Buffer.read(s, bufferPath);
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
            ("Position: " ++ (startIndex / (~bufferData[0].size - 1)).asFloat ++
            " Channel 1: " ++ ~bufferData[0][startIndex] ++
            " Channel 2: " ++ ~bufferData[1][startIndex]).postln;

            startIndex = startIndex + increment;

            if ((increment > 0 and: { startIndex >= endIndex }) or:
                (increment < 0 and: { startIndex <= endIndex })) {
                "Target position reached.".postln;
                currentPos = startIndex / (~bufferData[0].size - 1);
                routine.stop;
            };
            scanInterval.wait;
        });
    });

    routine.play;
};
)
~scanBuffer.value(0.1, 10);
