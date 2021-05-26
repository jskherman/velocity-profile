% List of questions to ask the user for the system conditions
prompt = {"What is the radius of the pipe (in meters)?",
            "What is the length of the pipe (in meters)?",
            "What is the angle of the pipe relative to the horizontal (in radians)?",
            "What is the density of the fluid (in kg/m^3)?",
            "What is the viscosity of the fluid (in Pa.s)?"
            "What is the upstream pressure (in pascals)?",
            "What is the downstream pressure (in pascals)?",
            };

% Default values for the conditions
defaults = {"0.1", "10", "pi/6", "1000", "10.00", "101325", "100000"};
rc = [1];

% Prompt for conditions of the system to be input
dims = inputdlg (prompt, 'Specify conditions of the system', rc,...
    defaults);

% Look for errors
try
    % Store the given data in variables as a number            
    R = str2num(dims{1});       % Radius of the pipe
    L = str2num(dims{2});       % Length of the pipe
    theta = str2num(dims{3});   % Angle of the pipe
    rho = str2num(dims{4});     % Density of the fluid
    mu = str2num(dims{5});      % Viscosity of the fluid
    p0 = str2num(dims{6});      % Upstream pressure
    pL = str2num(dims{7});      % Downstream pressure

catch err
    % In case of error by cancelling show text box of error
    helpdlg ('Canceled by user', 'Information');

    % Clear variables and end script through error
    clear all;
    error("Input was cancelled. Operation aborted.\n\n")
end

% Start check for other errors:
% Check to see if all variables have values and not empty
if isempty(R) || isempty(L) || isempty(theta) ||  isempty(rho) ||...
   isempty(mu) ||  isempty(p0) || isempty(pL)

    % If there is an empty variable, abort script and inform the user
    clear all;
    errordlg("\nOperation aborted: Incomplete input was given. Please specify.\n\n", "Error");
    error("Incomplete input was given. Please specify.\n\n")

% Check to see if user gave impossible conditions for the system
elseif R == 0 || L == 0 || rho == 0 ||  mu == 0 ||  p0 == 0
    % If true, abort script and inform the user
    clear all;
    errordlg("\nInvalid parameters: Please specify values other than zero.\n\n", "Error");
    error("\nInvalid parameters. Please specify values other than zero.\n\n")
endif

dr = 0.01;      % Specify the amount to increment r
r = [0:dr:1];   % Generate a row vector with values of r from 0 to 1,
r = R.*r;       % Create range of r values that range from 0 to the
                % radius of the pipe

% Calculate the pressures and gravitational terms
P0 = fancyP(p0, rho, 0, theta);
PL = fancyP(pL, rho, L, theta);

% Calculate the viscous-momentum flux
flux = ( P0 - PL ) .* (r / 2.*L);
fluxmax = max(flux);    % Find the max momentum flux

% Calculate the velocity at every point r to create the profile
velocity = ( ( (P0-PL) .* R.^2 ) / (4 .* mu .* L) ) *...
    (1 - (r./R).^2 ); 

% Calculate the max and average velocity
vmax =  ( ( P0 - PL ) .* R^2 ) ./ (4 .* mu .* L);
vavg = 0.5 .* vmax;

% Calculate the mass and volumetric flow rate
Q = (pi .* (P0 - PL) .* R.^4) ./ (8 .* mu .* L) ;
mdot = rho .* Q;

% Check if flow is laminar
NRe = (rho .* 2 .* R .* vmax ./ mu);     % Calculate Reynold's number

if NRe <= 2300
    % If laminar, do nothing

elseif NRe <= 2900
    % If not laminar and in transition region,
    % Warn the user that the flow may not be laminar
    warndlg(sprintf("\nThe Reynolds number is %g.\nThe flow may not be laminar (which breaks the assumption).\n\n", NRe), "Warning");
else
    % If turbulent flow, display an error that flow is not laminar
    errordlg(sprintf("\nOperation aborted: The Reynolds number is %.3g.\nThe flow is not laminar with the given conditions.\n\n", NRe), "Error");
    error("The flow is not laminar with the given conditions.\n\n");
endif

% Display results
helpdlg (sprintf ('Results:\n\nMaximum viscous-Momentum Flux = %.3g pascals\nMaximum Velocity = %.3g meters per second\nAverage Velocity = %.3g meters per second\nVolumetric Flow Rate = %.3g cubic meters per second\nMass Flow Rate = %.3g kilograms per second',...
  fluxmax, vmax, vavg, Q, mdot), 'Answer');

vprime = velocity./vmax;
rprime = r./R;

% Visualize the profiles
figure;
subplot(2, 1, 1);
plot(flux, rprime);                     % Plot momentum flux vs radius
title("Momentum Flux Profile")
xlabel("Viscous-Momentum Flux ({\\tau}/Pa)"); 
ylabel("Relative distance from \nthe center of the pipe (r/R)");

subplot(2, 1, 2);
plot(velocity, rprime);                 % Plot velocity vs radius
title("Velocity Profile")
xlabel("Velocity (m/s)"); 
ylabel("Relative distance from \nthe center of the pipe (r/R)");