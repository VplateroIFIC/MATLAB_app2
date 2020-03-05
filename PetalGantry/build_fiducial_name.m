%
% Builds the fiducial name
%
% @param  type   T1, T2, T3, T4 for type 1, 2, 3, or 4.
%                H1 ... H5 for HPK fiducials
% @param  iring  sensor number (R0:0, R1:1, etc)
% @param  side   (0: right, 1:left)
% @param  cntr   The index of the possible various fiducials of
%                this kind
%
% @return        Fiducial name.
%
function name = build_fiducial_name(type, iring, side, counter)
   name = sprintf('R%d_%s_%d_%d', iring, type, counter, side);
endfunction
