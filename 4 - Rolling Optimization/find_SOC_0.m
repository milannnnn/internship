function [ SOC_0 ] = find_SOC_0( my_interval )
%FIND_SOC Summary of this function goes here
%   Detailed explanation goes here

if     my_interval==1
    
    SOC_0 = 0.9;
    
elseif my_interval==2
    
    load('../../Data/Generated Data/5 - Optimization/solutions/sol_1');
    SOC_act = sim_SOC_end(my_interval-2);
    SOC_0 = SOC_bat(2,1);
    
else
    
    load(['../../Data/Generated Data/5 - Optimization/solutions/sol_' num2str(my_interval-1)]);
    SOC_act = sim_SOC_end(my_interval-2);
    SOC_0 = SOC_bat(2,1) - (SOC_bat(2,1)-SOC_act);
    % fprintf('%.4f vs. %.4f',SOC_bat(2,1),SOC_0);
    SOC_0 = min(max(0,SOC_0),1);
    
end

end

function [SOC_end] = sim_SOC_end(k)

my_params = load('../../Data/System Params/params');
T_EMS   = (24*3600)/my_params.N_EMS;
T_intra =  T_EMS/my_params.N_intra;
clear my_params;

% Simulation times:
p_time_sim = T_EMS*k;
t_init_dies = 10;
t_init = 20;
t_final = t_init+p_time_sim;

% ### Initialization:

load('../../Data/Generated Data/5 - Optimization/solutions/sol_1');
load('../../Data/Generated Data/1 - Secondly/cons_seg');
load('../../Data/Generated Data/1 - Secondly/gen_seg');
my_params = load('../../Data/System Params/params');

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

% Flag for activating minimum dies generation constraint (required for initialization):
GS_min_ratio_sim = zeros(t_final,2);
GS_min_ratio_sim(:,1) = 1:t_final;
GS_min_ratio_sim(:,2) = [zeros(t_init,1); repmat(my_params.P_dies_min/my_params.P_dies_max,t_final-t_init,1)];

% Clear the unecessary data:
clear interval ON_dies P_bat_set P_dies P_PV P_PV_set SOC_bat status P_bat_cha P_bat_dis X_bat
clear cons_seg gen_seg my_params

% ### Loading Optimization Setpoints:

for q=1:k
    load(['../../Data/Generated Data/5 - Optimization/solutions/sol_' num2str(q)]);

    % ts = t_init+(q-1)*T_EMS+(1:T_EMS);
    ts = int32(t_init)+int32(q-1)*int32(T_EMS)+int32(1:T_EMS);

    num_dies_sim(ts,2) = repmat(sum(ON_dies(1,:)),T_EMS,1);
    bat_set_sim(ts,2) = reshape(repmat(P_bat_set(1,:),T_intra,1),[T_EMS,1])*1e3;
    pv_set_sim(ts,2) = reshape(repmat(P_PV_set(1,:),T_intra,1),[T_EMS,1])*1e3;

    clear interval ON_dies P_bat_set P_dies P_PV P_PV_set SOC_bat status P_bat_cha P_bat_dis X_bat
end

% ### Run Simulation Full:

% parameters_balanc;
% options = simset('SrcWorkspace','current');
% load_system('HEMS_v2')
% set_param('HEMS_v2', 'StopTime', sprintf('%d',t_final));
% sim('HEMS_v2',[],options);

% ### Run Simulation Partial:

clear simulate_PF;

parameters_balanc;
options = simset('SrcWorkspace','current');
load_system('HEMS_part');
if k == 0
    set_param('HEMS_part','LoadInitialState','off');
    set_param('HEMS_part', 'StartTime', sprintf('%d',0));
else
    load(['../../Data/Generated Data/5 - Optimization/states/state_' num2str(k-1)]);
    set_param('HEMS_part','LoadInitialState','on','InitialState','prev_st');
    set_param('HEMS_part', 'StartTime', sprintf('%d',t_final-T_EMS));
end
set_param('HEMS_part','SaveFinalState','on','FinalStateName','prev_st','SaveCompleteFinalSimState','off');
set_param('HEMS_part', 'StopTime', sprintf('%d',t_final));
sim('HEMS_part',[],options)
save(['../../Data/Generated Data/5 - Optimization/states/state_' num2str(k)],'prev_st');

% ### Return SOC:

% save_system('HEMS_part');
% close_system('HEMS_part');

SOC_end = SOC_act.Data(end);

end