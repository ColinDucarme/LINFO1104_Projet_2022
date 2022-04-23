declare
fun {Duration Partion Duration}
   {TimeSet Partion Duration/{TotalTime Partion 0.0}}
end
    


declare 
fun {TotalTime X Acc}
    case X of nil then Acc
    [] H|T then {TotalTime T Acc+H.duration}
    end
end

declare
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

declare
P = [b b c5 d5 d5 c5 b a g g a b]
{Browse {Duration {PartitionToTimedList P} 6.0}}