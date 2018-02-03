clear all;
close all;
clc;

%% 

load('../../Data/Generated Data/7 - Simulation/signals');

P_cons      = logsout.get('P_cons').Values*1e-6;            %
P_cons_for  = logsout.get('P_cons_for').Values*1e-6;        %

P_pv        = logsout.get('P_pv').Values*1e-6;              %
P_pv_avail  = logsout.get('P_pv_avail').Values*1e-6;        %
P_pv_set    = logsout.get('P_pv_set').Values*1e-6;          %
P_pv_opt    = logsout.get('P_pv_opt').Values*1e-6;          %

P_loss      = logsout.get('P_loss').Values*1e-6;            %
P_loss_sim  = logsout.get('P_loss_sim').Values*1e-6;        %
P_loss_act  = logsout.get('P_loss_act').Values*1e-6;        %

P_bat       = logsout.get('P_bat').Values*1e-6;             %
P_bat_set   = logsout.get('P_bat_set').Values*1e-6;         %
SoC         = logsout.get('SoC').Values;                    %

n_dies      = logsout.get('n_dies').Values;                 %
P_dies      = logsout.get('P_dies').Values*1e-6;            
P_dies_unit = logsout.get('P_dies_unit').Values;            %

U_max       = logsout.get('U_max').Values;                  %
U_min       = logsout.get('U_min').Values;                  %

freq        = logsout.get('freq').Values;                   %

%%

t_st = 20;
t_en = freq.Time(end);

%%
figure();
plot(0,0);
plot(P_loss);
ylabel('P_{LOSS} [MW]'); xlabel('Time [s]'); xlim([t_st t_en]); 
title ('Grid Losses'); grid minor;
legend('Actual','Predicted');

%%
figure();
plot(0,0);
plot(P_pv); hold all;
plot(P_pv_avail);
plot(P_pv_set);
% plot(P_pv_opt);
xlabel('Time [s]'); xlim([t_st t_en]); title ('PV Generation'); grid minor;
ylabel('P_{PV} [MW]');
legend('Actual','Available','Setpoint');

%%
figure();
plot(0,0);
plot(P_cons); hold all;
plot(P_cons_for);
xlabel('Time [s]'); xlim([t_st t_en]); title ('Consumption'); grid minor;
ylabel('P_{CONS} [MW]');
legend('Actual','Avg Forecast');


%%
figure();
plot(0,0);
plot(P_bat); hold all;
plot(P_bat_set);
xlabel('Time [s]'); xlim([t_st t_en]); title ('Battery Injection'); grid minor;
ylabel('P_{BAT} [MW]');
legend('Actual','Setpoint');

%%
figure();
plot(0,0);
plot(SoC*100);
xlabel('Time [s]'); xlim([t_st t_en]); title ('Battery SoC'); grid minor;
ylabel('SoC [%]');
% legend('','');

%%
figure();
plot(0,0);
plot(n_dies);
xlabel('Time [s]'); xlim([t_st t_en]); title ('Num of Dies Generators'); grid minor;
ylabel('N_{DIES}'); ylim([1 13]);
% legend('','');

%%
figure();
plot(0,0);
plot(P_dies_unit*100);
xlabel('Time [s]'); xlim([t_st t_en]); title ('Dies Generator Loading'); grid minor;
ylabel('P_{DIES}^{UNIT} [%]');
% legend('','');

%%
figure();
plot(0,0);
plot(freq);
xlabel('Time [s]'); xlim([t_st t_en]); title ('Grid Frequency'); grid minor;
ylabel('f [Hz]');
% legend('','');

%%
figure();
plot(0,0);
plot(U_max); hold all;
plot(U_min);
xlabel('Time [s]'); xlim([t_st t_en]); title ('Grid Voltage'); grid minor;
ylabel('U [p.u.]'); ylim([0.9, 1.1]);
legend('Max','Min');

%%
% figure();
% plot(0,0);
% plot();
% xlabel('Time [s]'); xlim([t_st t_en]); title (''); grid minor;
% ylabel('');
% % legend('','');

%%
% SoC.Data(SoC.Time==20+900*31)
