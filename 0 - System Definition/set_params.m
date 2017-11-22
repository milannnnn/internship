clear all;
close all;
clc;

%% Parameters:

% % ### Simulation (5 MIN):
% N_scen  =   5; % num of different scenations
% N_EMS   = 288; % num of remaining EMS   intervals (opt. executions)
% N_intra =  10; % num of remaining Intra intervals (opt. resolution)
% N_firm  =  36; % firm margin restriction (3h)
% delta_t = 0.5/60; % 30s (in hours)

% % ### Simulation (10 MIN):
% N_scen  =   5; % num of different scenations
% N_EMS   = 144; % num of remaining EMS   intervals (opt. executions)
% N_intra =  20; % num of remaining Intra intervals (opt. resolution)
% N_firm  =  18; % firm margin restriction (3h)
% delta_t = 0.5/60; % 30s (in hours)

% ### Simulation (15 MIN):
N_scen  =    5; % num of different scenations
N_EMS   =   96; % num of remaining EMS   intervals (opt. executions)
N_intra =   15; % num of remaining Intra intervals (opt. resolution)
N_firm  =   12; % firm margin restriction (3h)
delta_t = 1/60; % 1min (in hours)

% ### Diesel Gen:
N_dies  =  12; % num of diesel generators
P_dies_max = 1100.0; % kW (of 1 unit)
P_dies_min = 0.3*P_dies_max;
marge_dies = 2000;

% ### Batteries:
Cap_bat   = 4400;       % kWh
P_bat_max = 2200.0;     % 
P_bat_min = -P_bat_max; % 
eta_bat  = 0.95;        % 
SOC_min  = 0.0;         % 
SOC_max  = 1.0;         % 
SOC_init = 0.9;

% ### PV Generation:
P_PV_inst = 15000;

% ### Frequency:
f_min = 48.5;
f_max = 51.5;

save('../../Data/System Params/params');

%%

% my_params = load('../../Data/System Params/params');
