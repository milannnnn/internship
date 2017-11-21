function [] = generate_data( interval )
%GENERATE_DATA Summary of this function goes here
%   Detailed explanation goes here

warning('off','all');

load('../../Data/Generated Data/2 - Scenarios/cons_scen.mat')
load('../../Data/Generated Data/2 - Scenarios/gen_scen.mat')

%% Parameters:

% We need to boost the system up to 10 generators (infeasable with 9)
N_dies  =  12; % num of diesel generators
N_scen  =   5; % num of different scenations

% % 10 MIN Data:
N_EMS   = 144; % num of remaining EMS   intervals (opt. executions)
N_intra =  20; % num of remaining Intra intervals (opt. resolution)
N_firm  =  18; % firm margin restriction (3h)
delta_t = 0.5/60; % 30s in hours

% Upper and Lower bounds:
P_bat_min = -2200.0;
P_bat_max =  2200.0;
eta_bat  = 0.95;
SOC_min  = 0.0;
SOC_max  = 1.0;
SOC_init = find_SOC_0(interval);
Cap_bat  = 1120;
P_dies_max = 1100.0;
P_dies_min = 0.3*P_dies_max;
P_PV_inst = 20000;

f_min = 48;

load('../../Data/Generated Data/4 - Frequency/theta');

marge_dies = 2000;

L_C  = shape_to(cons_scen(:,:,interval),N_intra);
L_PV = shape_to( gen_scen(:,:,interval),N_intra);

% save('../../Data/Generated Data/5 - Optimization/scenarios/scen_test');
save(['../../Data/Generated Data/5 - Optimization/scenarios/scen_' num2str(interval)]);

end

