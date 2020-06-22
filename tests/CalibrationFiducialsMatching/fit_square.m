function sol = fit_square (vertex)
% fit_square fit a perfect square to the 4 centers of the circles. Used with fiducial matching for calibration plate.
% input: vertex: cell array with 4 points of the circles detected
% output: sol: array with the optimum value for the 4 fitted parameters (X, Y, width, rotation)
 
X0(1)=vertex{1}(1);
X0(2)=vertex{2}(1);
X0(3)=vertex{3}(1);
X0(4)=vertex{4}(1);

Y0(1)=vertex{1}(2);
Y0(2)=vertex{2}(2);
Y0(3)=vertex{3}(2);
Y0(4)=vertex{4}(2);

% condiciones iniciales (parece que no afectan mucho a la convergencia con este solver..)

cond_t0=[0.5 0.5 0 0.4];

% Implemento funcion %

fun = @(x)(X0(1)-(x(1)-(x(4)/sqrt(2))*cos(x(3)+pi/4)))^2+(Y0(1)-(x(2)-(x(4)/sqrt(2))*sin(x(3)+pi/4)))^2 ...
    + (X0(2)-(x(1)-(x(4)/sqrt(2))*cos(pi/4-x(3))))^2+(Y0(2)-(x(2)+(x(4)/sqrt(2))*sin(pi/4-x(3))))^2 ...
    + (X0(3)-(x(1)+(x(4)/sqrt(2))*cos(pi/4+x(3))))^2+(Y0(3)-(x(2)+(x(4)/sqrt(2))*sin(pi/4+x(3))))^2 ...
    + (X0(4)-(x(1)+(x(4)/sqrt(2))*cos(pi/4-x(3))))^2+(Y0(4)-(x(2)-(x(4)/sqrt(2))*sin(pi/4-x(3))))^2;
    
% Fijo número de iteraciones %

options = optimset('MaxFunEvals',1000);

% ejecuto el solver %

sol=fminsearch(fun,cond_t0,options);

end



