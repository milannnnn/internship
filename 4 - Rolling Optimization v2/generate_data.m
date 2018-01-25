function [] = generate_data( interval )
%GENERATE_DATA Summary of this function goes here
%   Detailed explanation goes here

warning('off','all');

load('../../Data/Generated Data/2 - Scenarios/cons_scen.mat')
load('../../Data/Generated Data/2 - Scenarios/gen_scen.mat')

%% Parameters:

load('../../Data/System Params/params');
load('../../Data/Generated Data/4 - Frequency/theta');
load('../../Data/Generated Data/6 - Power Flows/psi_min');
load('../../Data/Generated Data/6 - Power Flows/psi_loss');

SOC_init = find_SOC_0(interval);

L_C  = shape_to(cons_scen(:,:,interval),N_intra);
L_PV = shape_to( gen_scen(:,:,interval),N_intra);

clear cons_scen gen_scen

save(['../../Data/Generated Data/5 - Optimization/scenarios/scen_' num2str(interval)]);

clear;

end

