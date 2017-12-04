clear all;
close all;
clc;

a = loadcase('my_case9');

%% Modify:

% Base Power and Base Voltage:
a.baseMVA = 10;
a.bus(:,10) = 35;


k = 6; % impedance increase factor
% 400 kV -> X ~ 0.30 Ohm/km; B ~ 4.0 uS/km;
%  22 kV -> X ~ 0.35 Ohm/km; B ~ 1.4 uS/km;
a.branch(:,5) = a.branch(:,5)*(1.4/4)/k;
a.branch(:,3:4) = a.branch(:,3:4)*(0.35/0.3)*k;

a.bus(:,3:4) = a.bus(:,3:4)/30; % P_l and Q_l

a.gen(:,2:3) =  0; % P_g, Q_g
a.gen(:,  9) =  5; % P_g_max
a.gen(:,  4) =  3; % Q_g_max
a.gen(:, 10) =  0; % P_g_min
a.gen(:,  5) = -3; % Q_g_min


a.gen(:,2:3) =  3; % P_g, Q_g
a.gen(:,6) =  [1.08 1.08 1.08]; % P_g, Q_g
% a.gen(:,6) =  [1.00 1.00 1.00]; % P_g, Q_g


%%
b = runpf(a);



