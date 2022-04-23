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

   fun {PartitionToTimedList Partition}
      % TODO
      nil
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
      % TODO
      {Project.readFile CWD#'wave/animals/cow.wav'}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Music = {Project.load CWD#'joy.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert '/full/absolute/path/to/your/tests.oz'
   % !!! Remove this before submitting.local
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

   fun {PartitionToTimedList Partition}
      % TODO
      nil
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun {Mix P2T Music}
      fun {RecursiveMix P2T Music Samples}
	 case Music of nil then Samples|nil
	 [] Part|Mus then
	    case Part of samples(S) then {RecursiveMix P2T Mus Samples|S}
	    [] partition(P) then {RecursiveMix P2T Mus Samples|{Sampling {P2T P}}}
	    [] wave(Filename) then {RecursiveMix P2T Mus Samples|{Project.readFile CWD#Filename}}
	    [] merge(M) then {RecursiveMix P2T Mus Samples|{Merge M}}
	    [] reverse(M) then {RecursiveMix P2T Mus Samples|{Reverse M}}
	    [] repeat(amount:A M) then {RecursiveMix P2T Mus Samples|{Repeat A M}}
	    [] loop(duration:D M) then {RecursiveMix P2T Mus Samples|{Loop D M}}
	    [] clip(low:L high:H M) then {RecursiveMix P2T Mus Samples|{Clip L H M}}
	    [] echo(delay:D M) then {RecursiveMix P2T Mus Samples|{Echo D M}}
	    [] fade(start:In out:Out M) then {RecursiveMix P2T Mus Samples|{Fade In Out M}}
	    [] cut(start:S finish:E M) then {RecursiveMix P2T Mus Samples|{Cut S E M}}
	    end
	 end
      end
   in
      {RecursiveMix P2T Music first}.2
   end

   fun {Sampling FlatPartition}
      fun {SamplingAux FlatP Samples}
	 case FlatP of nil then Samples
	 [] ES|FlatP2 then
	 end
      end
   in
      {SamplingAux FlatPartition _}
   end

   fun {Merge M}
      
   end

   fun {Reverse M}
      
   end
   
   fun {Repeat Amount M}
      
   end
   
   fun {Loop Duration M}
      
   end

   fun {Clip Low High M}

   end

   fun {Echo Delay M}

   end

   fun {Fade In Out M}

   end

   fun {Cut Start Finish M}

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
