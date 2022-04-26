% Megalovania (from Undertale) by Toby Fox
local
   Start1 = [stretch(factor:0.1 [d d]) stretch(factor:0.2 [d5]) stretch(factor:0.3 [a]) stretch(factor:0.2 [g#4 g f]) stretch(factor:0.1 [d f g])]
   Start2 = [stretch(factor:0.1 [c c]) stretch(factor:0.2 [d5]) stretch(factor:0.3 [a]) stretch(factor:0.2 [g#4 g f]) stretch(factor:0.1 [d f g])]
   Start3 = [stretch(factor:0.1 [b3 b3]) stretch(factor:0.2 [d5]) stretch(factor:0.3 [a]) stretch(factor:0.2 [g#4 g f]) stretch(factor:0.1 [d f g])]
   Start4 = [stretch(factor:0.1 [a#3 a#3]) stretch(factor:0.2 [d5]) stretch(factor:0.3 [a]) stretch(factor:0.2 [g#4 g f]) stretch(factor:0.1 [d f g])]

   Start = {Append {Flatten [Start1 Start2 Start3 Start4]} {Flatten [Start1 Start2 Start3 Start4]}}

   Main = [stretch(factor:0.2 [f]) stretch(factor:0.1 [f]) stretch(factor:0.2 [f f f d]) stretch(factor:0.3 [d]) stretch(factor:0.2 [d]) stretch(factor:0.1 [f f f]) stretch(factor:0.2 [f g g#4]) stretch(factor:0.1 [g f d f]) stretch(factor:0.3 [g]) stretch(factor:0.2 [f]) stretch(factor:0.1 [f]) stretch(factor:0.2 [f g g#4 a c5]) stretch(factor:0.3 [a]) stretch(factor:0.2 [d5 d5]) stretch(factor:0.1 [d5 a d5]) stretch(factor:0.9 [c5])]
   
   Partition = [stretch(factor:1.5 {Flatten [Start Main]})]
in
   [partition(Partition)]
end