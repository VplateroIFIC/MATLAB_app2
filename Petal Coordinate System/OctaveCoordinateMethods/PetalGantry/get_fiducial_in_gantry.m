% Methods to get fiducial coordinates
%
% @param  petal  a PetalCoordinates object
% @param  type   T1, T2, T3, T4 for type 1, 2, 3, or 4.
%                H1 ... H5 for HPK fiducials
% @param  iring  sensor number (R0:0, R1:1, etc)
% @param  side   (0: right, 1:left)
% @param  cntr   The index of the possible various fiducials of
%                this kind
%
% @return        A Point with the position of the fiducial.
%
function pos = get_fiducial_in_gantry(petal, type, iring, side, cntr)
  name = build_fiducial_name(type, iring, side, cntr);
  try
    pos = petal.fiducials_gantry(name);
  catch
    pos = [];
  end
end
