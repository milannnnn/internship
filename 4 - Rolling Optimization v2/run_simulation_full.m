clear all;
clear simulate_PF;
close all;
clc;

warning('off','all');

my_params = load('../../Data/System Params/params');
T_EMS   = (24*3600)/my_params.N_EMS;
T_intra =  T_EMS/my_params.N_intra;
clear my_params;

k_st = 01;
k_en = 96;
% k_st = 1;
% k_en =70;

k = k_en-k_st+1;

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

load(['../../Data/Generated Data/5 - Optimization/solutions/sol_' num2str(k_st)]);
% load('../../Data/Generated Data/5 - Optimization/scenarios/scen_1');
load('../../Data/Generated Data/1 - Secondly/cons_seg');
load('../../Data/Generated Data/1 - Secondly/gen_seg');

p1_time_sim = 1+(k_st-1)*T_EMS;
p2_time_sim = k_en*T_EMS;

% Real secondly consumption data (immediately fully loaded):
consum_sim = zeros(t_final,2);
consum_sim(:,1) = 1:t_final;
consum_sim(:,2) = [zeros(t_init_dies,1); repmat(cons_seg(p1_time_sim),t_init-t_init_dies,1); cons_seg(p1_time_sim:p2_time_sim,1)]*1e3;

% Real secondly potential PV data (immediately fully loaded):
potmax_pv_sim = zeros(t_final,2);
potmax_pv_sim(:,1) = 1:t_final;
potmax_pv_sim(:,2) = [zeros(t_init_dies,1); repmat(gen_seg(p1_time_sim),t_init-t_init_dies,1); gen_seg(p1_time_sim:p2_time_sim,1)]*1e3;

% Secondly data for number of online dies generators:
num_dies_sim = zeros(t_final,2);
num_dies_sim(:,1) = 1:t_final;
num_dies_sim(1:t_init,2) = repmat(sum(ON_dies(1,:)),t_init,1);

% Secondly data for number of online dies generators:
bat_set_sim = zeros(t_final,2);
bat_set_sim(:,1) = 1:t_final;
bat_set_sim(1:t_init,2) = [zeros(t_init_dies,1); repmat(P_bat_set(1,1),t_init-t_init_dies,1)]*1e3;

% Secondly data for PV setpoints:
pv_set_sim = zeros(t_final,2);
pv_set_sim(:,1) = 1:t_final;
pv_set_sim(1:t_init,2) = [zeros(t_init_dies,1); repmat(P_PV_set(1,1),t_init-t_init_dies,1)]*1e3;

% Secondly data for PV Generation:
P_PV_gen = mean(P_PV,3);
pv_gen_sim = zeros(t_final,2);
pv_gen_sim(:,1) = 1:t_final;
pv_gen_sim(1:t_init,2) = [zeros(t_init_dies,1); repmat(P_PV_gen(1,1),t_init-t_init_dies,1)]*1e3;

% Secondly data for AVERAGE LOAD CONSUMPTION over scenarios:
cons_avg_sim = zeros(t_final,2);
cons_avg_sim(:,1) = 1:t_final;
cons_avg_sim(1:t_init,2) = [zeros(t_init_dies,1); repmat(L_C(1,1),t_init-t_init_dies,1)]*1e3;

% Clear the unecessary data:
clear interval ON_dies P_bat_set P_dies P_PV P_PV_set SOC_bat status P_bat_cha P_bat_dis X_bat L_C P_PV_gen
clear cons_seg gen_seg

%% Loading Optimization Setpoints:

for q=1:(k_en+1-k_st)
    load(['../../Data/Generated Data/5 - Optimization/solutions/sol_' num2str(q-1+k_st)]);
    
    ts = t_init+(q-1)*T_EMS+(1:T_EMS);
    
    P_PV_gen = mean(P_PV,3);
    
    num_dies_sim(ts,2) = repmat(sum(ON_dies(1,:)),T_EMS,1);
    bat_set_sim(ts,2)  = reshape(repmat(P_bat_set(1,:),T_intra,1),[T_EMS,1])*1e3;
    pv_set_sim(ts,2)   = reshape(repmat(P_PV_set(1,:),T_intra,1),[T_EMS,1])*1e3;
    pv_gen_sim(ts,2)   = reshape(repmat(P_PV_gen(1,:),T_intra,1),[T_EMS,1])*1e3;
    cons_avg_sim(ts,2) = reshape(repmat(L_C(1,:),T_intra,1),[T_EMS,1])*1e3;
    
    clear interval ON_dies P_bat_set P_dies P_PV P_PV_set SOC_bat status P_bat_cha P_bat_dis X_bat L_C P_PV_gen
end

%% Run Simulation:

parameters_balanc;

% [checksum,details] = Simulink.BlockDiagram.getChecksum('HEMS_v2')
load_system('HEMS_v2');
set_param('HEMS_v2', 'StopTime', sprintf('%d',t_final));
tic;
sim('HEMS_v2');
toc;

% % f_max = max(F_HZ.Data(F_HZ.Time>t_init));
% % f_min = min(F_HZ.Data(F_HZ.Time>t_init));
SOC_0_next = SOC_act.Data(end)

%% Test Scheme:
% clc;
% for q = 2:k
%     my_prm = load(['../../Data/Generated Data/5 - Optimization/scenarios/scen_' num2str(q)]);
%     SOC_act.Data(SOC_act.Time==(t_init+max((q-2),0)*T_EMS)) - my_prm.SOC_init
% end