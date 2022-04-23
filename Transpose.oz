declare
fun {Nth Xs I}
    case I of 0 then Xs.1
    else {Nth Xs.2 I-1}
    end
end

declare 
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