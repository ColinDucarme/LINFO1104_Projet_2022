% LINFO1104 Projet 2022 - Maestroz by
% Ahadji Alex 80222000
% Ducarme Colin 81472000

local
   % See project statement for API details.
   % !!! Please remove CWD identifier when submitting your project !!!
   CWD = '/home/colin/Documents/Cours UCL/Q4/Concepts des langages de programmation/Projet/' % Put here the **absolute** path to the project files
   [Project] = {Link [CWD#'Project2022.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                         PARTITIONTOTIMEDLIST SECTION                      %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Translate a note to the extended notation.
   %
   % Pre : Note : <note>
   %
   % Post : <extended note>
   %
   fun {NoteToExtended Note}
      case Note
      of Name#Octave then
	 note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] silence then
	 silence(duration:1.0)
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
   %
   % Stretch duration of P by a factor F.
   %
   % Pre : P : <flat partition>
   %       F : <factor>
   %
   % Post : <flat partition>
   %
   fun {TimeSet P F}
      case P of nil then nil 
      [] H|T then
	 case H of X|Y then
	    {TimeSet X F}|{TimeSet Y F}
	 [] silence(duration:D) then
	    silence(duration:D*F)
	 [] note(name:Name octave:Octave sharp:Boolean duration:D instrument:I) then
	    note(name:Name
		 octave:Octave
		 sharp:Boolean
		 duration:D*F
		 instrument: I)|{TimeSet T F}
	 end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Set duration of Partition to Duration.
   %
   % Pre : Partition : <flat partition>
   %       Duration : <duration>
   %
   % Post : <flat partition>
   %
   fun {Duration Partition Duration}
      fun {TotalTime X Acc}
	 case X of nil then Acc
	 [] H|T then
	    if {List.is H} then {TotalTime T Acc+H.1.duration} % Case H is <extended chord>
	    else {TotalTime T Acc+H.duration} % Case H is <extended note>
	    end
	 end
      end
   in
      {TimeSet Partition Duration/{TotalTime Partition 0.0}}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Repeat Chord N times.
   %
   % Pre : Chord : <extended sound>
   %       N : <natural>
   %
   % Post : <flat partition>
   %
   fun {Drone Chord N}
      if N==1 then 
	 Chord|nil
      else
	 Chord|{Drone Chord N-1}
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Transpose P of I semitones.
   %
   % Pre : P : <flat partition>
   %       I : <integer>
   %
   % Post : <flat partition>
   %
   fun {Transpose P I}
      case P of nil then nil
      [] H|T then 
	 {Transpose H I}|{Transpose T I}
      [] silence(duration:D) then
	 silence(duration:D)
      [] note(name:Name octave:Octave sharp:Boolean duration:D instrument:Instr) then
	 local N X Y Z in
	    N= [c c#2 d d#2 e f f#2 g g#2 a a#2 b] 
	    if Boolean==true then
	       case Name of c then X=I
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
	    case {List.nth N (X mod 12)} of A#B then
	       note(name: A
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

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Translate Partition into <flat partition>.
   %
   % Pre : Partition : <partition>
   %
   % Post : <flat partition>
   %
   fun {PartitionToTimedList Partition}
      case Partition 
      of nil then nil
      [] X|Y then
	 if {List.is X} then {PartitionToTimedList X}|{PartitionToTimedList Y}
	 else {Append {PartitionToTimedList X} {PartitionToTimedList Y}}
	 end
      [] Name#Octave then
         [{NoteToExtended Partition}]
      [] duration(1:P seconds:D) then
         {Duration {PartitionToTimedList P} D}
      [] stretch(1:P factor:F)then
         {TimeSet {PartitionToTimedList P} F}
      [] drone(note:C amount:N) then 
         {Drone {PartitionToTimedList C}.1 N}
      [] transpose(1:P semitones:I) then 
	 {Transpose {PartitionToTimedList P} I}
      [] silence(duration:D) then
	 [silence(duration:D)]
      [] note(name:Name octave:Octave sharp:Boolean duration:D instrument:I) then
	 [note(name:Name octave:Octave sharp:Boolean duration:D instrument:I)] 
      [] Atom then 
         [{NoteToExtended Partition}]
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                               MIX SECTION                                 %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Sample FlatPartition.
   %
   % Pre : FlatPartition : <flat partition>
   %
   % Post : <samples>
   %
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
      [] ES|FP then if {List.is ES} then {Append {SamplingChord {Sampling ES} ES} {Sampling FP}}
		    else {Append {Sampling ES} {Sampling FP}}
		    end
      [] EN then
	 local H Frequency in
	    H = {Height EN}
	    Frequency = {Number.pow 2.0 {IntToFloat H}/12.0}*440.0
	    {List.mapInd {List.make {FloatToInt 44100.0*EN.duration}} fun {$ I A} {Float.sin 2.0*3.1415926535*Frequency*{IntToFloat I}/44100.0}/2.0 end}
	 end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Merge different musics with differents factors.
   %
   % Pre : P2T : function which translates <partition> into <flat partition>
   %       M : <music with intensities>
   %
   % Post : <samples>
   %
   fun {Merge P2T M}
      fun {MergeSum Lis Acc}
	 case Lis of nil then Acc
	 [] H|T then {MergeSum T {List.zip Acc H fun {$ X Y} X + Y end}}
	 end
      end
      fun {MaxLength L Acc}
	 case L of nil then Acc
	 [] H|T then {MaxLength T {Value.max {List.length H} Acc}}
	 end
      end
      fun {MakeEqualLength L MaxLength}
	 case L of nil then nil
	 [] H|T then {Append H {List.map {List.make MaxLength-{List.length H}} fun {$ X} 0.0 end }}|{MakeEqualLength T MaxLength}
	 end
      end
      fun {MergeProduct P2T M}
	 case M of nil then nil
	 [] H|T then {MergeProduct P2T H}|{MergeProduct P2T T}
	 [] A#Mus then
	    {List.map {Mix P2T Mus} fun {$ X} X*A end}
	 end
      end
   in
      local L Products MaxL in
	 Products = {MergeProduct P2T M}
	 MaxL = {MaxLength Products 0}
	 L = {MakeEqualLength Products MaxL}
	 {MergeSum L {List.map {List.make {List.length L.1}} fun {$ X} 0.0 end }}
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Reverse Samples.
   %
   % Pre : Samples : <samples>
   %
   % Post : <samples>
   %
   fun {Reverse Samples}
      {List.reverse Samples}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Repeat Samples Amount times.
   %
   % Pre : Amount : <integer>
   %       Samples : <samples>
   %
   % Post : <samples>
   %
   fun {Repeat Amount Samples}
      case Amount of 0 then nil
      [] N then {Append Samples {Repeat N-1 Samples}}
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Repeat Samples during Duration seconds.
   %
   % Pre : Duration : <duration>
   %       Samples : <samples>
   %
   % Post : <samples>
   %
   fun {Loop Duration Samples}
      local MusicDuration SamplesDuration in
	 MusicDuration = {List.length Samples}
	 SamplesDuration = {FloatToInt 44100.0*Duration}
	 {Append {Repeat (SamplesDuration div MusicDuration) Samples} {List.take Samples (SamplesDuration mod MusicDuration)}}
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Clip Samples from Low to High.
   %
   % Pre : Low : <sample>
   %       High : <sample>
   %       Samples : <samples>
   %
   % Post : <samples>
   %
   fun {Clip Low High Samples}
      {List.map Samples fun {$ X}
			   if X < Low then Low
			   elseif X > High then High
			   else X
			   end
			end}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Add echo with a delay of Delay and a factor of Decay to Music.
   %
   % Pre : P2T : function which translates <partition> into <flat partition>
   %       Delay : <duration>
   %       Decay : <factor>
   %       Music : <music>
   %
   % Post : <samples>
   %
   fun {Echo P2T Delay Decay Music}
      {Merge P2T [1.0#Music Decay#(partition(silence(duration:Delay))|Music)] }
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Increase volume of music linearly during In seconds at start and decrease
   % it linearly during Out seconds at finish.
   %
   % Pre : In : <duration>
   %       Out : <duration>
   %       Samples : <samples>
   %
   % Post : <samples>
   %
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
	 Factors = {Append {Arange 0.0 1.0 StepIn 0.0}  {Append {Cut In {IntToFloat {List.length Samples}}/44100.0-Out {List.map {List.make {List.length Samples}} fun {$ X} 1.0 end }} {List.reverse {Arange 0.0 1.0 StepOut 0.0}}}}
	 {List.zip Factors Samples fun {$ X Y} X*Y end}
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Cut Samples from Start to Finish.
   %
   % Pre : Start : <duration>
   %       Finish : <duration>
   %       Samples : <samples>
   %
   % Post : <samples>
   %
   fun {Cut Start Finish Samples}
      local SamplesStart SamplesFinish in
	 SamplesStart = {FloatToInt Start*44100.0}
	 SamplesFinish = {FloatToInt Finish*44100.0}
	 if SamplesFinish >= {List.length Samples} then {Append {List.drop {List.take Samples SamplesFinish} SamplesStart} {List.map {List.make SamplesFinish-{List.length Samples}} fun {$ X} 0.0 end }}
	 else {List.drop {List.take Samples SamplesFinish} SamplesStart}
	 end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %
   % Translate Music into samples.
   %
   % Pre : P2T : function which translates <partition> into <flat partition>
   %       M : <music>
   %
   % Post : <samples>
   %
   fun {Mix P2T Music}
      case Music of nil then nil
      [] Part|Mus then {Append {Mix P2T Part} {Mix P2T Mus}}
      [] samples(S) then S
      [] partition(P) then {Sampling {PartitionToTimedList P}}
      [] wave(Filename) then {Project.readFile CWD#Filename}
      [] merge(M) then {Merge P2T M}
      [] reverse(M) then {Reverse {Mix P2T M}}
      [] repeat(amount:A M) then {Repeat A {Mix P2T M}}
      [] loop(seconds:D M) then {Loop D {Mix P2T M}}
      [] clip(low:L high:H M) then {Clip L H {Mix P2T M}}
      [] echo(delay:D decay:F M) then {Echo P2T D F M}
      [] fade(start:In out:Out M) then {Fade In Out {Mix P2T M}}
      [] cut(start:S finish:E M) then {Cut S E {Mix P2T M}}
      end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Music = {Project.load CWD#'joy.dj.oz'}
   Start
   
in
   Start = {Time}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [NoteToExtended Music] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music CWD#'out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end
