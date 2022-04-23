local
   % See project statement for API details.
   % !!! Please remove CWD identifier when submitting your project !!!
   CWD = '/directory/to/the/project/template/' % Put here the **absolute** path to the project files
   [Project] = {Link [CWD#'Project2022.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
   fun {NoteToExtended Note}
      case Note
      of Name#Octave then
         note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] Atom then
         case {AtomToString Atom}
         of [_] then
            note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
         [] [N O] then
            note(name:{StringToAtom [N]}
                 octave:{StringToInt [O]}
                 sharp:false
                 duration:1.0
                 instrument: none)
         end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Duration Partion Duration}
      {TimeSet Partion Duration/{TotalTime Partion 0.0}}
   end

   fun {TotalTime X Acc}
      case X of nil then Acc
      [] H|T then {TotalTime T Acc+H.duration}
      end
   end

   fun {TimeSet P F}
      case P of nil then nil 
      [] H|T then 
	 note(name:H.name
	      octave:H.octave
	      sharp:H.sharp
	      duration:H.duration*F
	      instrument: H.instrument)|{TimeSet T F}
      end
   end
   
   fun {Drone Chord N}
      if N==1 then 
	 Chord|nil
      else
	 Chord|{Drone Chord N-1}
      end
   end

   fun {Transpose P I}
      case P of nil then nil
      [] H|T then 
	 {Transpose H I}|{Transpose T I}
      else
	 local N X Y Z in
	    N= [c c#2 d d#2 e f f#2 g g#2 a a#2 b] 
	    if P.sharp==true then
	       case P.name of c then X=I
	       [] d then X=2+I
	       [] e then X=4+I
	       [] f then X=5+I
	       [] g then X=7+I
	       [] a then X=9+I
	       [] b then X=11+I
	       end
	    else
	       case P.name of c then X=I+1
	       [] d then X=3+I
	       [] e then X=5+I
	       [] f then X=6+I
	       [] g then X=8+I
	       [] a then X=10+I
	       [] b then X=12+I
	       end
	    end
	    if X>11 then
	       Y = Z div 11
	    else 
	       Y=0
	    end
	    case {Nth N (X mod 12)} of Name#Octave then
	       note(name: Name
		    octave: P.octave + Y 
		    sharp:true
		    duration:P.duration
		    instrument: P.instrument)
	    [] Atom then
	       note(name: Atom
		    octave: P.octave+Y
		    sharp:false 
		    duration:P.duration
		    instrument: P.instrument)
	    end
	 end
      end
   end
   
   fun {PartitionToTimedList Partition}
      case Partition 
      of nil then nil
      [] X|Y then
         {PartitionToTimedList X}|{PartitionToTimedList Y}
      [] Name#Octave then
         {NoteToExtended Partition}
      [] duration(1:P seconds:D) then
         {Duration {PartitionToTimedList P} D}
      [] stretch(1:P factor:F)then
         {TimeSet {PartitionToTimedList P} F}
      [] drone(note:C amount:N) then 
         {Drone {PartitionToTimedList C} N}
      [] transpose(1:P semitones:I) then 
         {Transpose {PartitionToTimedList P} I}
      [] Atom then 
         {NoteToExtended Partition}
      else Partition
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Sampling FlatPartition}
      fun {SamplingChord Samples ExtendedChord}
	 {List.map {List.foldL Samples fun {$ X Y} X + Y end 0.0} fun {$ X} X/{IntToFloat {List.length ExtendedChord}} end}
      end
      fun {Height Note}
	 case Note
	 of silence(duration:D) then 0
	 [] note(name:N octave:O sharp:B duration:D instrument:I) then
	    case N#B of a#false then (O-4)*12
	    [] a#true then (O-4)*12+1
	    [] b#false then (O-4)*12+2
	    [] c#false then (O-4)*12-9
	    [] c#true then (O-4)*12-8
	    [] d#false then (O-4)*12-7
	    [] d#true then (O-4)*12-6
	    [] e#false then (O-4)*12-5
	    [] f#false then (O-4)*12-4
	    [] f#true then (O-4)*12-3
	    [] g#false then (O-4)*12-2
	    [] g#true then (O-4)*12-1
	    end
	 end
      end
   in
      case FlatPartition of nil then nil
      [] ES|FP then if {List.is ES} then {SamplingChord {Sampling ES} ES}|{Sammpling FP}
		    else {Sampling ES}|{Sampling FP}
		    end
      [] EN then
	 local Height Frequency in
	    Height = {Height EN}
	    Frequency = {Number.pow 2.0 {IntToFloat Height}/12.0}*440.0
	    {List.mapInd {List.make {FloatToInt 44100.0*EN.duration}} fun {$ I A} {Float.sin 2.0*3.1415926535*Frequency*{IntToFloat I}/44100.0}/2.0 end}
	 end
      end
   end

   fun {Merge P2T M}
      fun {MergeSum Lis Acc}
	 case Lis of nil then Acc
	 [] H|T then {MergeSum T {List.zip Acc H fun {$ X Y} X + Y end}}
	 end
      end
      fun {MakeEqualLength L}
	 fun {MaxLength L Acc}
	    case L of nil then Acc
	    [] H|T then {MaxLength T {Value.max {List.length H} Acc}}
	    end
	 end
      in
	 case L of nil then nil
	 [] H|T then {Append H {List.map {List.make {MaxLength L 0}} fun {$ X} 0.0 end }}|{MakeEqualLength T}
	 end
      end
      fun {MergeProduct P2T M}
	 case M of nil then nil
	 [] H|T then {MergeProduct H}|{MergeProduct T}
	 [] A#Mus then
	    {List.map {Mix P2T Mus} fun {$ X} X/A end}
	 end
      end
   in
      local L in
	 L = {MakeEqualLength {MergeProduct P2T M}}
	 {MergeSum L {List.map {List.make {List.length L.1}} fun {$ X} 0.0 end }}
      end
   end

   fun {Reverse Samples}
      {List.reverse Samples}
   end
   
   fun {Repeat Amount Samples}
      case Amount of 0 then nil
      [] N then {Append Samples {Repeat N-1 Samples}}
      end
   end
   
   fun {Loop Duration Samples}
      local MusicDuration in
	 MusicDuration = {List.length Samples}
	 SamplesDuration = {FloatToInt 44100.0*Duration}
	 {Append {Repeat (SamplesDuration div MusicDuration) Samples} {List.take Samples (SamplesDuration mod MusicDuration)}}
      end
   end

   fun {Clip Low High Samples}
      {List.map Samples fun {$ X}
			   if X < Low then Low
			   elseif X > High then High
			   else X
			   end
			end}
   end

   fun {Echo P2T Delay Decay Music}
      {Merge P2T [1.0#Music Decay#(partition(silence(duration:Decay))|M)] }
   end

   fun {Fade In Out Samples}
      fun {Arange Start Stop Step Actual}
	 if Actual >= Stop then nil
	 else Actual|{Arange Start Stop Step Actual+Step}
	 end
      end
   in
      local Factors StepIn StepOut in
	 StepIn = 1.0/(44100.0*In)
	 StepOut = 1.0/(44100.0*Out)
	 Factors = {Append {Arange 0.0 1.0 StepIn 0.0}  {Append {Cut In {IntToFloat {List.length Samples}}/44100.0-Out Samples} {List.reverse {Arange 0.0 1.0 StepOut 0.0}}}}
	 {List.zip Factors Samples fun {$ X Y} X*Y end}
      end
   end

   fun {Cut Start Finish Samples}
      local SamplesStart SamplesFinish in
	 SamplesStart = {FloatToInt Start*44100.0}
	 SamplesFinish = {FloatToInt Finish*44100.0}
	 if SamplesFinish >= {List.length Samples} then {Append {List.drop {List.take Samples SamplesFinish} SamplesStart} {List.map {List.make SamplesFinish-{List.length Samples}} fun {$ X} 0.0 end }}
	 else {List.drop {List.take Samples SamplesFinish} SamplesStart}
	 end
      end
   end

   fun {Mix P2T Music}
      case Music of nil then nil
      [] Part|Mus then {Append {Mix P2T Part} {Mix P2T Mus}}
      [] samples(S) then S
      [] partition(P) then {Sampling {PartitionToTimedList P}}
      [] wave(Filename) then {Project.readFile CWD#Filename}
      [] merge(M) then {Merge P2T M}
      [] reverse(M) then {Reverse {Mix P2T M}}
      [] repeat(amount:A M) then {Repeat A {Mix P2T M}}
      [] loop(duration:D M) then {Loop D {Mix P2T M}}
      [] clip(low:L high:H M) then {Clip L H {Mix P2T M}}
      [] echo(delay:D decay:F M) then {Echo P2T D F M}
      [] fade(start:In out:Out M) then {Fade In Out {Mix P2T M}}
      [] cut(start:S finish:E M) then {Cut S E {Mix P2T M}}
      end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Music = {Project.load CWD#'joy.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert '/full/absolute/path/to/your/tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [NoteToExtended Music] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end
