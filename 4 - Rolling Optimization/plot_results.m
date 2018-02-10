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
% P_loss_sim  = logsout.get('P_loss_sim').Values*1e-6;        %
P_loss_sim  = P_loss; P_loss_sim.Data = P_loss_sim.Data(:,2);
P_loss_act  = P_loss; P_loss_act.Data = P_loss_act.Data(:,1);

P_bat       = logsout.get('P_bat').Values*1e-6;             %
P_bat_set   = logsout.get('P_bat_set').Values*1e-6;         %
SoC         = logsout.get('SoC').Values;                    %

n_dies      = logsout.get('n_dies').Values;                 %
P_dies      = logsout.get('P_dies').Values*1e-6;            
P_dies_unit = logsout.get('P_dies_unit').Values;            %

U_max       = logsout.get('U_max').Values;                  %
U_min       = logsout.get('U_min').Values;                  %

Q_gen       = logsout.get('Q_gen_tot').Values*1e-6;         %

freq        = logsout.get('freq').Values;                   %

%%

t_st = 25;
t_en = freq.Time(end);

orange  = [0.9290, 0.6940, 0.1250];
red     = [0.8500, 0.3250, 0.0980];
blue    = [0, 0.4470, 0.7410];

set(0, 'DefaultLineLineWidth', 0.75);

%%
close all;
figure();
plot(0,0);
plot(P_loss_sim,'Color',red); hold all;
plot(P_loss_act,'Color',blue);
ylabel('P_{LOSS} [MW]'); xlabel('Time [s]'); xlim([t_st t_en]); 
title ('Grid Losses'); grid minor;
legend('Predicted','Actual');
myplot('res/losses');

%%
close all;
figure();
plot(0,0);
% plot(P_pv); hold all;
% plot(P_pv_avail);
% plot(P_pv_set);
plot(P_pv_avail,'Color',orange,'LineWidth',0.9); hold all;
plot(P_pv_set,'Color',red,'LineWidth',0.9);
plot(P_pv,'Color',blue,'LineWidth',0.75);
% plot(P_pv_opt);
xlabel('Time [s]'); xlim([t_st t_en]); title ('PV Generation'); grid minor;
ylabel('P_{PV} [MW]');  ylim([0 15]);
legend('Available','Setpoint','Actual');
myplot('res/pv');

%%
close all;
figure();
plot(0,0);
plot(P_cons_for,'Color',red,'LineWidth',0.9);
hold all;
plot(P_cons,'Color',blue,'LineWidth',0.75); 
xlabel('Time [s]'); xlim([t_st t_en]); title ('Consumption'); grid minor;
ylabel('P_{CONS} [MW]');
legend('Avg Forecast','Actual');
myplot('res/cons');

%%
close all;
figure();
plot(0,0);
plot(P_bat_set,'Color',red,'LineWidth',0.9); hold all;
plot(P_bat,'Color',blue,'LineWidth',0.75);
xlabel('Time [s]'); xlim([t_st t_en]); title ('Battery Injection'); grid minor;
ylabel('P_{BAT} [MW]');
legend('Setpoint','Actual','Location', 'SouthEast');
myplot('res/bat');

%%
close all;
figure();
plot(0,0);
plot(SoC*100,'LineWidth',0.9);
xlabel('Time [s]'); xlim([t_st t_en]); title ('Battery SoC'); grid minor;
ylabel('SoC [%]');
% legend('','');
myplot('res/soc');

%%
t = n_dies.Time;
x = n_dies.Data;

close all;
figure();
plot(t,x,'LineWidth',0.9);
xlabel('Time [s]'); xlim([t_st t_en]); title ('Online Dies Generators'); grid minor;
ylabel('N_{DIES}'); ylim([2.5 12.5]);
% legend('','');
myplot('res/ndies');

%%
close all;
figure();
plot(0,0);
plot(P_dies_unit*100,'LineWidth',0.9);
xlabel('Time [s]'); xlim([t_st t_en]); title ('Dies Generator Loading'); grid minor;
ylabel('P_{DIES}^{UNIT} [%]');
% legend('','');
myplot('res/dies_un');

%%
close all;
figure();
plot(0,0);
plot(freq);
xlabel('Time [s]'); xlim([t_st t_en]); title ('Grid Frequency'); grid minor;
ylabel('f [Hz]');
% legend('','');
myplot('res/freq');

%%
t1 = U_max.Time; U1 = U_max.Data;
t2 = U_min.Time; U2 = U_min.Data;

close all;
figure();
plot(t1,U1); hold all;
plot(t2,U2);
xlabel('Time [s]'); xlim([t_st t_en]); title ('Grid Voltage'); grid minor;
ylabel('U [p.u.]'); ylim([0.9, 1.1]);
legend('Max','Min');
myplot('res/volt');

%%
t = Q_gen.Time;
Q = Q_gen.Data;

close all;
figure();
plot(t,Q);
% plot(Q_gen,'LineWidth',1.05); hold all;
xlabel('Time [s]'); xlim([t_st t_en]); title ('Injected Reactive Power'); grid minor;
ylabel('Q [MVAr]');
% legend('','');
myplot('res/react');

%%
close all;
figure();
h=plot(0,0); hold all; delete(h);
plot(P_dies); 
plot(P_cons);
plot(P_pv);
plot(P_bat);
plot(P_loss_act,'Color',blue);
xlabel('Time [s]'); xlim([t_st t_en]); title (''); grid minor;
ylabel('P [MW]');
legend('Dies','Cons','PV','Bat','Loss','Location', 'NW');
myplot('res/all_powers');

%%
% SoC.Data(SoC.Time==20+900*31)
% plot(P_loss_act)
