declare
fun {Drone Chord N}
    if N==1.0 then 
        Chord|nil
    else
        Chord|{Drone Chord N-1.0}
    end
end