% List of questions to ask the user for the system conditions
prompt = {"What is the outer radius of the pipe (in meters)?",
            "What is the inner radius of the pipe (in meters)?",
            "What is the length of the pipe (in meters)?",
            "What is the angle of the pipe relative to the horizontal (in radians)?",
            "What is the density of the fluid (in kg/m^3)?",
            "What is the viscosity of the fluid (in Pa.s)?"
            "What is the upstream pressure (in pascals)?",
            "What is the downstream pressure (in pascals)?",
            };

% Default values for the conditions
defaults = {"1", "0.25", "10", "pi/6", "1000", "10.00", "101325", "100000"};
rc = [1];

% Prompt for conditions of the system to be input
dims = inputdlg (prompt, 'Specify conditions of the system',
    rc, defaults);

% Look for errors
try
    % Store the given data in variables as a number    
    R = str2num(dims{1});       % Outer radius of the annulus
    k = str2num(dims{2});       % Inner radius of the annulus
    L = str2num(dims{3});       % Length of the pipe 
    theta = str2num(dims{4});   % Angle of the pipe
    rho = str2num(dims{5});     % Density of the fluid
    mu = str2num(dims{6});      % Viscosity of the fluid
    p0 = str2num(dims{7});      % Upstream pressure
    pL = str2num(dims{8});      % Downstream pressure

catch err
    % In case of error by cancelling show text box of error
    helpdlg ('Cancelled by user.', 'Information');

    % Clear variables and end script through error
    clear all;  % Clear variables and end script
    error("Input was cancelled. Operation aborted.\n\n")
end

% Start check for other errors:
% Check to see if all variables have values and not empty
if isempty(R) || isempty(k) || isempty(L) || isempty(theta) ||...
   isempty(rho) ||  isempty(mu) ||  isempty(p0) || isempty(pL)
    
    % If there is an empty variable, abort script and inform the user
    clear all;
    errordlg("\nOperation aborted: Incomplete input was given. Please specify.\n\n", "Error");
    error("Incomplete input was given. Please specify.\n\n")

% Check to see if user gave impossible conditions for the system
elseif R == 0 || k == 0 || L == 0 || rho == 0 ||  mu == 0 ||  p0 == 0
    % If true, abort script and inform the user
    clear all;
    errordlg("\nInvalid parameters: Please specify values other than zero.\n\n", "Error");
    error("\nInvalid parameters: Please specify values other than zero.\n\n")
elseif k > R;
    % Abort the script if the inner radius is larger than the outer
    clear all;
    errordlg("\nInvalid parameters:\nPlease specify an inner radius smaller than the outer radius.\n\n", "Error");
    error("Invalid parameters. Please specify an inner radius smaller than the outer radius.\n\n")
endif

dr = 0.01;      % Specify the amount to increment r
r = [0:dr:1];   % Generate a row vector with values of r from 0 to 1,
r = R.*r;       % Create range of r values that range from 0 to the
                % radius of the pipe

% Calculate a constant lambda, distance where the max velocity occurs
k = k./R;
kappa = ( (1-k.^2) ./ log(1./k) );
lambda = sqrt(kappa./2);

% Calculate the pressures and gravitational terms
P0 = fancyP(p0, rho, 0, theta);
PL = fancyP(pL, rho, L, theta);

% Calculate the viscous-momentum flux
flux = ((P0 - PL) .* R ./ (2 .* L) ) .* ((r./R) - ((kappa./2)...
    .* (R./r)) );
fluxmax = max(flux);    % Find the max momentum flux

% Calculate the velocity at every point r to create the profile
velocity = ((P0 - PL) .* R.^2 ./ (4 .* mu .* L)) .* (1 - (r./R).^2 ...
    - ( kappa .* log(R./r) ));

% Calculate the max and average velocity
vmax = ((P0 - PL) .* R.^2 ./ (4 .* mu .* L)) .* (1 - (lambda.^2)...
    .* (1 - log(lambda.^2)) );
vavg = ((P0 - PL) .* R.^2 ./ (8 .* mu .* L)) .* ( ((1-k.^4)...
    ./ (1-k.^2)) - kappa );

% Calculate the mass and volumetric flow rate
Q = (pi .* (P0 - PL) .* R.^4 ./ (8 .* mu .* L)) .* ( 1 - k.^4 -...
    (kappa .* (1-k.^2)) );
mdot = rho .* Q;

% Check if flow is laminar
% Calculate Reynold's number
NRe = (rho .* (R - lambda .* R) .* vmax ./ mu); 

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


% Print results
helpdlg (sprintf ('Results:\n\nMaximum viscous-Momentum Flux = %.3g pascals\nMaximum Velocity = %.3g meters per second\nAverage Velocity = %.3g meters per second\nVolumetric Flow Rate = %.3g cubic meters per second\nMass Flow Rate = %.3g kilograms per second',...
  fluxmax, vmax, vavg, Q, mdot), 'Answer');

vprime = velocity./vmax;
rprime = r./R;

% Calculate some limits to help with plotting
fluxmin = ((P0 - PL) .* R ./ (2 .* L) ) .* (((k.*R)./R) - ...
    ((kappa./2) .* (R./(k.*R))) );
vmin = ((P0 - PL) .* R.^2 ./ (4 .* mu .* L)) .* (1 - ((k.*R)./R).^2 ...
    - ( kappa .* log(R./(k.*R)) ));
boundary = (lambda.*R).*ones(size(flux));

% Visualize the profiles
figure;
subplot(2, 1, 1);
plot(flux, rprime), hold on;            % Plot momentum flux vs radius
plot(flux, boundary, 'r--');
xlim([fluxmin max(flux)]);
ylim([k max(rprime)]);
text((fluxmin.*0.9),(lambda .* R .* 1.1),
    "{\\lambda}R", "interpreter", "tex");
title("Momentum Flux Profile");
xlabel("Viscous-Momentum Flux ({\\tau}/Pa)"); 
ylabel("Relative distance from \nthe center of the pipe (r/R)");

subplot(2, 1, 2);
plot(velocity, rprime), hold on;             % Plot velocity vs radius
plot(flux, boundary, 'r--');
xlim([vmin vmax]);
ylim([k max(rprime)]);
text((vmax.*0.05),(lambda .* R .* 1.1),
    "{\\lambda}R", "interpreter", "tex");
title("Velocity Profile")
xlabel("Velocity (m/s)"); 
ylabel("Relative distance from \nthe center of the pipe (r/R)");

