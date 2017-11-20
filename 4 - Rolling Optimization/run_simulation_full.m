clear all;
close all;
clc;

warning('off','all');


T_EMS   = 600;
T_intra =  30;

k = 2;

% Simulation times:
p_time_sim = T_EMS*k;
t_init_dies = 10;
t_init = 20;
t_final = t_init+p_time_sim;

%% Initialization:

% ####################################################################### %
% We initialize a no load period of 10s followed by const power period of %
% 10s to stabilize the system prior to real simulation, and then we load  %
% the real simulation data (first 20s just for system stabilization)!!!!  %
% ####################################################################### %
%        => FIRST 20s OF SIMULATION SHOULD BE DISREGARDED !!!             %
% ####################################################################### %

load('../../Data/Generated Data/5 - Optimization/solutions/sol_1');
load('../../Data/Generated Data/1 - Secondly/cons_seg');
load('../../Data/Generated Data/1 - Secondly/gen_seg');

% Real secondly consumption data (immediately fully loaded):
consum_sim = zeros(t_final,2);
consum_sim(:,1) = 1:t_final;
consum_sim(:,2) = [zeros(t_init_dies,1); repmat(cons_seg(1),t_init-t_init_dies,1); cons_seg(1:p_time_sim,1)]*1e3;

% Real secondly potential PV data (immediately fully loaded):
potmax_pv_sim = zeros(t_final,2);
potmax_pv_sim(:,1) = 1:t_final;
potmax_pv_sim(:,2) = [zeros(t_init_dies,1); repmat(gen_seg(1),t_init-t_init_dies,1); gen_seg(1:p_time_sim,1)]*1e3;

% Secondly data for number of online dies generators:
num_dies_sim = zeros(t_final,2);
num_dies_sim(:,1) = 1:t_final;
num_dies_sim(1:t_init,2) = repmat(sum(ON_dies(1,:)),t_init,1);

% Secondly data for number of online dies generators:
bat_set_sim = zeros(t_final,2);
bat_set_sim(:,1) = 1:t_final;
bat_set_sim(1:t_init,2) = [zeros(t_init_dies,1); repmat(P_bat_set(1,1),t_init-t_init_dies,1)]*1e3;

% Secondly data for number of online dies generators:
pv_set_sim = zeros(t_final,2);
pv_set_sim(:,1) = 1:t_final;
pv_set_sim(1:t_init,2) = [zeros(t_init_dies,1); repmat(P_PV_set(1,1),t_init-t_init_dies,1)]*1e3;

% Clear the unecessary data:
clear interval ON_dies P_bat_set P_dies P_PV P_PV_set SOC_bat status
clear cons_seg gen_seg

%% Loading Optimization Setpoints:

for q=1:k
    load(['../../Data/Generated Data/5 - Optimization/solutions/sol_' num2str(q)]);
    
    ts = t_init+(q-1)*T_EMS+(1:T_EMS);
    
    num_dies_sim(ts,2) = repmat(sum(ON_dies(1,:)),T_EMS,1);
    bat_set_sim(ts,2) = reshape(repmat(P_bat_set(1,:),T_intra,1),[T_EMS,1])*1e3;
    pv_set_sim(ts,2) = reshape(repmat(P_PV_set(1,:),T_intra,1),[T_EMS,1])*1e3;
    
    clear interval ON_dies P_bat_set P_dies P_PV P_PV_set SOC_bat status
end

%% Run Simulation:

parameters_balanc;
sim('HEMS_v2');