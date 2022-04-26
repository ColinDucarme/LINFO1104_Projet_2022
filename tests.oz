PassedTests = {Cell.new 0}
TotalTests  = {Cell.new 0}

% Time in seconds corresponding to 5 samples.
FiveSamples = 0.00011337868

% Takes a list of samples, round them to 4 decimal places and multiply them by
% 10000. Use this to compare list of samples to avoid floating-point rounding
% errors.
fun {Normalize Samples}
   {Map Samples fun {$ S} {IntToFloat {FloatToInt S*10000.0}} end}
end

proc {Assert Cond Msg}
   TotalTests := @TotalTests + 1
   if {Not Cond} then
      {Browse Msg}
   else
      PassedTests := @PassedTests + 1
   end
end

proc {AssertEquals A E Msg}
   TotalTests := @TotalTests + 1
   if A \= E then
      {Browse Msg}
      {Browse actual(A)}
      {Browse expect(E)}
   else
      PassedTests := @PassedTests + 1
   end
end

% Prevent warnings if these are not used.
{ForAll [FiveSamples Normalize Assert AssertEquals] Wait}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST PartitionToTimedNotes

% Test a partition of notes
proc {TestNotes P2T}
   local Actual Expected in
      Actual = [a g5 silence f#4]
      Expected = [note(name:a octave:4 sharp:false duration:1.0 instrument:none) note(name:g octave:5 sharp:false duration:1.0 instrument:none) silence(duration:1.0) note(name:f octave:4 sharp:true duration:1.0 instrument:none)]
      {AssertEquals {P2T Actual} Expected 'TestNotes not passed'}
   end
end

% Test a partition of chords
proc {TestChords P2T}
   local Actual Expected in
      Actual = [[a g5 silence f#4] [a]]
      Expected = [[note(name:a octave:4 sharp:false duration:1.0 instrument:none) note(name:g octave:5 sharp:false duration:1.0 instrument:none) silence(duration:1.0) note(name:f octave:4 sharp:true duration:1.0 instrument:none)] [note(name:a octave:4 sharp:false duration:1.0 instrument:none)]]
      {AssertEquals {P2T Actual} Expected 'TestChords not passed'}
   end
end

% Test a partition of extended notes and extended chords
proc {TestIdentity P2T}
   local Actual1 Actual2 in
      Actual1 = [note(name:a octave:4 sharp:false duration:1.0 instrument:none) note(name:g octave:5 sharp:false duration:1.0 instrument:none) silence(duration:1.0) note(name:f octave:4 sharp:true duration:1.0 instrument:none)]
      Actual2 = [[note(name:a octave:4 sharp:false duration:1.0 instrument:none) note(name:g octave:5 sharp:false duration:1.0 instrument:none) silence(duration:1.0) note(name:f octave:4 sharp:true duration:1.0 instrument:none)] [note(name:a octave:4 sharp:false duration:1.0 instrument:none)]]
      {AssertEquals {P2T Actual1} Actual1 'TestIdentity with extended notes not passed'}
      {AssertEquals {P2T Actual2} Actual2 'TestIdentity with extended chords not passed'}
   end
end

% Test a partition of duration()
proc {TestDuration P2T}
   local Actual Expected in
      Actual = [duration(seconds:6.0 [a g5 silence f#4]) duration(seconds:4.0 [[a g5 silence f#4] [a]])]
      Expected = [note(name:a octave:4 sharp:false duration:1.5 instrument:none) note(name:g octave:5 sharp:false duration:1.5 instrument:none) silence(duration:1.5) note(name:f octave:4 sharp:true duration:1.5 instrument:none) [note(name:a octave:4 sharp:false duration:2.0 instrument:none) note(name:g octave:5 sharp:false duration:2.0 instrument:none) silence(duration:2.0) note(name:f octave:4 sharp:true duration:2.0 instrument:none)] [note(name:a octave:4 sharp:false duration:2.0 instrument:none)]]
      {AssertEquals {P2T Actual} Expected 'TestDuration not passed'}
   end
end

% Test a partition of stretch()
proc {TestStretch P2T}
   local Actual Expected in
      Actual = [stretch(factor:1.5 [a g5 silence f#4]) stretch(factor:2.0 [[a g5 silence f#4] [a]])]
      Expected = [note(name:a octave:4 sharp:false duration:1.5 instrument:none) note(name:g octave:5 sharp:false duration:1.5 instrument:none) silence(duration:1.5) note(name:f octave:4 sharp:true duration:1.5 instrument:none) [note(name:a octave:4 sharp:false duration:2.0 instrument:none) note(name:g octave:5 sharp:false duration:2.0 instrument:none) silence(duration:2.0) note(name:f octave:4 sharp:true duration:2.0 instrument:none)] [note(name:a octave:4 sharp:false duration:2.0 instrument:none)]]
      {AssertEquals {P2T Actual} Expected 'TestStretch not passed'}
   end
end

% Test a partition of drone()
proc {TestDrone P2T}
   local Actual Expected in
      Actual = [drone(note:a#5 amount:2) drone(note:[a g5 silence f#4] amount:2) ]
      Expected = [note(name:a octave:5 sharp:true duration:1.0 instrument:none) note(name:a octave:5 sharp:true duration:1.0 instrument:none) [note(name:a octave:4 sharp:false duration:1.0 instrument:none) note(name:g octave:5 sharp:false duration:1.0 instrument:none) silence(duration:1.0) note(name:f octave:4 sharp:true duration:1.0 instrument:none)] [note(name:a octave:4 sharp:false duration:1.0 instrument:none) note(name:g octave:5 sharp:false duration:1.0 instrument:none) silence(duration:1.0) note(name:f octave:4 sharp:true duration:1.0 instrument:none)] ]
      {AssertEquals {P2T Actual} Expected 'TestDrone not passed'}
   end
end

% Test a partition of transpose() NE FONCTIONNE PAS ENCORE
proc {TestTranspose P2T}
   local Actual Expected in
      Actual = [transpose(semitones:2 [a g5 silence f#4]) transpose(semitones:~2 [c g5 silence f#4]) transpose(semitones:12 [[a g5 silence f#4] [a]])]
      Expected = [note(name:b octave:4 sharp:false duration:1.0 instrument:none) note(name:a octave:5 sharp:false duration:1.0 instrument:none) silence(duration:1.0) note(name:g octave:4 sharp:true duration:1.0 instrument:none) note(name:a octave:3 sharp:true duration:1.0 instrument:none) note(name:f octave:5 sharp:false duration:1.0 instrument:none) silence(duration:1.0) note(name:e octave:4 sharp:false duration:1.0 instrument:none) [note(name:a octave:5 sharp:false duration:1.0 instrument:none) note(name:g octave:6 sharp:false duration:1.0 instrument:none) silence(duration:1.0) note(name:f octave:5 sharp:true duration:1.0 instrument:none)] [note(name:a octave:5 sharp:false duration:1.0 instrument:none)]]
      {AssertEquals {P2T Actual} Expected 'TestTranspose not passed'}
   end
end

% Test a partition with multiple transformations
proc {TestP2TChaining P2T}
   local Actual Expected in
      Actual = [stretch(factor:4.0 duration(seconds:1.0 [a g5 silence f#4])) stretch(factor:0.5 duration(seconds:4.0 [[a g5 silence f#4] [a]]))]
      Expected = [note(name:a octave:4 sharp:false duration:1.0 instrument:none) note(name:g octave:5 sharp:false duration:1.0 instrument:none) silence(duration:1.0) note(name:f octave:4 sharp:true duration:1.0 instrument:none) [note(name:a octave:4 sharp:false duration:1.0 instrument:none) note(name:g octave:5 sharp:false duration:1.0 instrument:none) silence(duration:1.0) note(name:f octave:4 sharp:true duration:1.0 instrument:none)] [note(name:a octave:4 sharp:false duration:1.0 instrument:none)]]
      {AssertEquals {P2T Actual} Expected 'TestP2TChaining not passed'}
   end
end

% Test all functions with empty chords
proc {TestEmptyChords P2T}
   local Actual Expected in
      Actual = [duration(seconds:1.0 [nil]) stretch(factor:1.0 [nil]) drone(note:nil amount:1) transpose(semitones:0 [nil])]
      Expected = [nil nil nil nil]
      {AssertEquals {P2T Actual} Expected 'TestEmptyChords not passed'}
   end
end
   
proc {TestP2T P2T}
   {TestNotes P2T}
   {TestChords P2T}
   {TestIdentity P2T}
   {TestDuration P2T}
   {TestStretch P2T}
   {TestDrone P2T}
   {TestTranspose P2T}
   {TestP2TChaining P2T}
   {TestEmptyChords P2T}   
   {AssertEquals {P2T nil} nil 'nil partition'}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST Mix

% Test a music of samples()
proc {TestSamples P2T Mix}
   local Actual Expected in
      Actual = [samples([~1.0 0.0 1.0]) samples([0.0 ~1.0])]
      Expected = [~1.0 0.0 1.0 0.0 ~1.0]
      {AssertEquals {Mix P2T Actual} Expected 'TestSamples not passed'}
   end
end

% Test a music of partition()
proc {TestPartition P2T Mix}
   local Actual Expected in
      Actual = [partition([duration(seconds:FiveSamples [a])])]
      Expected = [{Float.sin 2.0*3.1415926535*440.0/44100.0}/2.0 {Float.sin 2.0*3.1415926535*440.0*2.0/44100.0}/2.0 {Float.sin 2.0*3.1415926535*440.0*3.0/44100.0}/2.0 {Float.sin 2.0*3.1415926535*440.0*4.0/44100.0}/2.0 {Float.sin 2.0*3.1415926535*440.0*5.0/44100.0}/2.0]
      {AssertEquals {Normalize {Mix P2T Actual}} {Normalize Expected} 'TestPartition not passed'}
   end
end

% Test a music of partition() of chords
proc {TestPartitionChord P2T Mix}
   local Actual Expected in
      Actual = [partition([duration(seconds:FiveSamples [[a] nil]) duration(seconds:FiveSamples [silence])])]
      Expected = [{Float.sin 2.0*3.1415926535*440.0/44100.0}/2.0 {Float.sin 2.0*3.1415926535*440.0*2.0/44100.0}/2.0 {Float.sin 2.0*3.1415926535*440.0*3.0/44100.0}/2.0 {Float.sin 2.0*3.1415926535*440.0*4.0/44100.0}/2.0 {Float.sin 2.0*3.1415926535*440.0*5.0/44100.0}/2.0 0.0 0.0 0.0 0.0 0.0]
      {AssertEquals {Normalize {Mix P2T Actual}} {Normalize Expected} 'TestPartitionChord not passed'}
   end
end

% Test a music of wave()
proc {TestWave P2T Mix}
   % I listened and it was equal
   skip
end

% Test a music of merge()
proc {TestMerge P2T Mix}
   local Actual Expected in
      Actual = [merge([0.5#[samples([~1.0 0.0 1.0 0.0 ~1.0])] 1.0#[samples([1.0 0.0 ~1.0])]])]
      Expected = [0.5 0.0 ~0.5 0.0 ~0.5]
      {AssertEquals {Mix P2T Actual} Expected 'TestPartition not passed'}
   end
end

% Test a music of reverse()
proc {TestReverse P2T Mix}
   local Actual Expected in
      Actual = [reverse([samples([~1.0 0.0 1.0])]) reverse([samples([0.0 ~1.0])])]
      Expected = [1.0 0.0 ~1.0 ~1.0 0.0]
      {AssertEquals {Mix P2T Actual} Expected 'TestReverse not passed'}
   end
end

% Test a music of repeat()
proc {TestRepeat P2T Mix}
   local Actual Expected in
      Actual = [repeat(amount:2 [samples([~1.0 0.0 1.0])])]
      Expected = [~1.0 0.0 1.0 ~1.0 0.0 1.0]
      {AssertEquals {Mix P2T Actual} Expected 'TestRepeat not passed'}
   end
end

% Test a music of loop()
proc {TestLoop P2T Mix}
   local Actual Expected in
      Actual = [loop(seconds:FiveSamples [samples([~1.0 0.0 1.0])])]
      Expected = [~1.0 0.0 1.0 ~1.0 0.0]
      {AssertEquals {Mix P2T Actual} Expected 'TestLoop not passed'}
   end
end

% Test a music of clip()
proc {TestClip P2T Mix}
   local Actual Expected in
      Actual = [clip(low:0.0 high:0.5 [samples([~1.0 0.0 1.0])])]
      Expected = [0.0 0.0 0.5]
      {AssertEquals {Mix P2T Actual} Expected 'TestClip not passed'}
   end
end

% Test a music of echo()
proc {TestEcho P2T Mix}
   local Actual Expected in
      Actual = [echo(delay:FiveSamples decay:0.5 [samples([~1.0 0.0 1.0 0.0 ~1.0])])]
      Expected = [~1.0 0.0 1.0 0.0 ~1.0 ~0.5 0.0 0.5 0.0 ~0.5]
      {AssertEquals {Mix P2T Actual} Expected 'TestEcho not passed'}
   end
end

% Test a music of fade()
proc {TestFade P2T Mix}
   local Actual Expected in
      Actual = [fade(start:FiveSamples out:FiveSamples [samples([1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0])])]
      Expected = [0.0 0.2 0.4 0.6 0.8 1.0 1.0 1.0 1.0 1.0 0.8 0.6 0.4 0.2 0.0]
      {AssertEquals {Normalize {Mix P2T Actual}} {Normalize Expected} 'TestFade not passed'}
   end
end

% Test a music of cut()
proc {TestCut P2T Mix}
   local Actual1 Expected1 Actual2 Expected2 in
      Actual1 = [cut(start:FiveSamples finish:2.0*FiveSamples [samples([0.0 0.2 0.4 0.6 0.8 1.0 1.0 1.0 1.0 1.0 0.8 0.6 0.4 0.2 0.0])])]
      Expected1 = [1.0 1.0 1.0 1.0 1.0]
      {AssertEquals {Mix P2T Actual1} Expected1 'TestCut without silence not passed'}
      Actual2 = [cut(start:0.0 finish:2.0*FiveSamples [samples([1.0 1.0 1.0 1.0 1.0])])]
      Expected2 = [1.0 1.0 1.0 1.0 1.0 0.0 0.0 0.0 0.0 0.0]
      {AssertEquals {Mix P2T Actual2} Expected2 'TestCut with silence not passed'}
   end
end

proc {TestMix P2T Mix}
   {TestSamples P2T Mix}
   {TestPartition P2T Mix}
   {TestPartitionChord P2T Mix}
   {TestWave P2T Mix}
   {TestMerge P2T Mix}
   {TestReverse P2T Mix}
   {TestRepeat P2T Mix}
   {TestLoop P2T Mix}
   {TestClip P2T Mix}
   {TestEcho P2T Mix}
   {TestFade P2T Mix}
   {TestCut P2T Mix}
   {AssertEquals {Mix P2T nil} nil 'nil music'}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc {Test Mix P2T}
   {Property.put print print(width:100)}
   {Property.put print print(depth:100)}
   {Browse 'tests have started'}
   {TestP2T P2T}
   {Browse 'P2T tests have run'}
   {TestMix P2T Mix}
   {Browse 'Mix tests have run'}
   {Browse test(passed:@PassedTests total:@TotalTests)}
end
