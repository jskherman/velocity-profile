g = 9.80665;    % acceleration due to gravity, m/s^2

% List of questions to ask the user for the system conditions
prompt = {"What is the height of the film (in meters)?",
            "What is the width of the film (in meters)?",
            "What is the angle of the surface relative to the horizontal (in radians)?",
            "What is the density of the fluid (in kg/m^3)?",
            "What is the viscosity of the fluid (in Pa.s)?"
            };

% Default values for the conditions
defaults = {"0.1", "5", "pi/6", "1000", "10.00"};
rc = [1];

% Prompt for conditions of the system to be input
dims = inputdlg (prompt, 'Specify conditions of the system',
    rc, defaults);

% Look for errors
try
    % Store the given data in variables as a number
    delta = str2num(dims{1});   % Thickness of the film
    w = str2num(dims{2});       % Width of the film
    theta = str2num(dims{3});   % Angle of film
    rho = str2num(dims{4});     % Density of fluid
    mu = str2num(dims{5});      % Viscosity of fluid

catch err
    % In case of error by cancelling show text box of error
    helpdlg ('Cancelled by user.', 'Information');

    % Clear variables and end script through error
    clear all;  
    error("Input was cancelled. Operation aborted.\n\n")
end

% Start check for other errors:
% Check to see if all variables have values and not empty
if isempty(delta) || isempty(w) || isempty(theta) || isempty(rho)...
|| isempty(mu)
    % If there is an empty variable, abort script and inform the user
    clear all;  % Clear variables
    errordlg("\nOperation aborted: Incomplete input was given. Please specify.\n\n", "Error");
    error("Incomplete input was given. Please specify.\n\n")

% Check to see if user gave impossible conditions for the system
elseif delta == 0 || w == 0 || rho == 0 ||  mu == 0
    % If true, abort script and inform the user
    clear all;
    errordlg("\nInvalid parameters: Please specify values other than zero.\n\n", "Error");
    error("\nInvalid parameters. Please specify values other than zero.\n\n")
endif

dx = 0.01;      % Specify the amount to increment x
x = [0:dx:1];   % Generate a row vector with values of x from 0 to 1,
                % x is the relative distance from the solid surface
x = delta.*x;   % Create range of x values that range from 0 to the
                % height of the film

% Calculate the viscous-momentum flux
flux = rho .* g .* sin(theta) .* x;
fluxmax = max(flux);    % Find the max momentum flux

% Calculate the velocities:
% Calculate the velocity at every point x to create the profile
velocity = (rho .* g .* sin(theta) .* (delta .^ 2) ./ (2 .* mu) ) ...
    .* (1 - (x ./ delta).^2 );

% Calculate the max velocity
vmax = (rho .* g .* sin(theta) .* (delta .^ 2) ./ (2 .* mu) ); 

% Calculate the average velocity
vavg = vmax .* (2 ./ 3);    

% Calculate the volumetric flow rate
Q = (rho .* g .* sin(theta) .* (delta .^ 3) .* w ./ (3 .* mu) );

% Calculate the mass flow rate
mdot  = rho .* Q;

% Check if flow is laminar
NRe = (rho .* delta .* vmax ./ mu);     % Calculate Reynold's number

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

xprime = x ./ delta;    % Create a range of values to denote the
                        % film's relative distance from the surface
vprime = velocity  ./ vmax;     % Create a velocity profile relative
                                % to the max velocity

% Visualize the profiles
figure;
subplot(2, 1, 1);
plot(flux, xprime);      % Plot momentum flux vs distance from surface
title("Momentum Flux Profile")
xlabel("Viscous-Momentum Flux ({\\tau}/Pa)"); 
ylabel("Relative distance from \nthe solid surface");

subplot(2, 1, 2);
plot(velocity, xprime);  % Plot velocity vs distance from surface
title("Velocity Profile")
xlabel("Velocity (m/s)"); 
ylabel("Relative distance from \nthe solid surface");
