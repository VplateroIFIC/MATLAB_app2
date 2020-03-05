%% PetalCoordinates
%
% This class allows to transform from gantry to petal coordinates
% and back. It will also provide the coordinates of the sensor
% centers in the petal as well as the sensor fiducial coordinates.
%
% The petal reference system will be defined by the two fiducials in
% the petal locators and the Y axis. We assume that the Y axis goes
% along the radius of the petal. The X axis goes across the petal
% sensors.
%
% The origin of the petal reference will be the fiducial in the lower
% petal locator.
%

classdef PetalCoordinates < handle
   properties
      M                       % The transform gantry->petal
      Minv                    % Inverse of the above petal->gantry
      nominal_upper_locator   % Nominal position of upper locator (petal coord)
      nominal_lower_locator   % Nominal positiin of lower locator (petal coord)
      nominal_angle           % Nominal angle between locators (wrt lower locator)
      petal_rotation          % Rotation of sensor assembly in petal
      sensor_data             % Structure with sensor data (Radiuse, angle, etc.)
      sensor_transforms       % A list with the transforms to locate sensors in petal
      sensor_positions        % POsitions of sensor center in petal coordinates
      sensor_positions_gantry % positions of sensor centers in gantry coordinates
      nom_fiducials           % Nominal positions of fiducials (in sensor coordinates)
      fiducials               % Positions of fiducials in petal coordinates (a Map)
      fiducials_gantry        % Positions of fiducials in gantry coordinates (a Map)
   endproperties

  methods
      function obj = PetalCoordinates()
         % constructor
         % Sets initial values
         %
         obj.sensor_data = struct(
            'Ri', {384.050, 489.373, 575.144, 638.159, 756.451, 867.012},
            'R',  {438.614, 534.639, 609.405, 697.899, 812.471, 918.749},
            'Ro', {488.873, 574.644, 637.659, 755.951, 866.512, 968.235},
            'angle', {0.000000, 0.000000, 0.000000, 0.050397, 0.050377, 0.050381}
            );

         obj.M = transform2D();
         obj.petal_rotation = -3.5e-3;
         obj.nominal_upper_locator = [131.104; 968.526];
         obj.nominal_lower_locator = [0; 382.000];
         diff = obj.nominal_upper_locator - obj.nominal_lower_locator;
         obj.nominal_angle = atan2(diff(2), diff(2));

         obj.sensor_transforms = containers.Map('KeyType', 'int32');
         obj.sensor_positions = [];
         obj,sensor_positions_gantry = [];
         obj.fiducials_gantry = containers.Map();
         obj.fiducials = containers.Map();

         read_fiducials(obj, 'EC-sensor-fiducials.xlsx');
      end  % PetalCoordinates

      function read_fiducials(obj, fname)
         % reads fiducials from excel file
         % Read from the XLSX file and store the positions of the fiducials
         %
         printf('Reading fiducials from %s\n', fname);

         [P, ~, R, ~] = xlsread(fname,1, 'B1:E265');
         nfid = size(P)(1);
         obj.nom_fiducials = containers.Map();
         for i = 1:nfid
           ID = cell2mat(R(i+1, 4));
           obj.nom_fiducials(ID) = [P(i,1) P(i, 2)]/1000.0;
         endfor
      end % read_fiducials

      function set_references(obj, upper_locator, lower_locator)
         % Sets the petal reference.
         %
         % Receives as input the two fiducials of the
         % petal locators. This will define the petal coordinate
         % system. In this system we assume that the petal in
         % "vertical".
         %
         % @param upper_locator Position in Gantry of the upper
         %                      locator (wide part of petal)
         %
         % @param lower_locator Position in gantry of the lower
         %                      locator. This will be, in fact, the
         %                      origin of the petal reference system.
         %

         translate(obj.M, -lower_locator);

         %
         % Transform upper_locator and compute the actual phi angle
         %
         P = obj.M.M * [upper_locator ; 1];

         phi = obj.nominal_angle - atan2(P(2), P(1));
         rotate(obj.M, phi);

         inv = inverse(obj.M.M);
         obj.Minv = inv;

         %
         % Get coordinates of sensors in the Petal reference and store the transform matrix
         %
         obj.sensor_transforms = containers.Map('KeyType', 'int32', 'ValueType', 'any');
         obj.sensor_positions = [];
         obj.sensor_positions_gantry = [];
         obj.fiducials_gantry = containers.Map();
         obj.fiducials = containers.Map();

         cntr = int32(0);
         for iring = 1:6
            nsensor = 1;
            if (iring > 3)
               nsensor = 2;
            endif

            for isensor = 1:nsensor
               angle = obj.sensor_data(iring).angle;
               if (isensor == 1)
                  angle = -angle;
               endif

               angle += obj.petal_rotation;

               % The sensor transform
               M = transform2D();
               translate(M, [0 obj.sensor_data(iring).R]);
               rotate(M, angle);
               translate(M, -obj.nominal_lower_locator);
               obj.sensor_transforms(cntr) = M;

               % The sensor position (the center fof the wafer) in the Petal
               P = M.M*[0;0;1];
               obj.sensor_positions = [obj.sensor_positions P];

               % The sensor position in the gantry coordinates
               Pg = inv * P;
               obj.sensor_positions_gantry = [obj.sensor_positions_gantry Pg];

               cntr++;

               % Now the position of the fiducials of this incartation of the sensor.
               % Could be done more efficiently...
               sname = sprintf('R%d', iring-1);
               for k = keys(obj.nom_fiducials)
                  k = cell2mat(k);
                  fN = obj.nom_fiducials(k);
                  if (!isempty(strfind(k, sname)))
                     new_key = sprintf('%s_%d', k, isensor);
                     P = M.M * [fN(1); fN(2); 1];
                     obj.fiducials(new_key) = P;
                     Q = inv * P;
                     obj.fiducials_gantry(new_key) = Q;
                 endif
               endfor
            endfor
         endfor
       end
  endmethods

endclassdef %PetalCoordinates
