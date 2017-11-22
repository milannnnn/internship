clear all;
close all;
clc;

%% Load Scenarios:

load('../../Data/Generated Data/2 - Scenarios/cons_scen.mat')
load('../../Data/Generated Data/2 - Scenarios/gen_scen.mat')

% interval = 1;
% figure(); hold all;
% plot(cons_scen(:,:,interval))
% plot( gen_scen(:,:,interval))
% grid on

%% Parameters:

load('../../Data/System Params/params');
load('../../Data/Generated Data/4 - Frequency/theta');

L_C  = shape_to(cons_scen(:,:,interval),N_intra);
L_PV = shape_to( gen_scen(:,:,interval),N_intra);

clear('cons_scen','gen_scen','scen');

save('../../Data/Generated Data/5 - Optimization/scenarios/scen_test');

%% Load data:

% clear all;
% close all;
% 
% load('../../Data/Generated Data/5 - Optimization/solutions/sol_test');
% 
% a = sum(ON_dies')';
% figure();
% stairs(a);
% 
% SOC = reshape(SOC_bat',[144*20 1]);
% figure();
% plot(SOC);
% 
% PV_set =  reshape(P_PV_set',[144*20 1]);
% figure();
% plot(PV_set);
