%
% Return sensor coordinates in
%
function pos = get_sensor_pos_in_gantry(petal, indx)
  pos = petal.sensor_positions_gantry(:,indx);
endfunction
