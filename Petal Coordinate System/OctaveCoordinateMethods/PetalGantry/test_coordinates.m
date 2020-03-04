%
% Test of the PetalCoordinates class
%
% pkg load io;

fprintf('Creating object\n');
petal = PetalCoordinates();

fprintf('Setting references from gantry coordinates of locators\n');
upper_locator = [23.8152; 1059.4657];
lower_locator = [48.9825; 458.9928];
petal.set_references(upper_locator, lower_locator);

fprintf('Origin in Gantry (%.3f, %.3f)\n', lower_locator(1), lower_locator(2));

pos = petal_to_gantry(petal, [0 0]);
fprintf('...from petal T. (%.3f, %.3f)\n', pos(1), pos(2));

orig = gantry_to_petal(petal, pos);
fprintf('...from gantry T. (%.3f, %.3f)\n', orig(1), orig(2));

fprintf('*** Sensors\n');
for isensor = 1:9
  fprintf('Sensor %d:\n', isensor);
  pos = get_sensor_pos_in_petal(petal, isensor);
  fprintf('\tpetal:  (%.3f, %.3f)\n', pos(1), pos(2));
  pos = get_sensor_pos_in_gantry(petal, isensor);
  fprintf('\tgantry: (%.3f, %.3f)\n', pos(1), pos(2));
end

fprintf('*** Fiducials\n');
for iring = 0:5
  nsensor = 1;
  if (iring>2)
    nsensor = 2;
  end

  for isensor = 1:nsensor
    for ik = 0:3
      fprintf('R%d_T4_%d_%d\n', iring, ik, isensor);
      pos = get_fiducial_in_petal(petal, 'T4', iring, isensor, ik);
      if (isempty(pos))
        fprintf('...does not exist\n');
        continue;
      end
      fprintf('\tpetal: (%.3f, %.3f)\n', pos(1), pos(2));

      pos = get_fiducial_in_gantry(petal, 'T4', iring, isensor, ik);
      fprintf('\tgantry: (%.3f, %.3f)\n', pos(1), pos(2));

      Q = gantry_to_petal(petal, pos);
      fprintf('\tpetal: (%.3f, %.3f)\n', Q(1), Q(2));


    end
  end
end
