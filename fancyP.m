% USAGE: P = fancyP(pressure, density, z, theta)
%
% Returns the sum of the pressure and gravitational terms in
% a shell momentum balance.
%
% [pressure] is in pascals
% [density] is in kg/m^3
% [z] is in meters
% [theta] is the angle of the pipe with respect to
%         the horizontal (in radians)
%---------------------------------------------------------------------

function P = fancyP(pressure, density, z, theta)
    g = 9.80665;                % m/s^2, acceleration due to gravity
    P = pressure - density .* g .* z .* sin(theta);
endfunction