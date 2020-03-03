%%% Affine 2D
% This is a class encapsulating a 2D affine transform
% All transformations can be represented as 3x3 transformation
% matrices of the following form:
%    | a c e |
%    | b d f |
%    | 0 0 1 |
%
% Transformations map coordinates and lengths from a new coordinate system
% into a previous coordinate system:
%
%  | x_prev |    | a c e | | x_new |
%  | y_prev | =  | b d f | | y_new |
%  | 1      |    | 0 0 1 | | 1     |
%

classdef transform2D < handle
   properties
      M = [1, 0, 0; 0, 1, 0; 0, 0, 1];
   end

   methods
      function out = transform2D()
         out.M = [1, 0, 0; 0, 1, 0; 0, 0, 1];
      end

      function multiply(obj, T)
         % multiplies by another transform2D object
         obj.M = obj.M * T.M;
      end % multiply

      function translate(obj, V)
         % Adds a translation to the transform.
         % The translation is given as a 2D vector
         % A translation is equivalent to
         %      | 1 0 tx |
         %      | 0 1 ty |
         %      | 0 0 1  |
         %
         tmp = [1, 0, V(1);
               0, 1, V(2);
               0, 0, 1];
         obj.M = tmp * obj.M;
      end % translate
      
            function translateMirrorY(obj, V)
         % Adds a translation to the transform.
         % The translation is given as a 2D vector
         % A translation is equivalent to
         %      | 1 0 tx |
         %      | 0 1 ty |
         %      | 0 0 1  |
         %
         tmp = [1, 0, V(1);
               0, 1, -V(2);
               0, 0, 1];
         obj.M = tmp * obj.M;
      end % translate

      function scale(obj, sx, sy)
         % scales coordinates
         %
         % Scaling is eqivalent to
         %      | sx  0  0 |
         %      | 0   sy 0 |
         %      | 0   0  1 |
         %
         tmp = [sx,  0, 0;
               0, sy, 0;
               0,  0, 1];
         obj.M = tmp * obj.M;
      end  % scale

      function skew_x(obj, angle)
         % A skew transformation around the Y axis
         %      | 1           0  0 |
         %      | tan(angle)  1  0 |
         %      | 0           0  1 |
         %
         tmp = [ 1, 0, 0; tan(angle), 1, 0; 0, 0, 1];
         obj.M = tmp * obj.M;
      end %skew_x

      function skew_y(obj, angle)
         % A skew transformation around the Y axis
         %      | 1           0  0 |
         %      | tan(angle)  1  0 |
         %      | 0           0  1 |
         %
         tmp = [0, 0, 1; tan(angle), 1, 0; 0, 0, 1];
         obj.M = tmp * obj.M;
      end % skew_y

      function rotate(obj, angle)
         % A rotation around the origin is equivalent to
         %      | cos(a) -sin(a) 0 |
         %      | sin(a)  cos(a) 0 |
         %      | 0       0      1 |
         %
         tmp = [cos(angle), -sin(angle), 0;
               sin(angle), cos(angle), 0;
               0, 0, 1];
         obj.M = tmp * obj.M;
      end % rotate
      
       function rotateMirrorY(obj, angle)
         % A rotation around the origin with oposite y axis
         %      | cos(a) -sin(a) 0 |
         %      | -sin(a)  -cos(a) 0 |
         %      | 0       0      1 |
         %
         tmp = [cos(angle), -sin(angle), 0;
               -sin(angle), -cos(angle), 0;
               0, 0, 1];
         obj.M = tmp * obj.M;
      end % rotate

      function rotate_around_point(obj, angle, P)
         % A rotation around a point is equivalent to
         %     translate(P) rotate(angle) translate(-P)
         %
         translate(obj, -P);
         rotate(obj, angle);
         translate(obj, P);
      end %rotate_around_point

      end
end
