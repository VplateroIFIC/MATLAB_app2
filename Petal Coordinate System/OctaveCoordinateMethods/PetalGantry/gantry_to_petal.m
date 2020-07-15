%
% moves from petal coordinates to gantry coordinates
%
function pos = gantry_to_petal(petal, P)
   pos = petal.M.M * [P(1); P(2); 1];
end
