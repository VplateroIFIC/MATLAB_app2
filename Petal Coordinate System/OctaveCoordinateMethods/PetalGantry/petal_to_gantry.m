%
% moves from petal coordinates to gantry coordinates
%
function pos = petal_to_gantry(petal, pos)
   pos = petal.Minv * [pos(1); pos(2); 1];
end
