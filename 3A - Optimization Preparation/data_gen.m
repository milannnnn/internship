clear all;
close all;
clc;

%% Load Scenarios:

load('../../Data/Generated Data/2 - Scenarios/cons_scen.mat')
load('../../Data/Generated Data/2 - Scenarios/gen_scen.mat')

interval = 1;

%% Parameters:

% We need to boost the system up to 10 generators (infeasable with 9)
N_dies  =  12; % num of diesel generators
N_scen  =   5; % num of different scenations

% %  5 MIN Data:
% N_EMS   = 288; % num of remaining EMS   intervals (opt. executions)
% N_intra =  10; % num of remaining Intra intervals (opt. resolution)
% N_firm  =  36; % firm margin restriction (3h)
% delta_t = 0.5/60; % 30s

% % 10 MIN Data:
N_EMS   = 144; % num of remaining EMS   intervals (opt. executions)
N_intra =  20; % num of remaining Intra intervals (opt. resolution)
N_firm  =  18; % firm margin restriction (3h)
delta_t = 0.5/60; % 30s in hours

% 15 MIN Data:
% N_EMS   =   96; % num of remaining EMS   intervals (opt. executions)
% N_intra =   15; % num of remaining Intra intervals (opt. resolution)
% N_firm  =   12; % firm margin restriction (3h)
% delta_t = 1/60; % 1min

% Upper and Lower bounds:
P_bat_min = -2200.0;
P_bat_max =  2200.0;
eta_bat  = 0.95;
SOC_min  = 0.0;
SOC_max  = 1.0;
SOC_init = 0.9;
Cap_bat  = 2200;
P_dies_max = 1100.0;
% P_dies_min = 0.3*P_dies_max;
P_dies_min = 0.15*P_dies_max;
P_PV_inst = 20000;

f_min = 48;

load('../../Data/Generated Data/4 - Frequency/theta');

marge_dies = 2000;

L_C  = shape_to(cons_scen(:,:,interval),N_intra);
L_PV = shape_to( gen_scen(:,:,interval),N_intra);

% rng('default');
% L_PV = 5000.0+5000*rand(N_EMS,N_intra,N_scen); % PV scenarios
% L_C  = 2500.0+7500*rand(N_EMS,N_intra,N_scen); % Load scenarios

clear('cons_scen','gen_scen','scen');

save('../../Data/Generated Data/5 - Optimization/scenarios/scen_test');

%% Load data:

clear all;
close all;

load('../../Data/Generated Data/5 - Optimization/solutions/sol_test');

a = sum(ON_dies')';
figure();
stairs(a);

SOC = reshape(SOC_bat',[144*20 1]);
figure();
plot(SOC);

PV_set =  reshape(P_PV_set',[144*20 1]);
figure();
plot(PV_set);
