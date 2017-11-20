warning('off','all');
clear all;
close all;
clc;

% Introduce PV Setpoint in Simulink model !!!

T_EMS   = 600;
T_intra =  30;

p_time_sim = 600;
t_init_dies = 10;
t_init = 20;
t_final = 620;


% load('../../Data/Generated Data/5 - Optimization/solutions/sol_1');
load('../../Data/Generated Data/5 - Optimization/solutions/sol_65');
load('../../Data/Generated Data/1 - Secondly/cons_seg');
load('../../Data/Generated Data/1 - Secondly/gen_seg');

n_diesels = sum(ON_dies(1,:));

num_dies_sim = zeros(t_init+p_time_sim,2);
num_dies_sim(:,1) = 1:(t_init+p_time_sim);
num_dies_sim(:,2) = repmat(sum(ON_dies(1,:)),t_init+p_time_sim,1);
% num_dies_sim(:,2) = [repmat(10,300,1);repmat(5,320,1)];
 

consum_sim = zeros(t_init+p_time_sim,2);
consum_sim(:,1) = 1:(t_init+p_time_sim);
% consum_sim(:,2) = [zeros(t_init_dies,1); repmat(cons_seg(1),t_init-t_init_dies,1); cons_seg(1:p_time_sim,1)]*1e3;
consum_sim(:,2) = [zeros(t_init_dies,1); repmat(cons_seg(T_EMS*64+1),t_init-t_init_dies,1); cons_seg((1:p_time_sim)+T_EMS*64,1)]*1e3;

potmax_pv_sim = zeros(t_init+p_time_sim,2);
potmax_pv_sim(:,1) = 1:(t_init+p_time_sim);
% potmax_pv_sim(:,2) = [zeros(t_init_dies,1); repmat(gen_seg(1),t_init-t_init_dies,1); gen_seg(1:p_time_sim,1)]*1e3;
potmax_pv_sim(:,2) = [zeros(t_init_dies,1); repmat(gen_seg(T_EMS*64+1),t_init-t_init_dies,1); gen_seg((1:p_time_sim)+T_EMS*64,1)]*1e3;

Setp_Batt = mean(P_bat_set(1,:));

bat_set_sim = zeros(t_init+p_time_sim,2);
bat_set_sim(:,1) = 1:(t_init+p_time_sim);
bat_set_sim(:,2) = [zeros(t_init_dies,1); repmat(P_bat_set(1,1),t_init-t_init_dies,1); reshape(repmat(P_bat_set(1,:),T_intra,1),[T_EMS,1])]*1e3;

pv_set_sim = zeros(t_init+p_time_sim,2);
pv_set_sim(:,1) = 1:(t_init+p_time_sim);
pv_set_sim(:,2) = [zeros(t_init_dies,1); repmat(P_PV_set(1,1),t_init-t_init_dies,1); reshape(repmat(P_PV_set(1,:),T_intra,1),[T_EMS,1])]*1e3;


% potmax_pv_sim - var
% consum_sim    - var
% n_diesels     - const (change)
% Setp_Batt     - const (change)

clear interval ON_dies P_bat_set P_dies P_PV P_PV_set SOC_bat cons_seg gen_seg status



%%
parameters_balanc;
sim('HEMS_v2')

%%
% SOLUTION
f_max = max(F_HZ.Data(F_HZ.Time>t_init));
f_min = min(F_HZ.Data(F_HZ.Time>t_init));

SOC_0_next = SOC_act.Data(end);

% f = F_HZ(F_HZ.Time>t_init);
