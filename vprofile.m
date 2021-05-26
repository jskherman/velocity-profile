%-------------------------------------------------------------------%
%       USAGE: vprofile
%
%     AUTHORS: Arlie Brual, Je Sian Keith Herman, Giane Manoguid
%        DATE: May 26, 2020
%    MODIFIED: Arlie Brual, Je Sian Keith Herman, Giane Manoguid
%        DATE: May 26, 2020
%   
% DESCRIPTION: This function calculates the conditions of fluid's 
%              laminar flow. It plots the viscous momentum-flux
%              and velocity profiles of the fluid in a circular pipe,
%              annulus, or falling film.
%   
%      INPUTS: sel = 'The index of the option chosen by the user,
%                     from 0 to 2 depending if it is a circular pipe,
%                     annulus, or falling film.'
%
%              Initial conditions specific to the system chosen. See
%              cpipe.m, annulus.m, and film.m for details.
%
%     OUTPUTS: A dialog box with values on
%                  - The maximum viscous-momentum flux
%                  - The maximum velocity achieved by the fluid
%                  - The average velocity of the fluid
%                  - The volumetric flow rate
%                  - The mass flow rate
%
%              A figure that plots the viscous-momentum flux profile
%              and the velocity profile of the fluid in the system.
%--------------------------------------------------------------------%

% Clear all variables, close open figures, and clear terminal
clear all; close all; clc;
format short g;             % Set number formatting

% Create list of options (cell array)
my_options = {"Circular Pipe", "Annulus", "Falling Film"};

% Set prompt
prompta = "Which system do you want to visualize?";

% Trigger option selection dialog box for list
[sel, ok] = listdlg ("ListString", my_options,
                     "SelectionMode", "Single",
                     "PromptString", prompta);

% Start logic for script execution depending on the choice made
if (ok == 1)
    option = my_options{sel};
    printf("You selected: %s\n\n", option);

    % Execute the appropriate script depending on the choice
    if sel == 1;    
        cpipe;
    elseif sel == 2;
        annulus;    
    elseif sel == 3;
        film;
    else
    endif
else
  disp ("You cancelled.\n");
endif
