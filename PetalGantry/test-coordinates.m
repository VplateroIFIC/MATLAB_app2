%
% Test of the PetalCoordinates class
%
pkg load io;

printf('Creating object\n');
petal = PetalCoordinates();

printf('Setting references from gantry coordinates of locators\n');
upper_locator = [23.8152; 1059.4657];
lower_locator = [48.9825; 458.9928];
petal.set_references(upper_locator, lower_locator);

printf('Origin in Gantry (%.3f, %.3f)\n', lower_locator(1), lower_locator(2));

pos = petal_to_gantry(petal, [0 0]);
printf('...from petal T. (%.3f, %.3f)\n', pos(1), pos(2));

orig = gantry_to_petal(petal, pos);
printf('...from gantry T. (%.3f, %.3f)\n', orig(1), orig(2));

printf('*** Sensors\n');
for isensor = 1:9
  printf('Sensor %d:\n', isensor);
  pos = get_sensor_pos_in_petal(petal, isensor);
  printf('\tpetal:  (%.3f, %.3f)\n', pos(1), pos(2));
  pos = get_sensor_pos_in_gantry(petal, isensor);
  printf('\tgantry: (%.3f, %.3f)\n', pos(1), pos(2));
endfor

printf('*** Fiducials\n');
for iring = 0:5
  nsensor = 1;
  if (iring>2)
    nsensor = 2;
  endif

  for isensor = 1:nsensor
    for ik = 0:3
      printf('R%d_T4_%d_%d\n', iring, ik, isensor);
      pos = get_fiducial_in_petal(petal, 'T4', iring, isensor, ik);
      if (isempty(pos))
        printf('...does not exist\n');
        continue;
      endif
      printf('\tpetal: (%.3f, %.3f)\n', pos(1), pos(2));

      pos = get_fiducial_in_gantry(petal, 'T4', iring, isensor, ik);
      printf('\tgantry: (%.3f, %.3f)\n', pos(1), pos(2));

      Q = gantry_to_petal(petal, pos);
      printf('\tpetal: (%.3f, %.3f)\n', Q(1), Q(2));


    endfor
  endfor
endfor
