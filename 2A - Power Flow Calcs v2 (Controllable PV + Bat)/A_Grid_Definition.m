clear all;
close all;
clc;

a = loadcase('case9');

%% Grid Params:

% Base Power and Base Voltage:
a.baseMVA   = 10;
a.bus(:,10) = 10;

ks = [1 1.6 2.95 1.02 1.75 1.25 1.09 2.8 1.5]'; % Branch Imp Ratios
z  = [0.0342 0.0124 0.0009]; % Nexans 10kV, 3x70 mm^2
a.branch(:,3:5) = ks*z;
a.branch(:,3) = a.branch(:,3)*2.75;
a.branch(:,4) = a.branch(:,4)*2.75;
a.branch(:,5) = a.branch(:,5)*1;

a.bus(:,3:4) = a.bus(:,3:4)/30; % P_l and Q_l

% Generation Setpoints:
a.gen(:,6) =  [1.00 1.00 1.00]; % U_g
a.gen(:,2:3) =  3; % P_g, Q_g


%% OPF Params:

% Min / Max Voltage:
a.bus(1:3,12)     = 1.10; % Diesel
a.bus([4,6,8],12) = 1.10; % PV + Bat
a.bus([5,7,9],12) = 1.05; % Load
a.bus(:,13)       = 0.925;% All

% Min / Max Power Injection:
a.gen(:,2:3) =  0; % P_g, Q_g
a.gen(:,  9) =  5; % P_g_max
a.gen(:, 10) =  0; % P_g_min
a.gen(:,  4) =  3; % Q_g_max
a.gen(:,  5) = -3; % Q_g_min

% Capability Curve Points:
% set a.gen(:,11:16);

a.gencost(:,2) = 0;
a.gencost(2,5:7) = a.gencost(1,5:7);
a.gencost(3,5:7) = a.gencost(1,5:7);



%% Diesel Capability Curves:

my_params = load('../../Data/System Params/params');

ON_dies = ones(12,1);
gens = [1 2 3 4; 5 6 7 8; 9 10 11 12];

% ON_dies([1 2 5 6 9 10]) = 0;

P_max = my_params.P_dies_max/1000;
P_min = my_params.P_dies_min/1000;

a.gen(:,  7) =  a.baseMVA; % Gen Base Power

a.gen(:,  9) =  P_max; % P_g_max
a.gen(:, 10) =  P_min; % P_g_min
a.gen(:,  4) =  P_max; % Q_g_max
a.gen(:,  5) = -P_max; % Q_g_min

% CASE A (S_max = 1.1*P_max -> cos_fi = 0.9091):
k = sqrt(1-(1/1.1)^2)*1.1;

a.gen(:, 11) =  k*P_max; % Pc1
a.gen(:, 12) =  1*P_max; % Pc2
a.gen(:, 13) = -1*P_max; % Qc1min
a.gen(:, 14) =  1*P_max; % Qc1max
a.gen(:, 15) = -k*P_max; % Qc2min
a.gen(:, 16) =  k*P_max; % Qc2max

%% PV and BATTERY Capability Curves:

% Switch them to PU buses:

a.bus([4,6,8],2) = 2;

a.bus([4,6,8],3:4) = 0;


% Add PV and Battery to Control:
a.gen(4:6, :) = a.gen(1:3,:);
a.gen(4:6, 1) = [4;8;6];
a.gen(4:6, 9) = 1.01;
a.gen(4:6,10) = 0.99;

a.gen(4:5, 4) =  my_params.P_PV_inst*1e-3*0.5;
a.gen(  6, 4) =  my_params.P_bat_max*1e-3;
a.gen(4:5, 5) = -my_params.P_PV_inst*1e-3*0.5;
a.gen(  6, 5) = -my_params.P_bat_max*1e-3;

a.gen(4:6,11:16) = 0;

a.gencost(4:6,:) = a.gencost(1:3,:);


%% Save Case;

% savecase('my_case',a); 
savecase('../../Data/System Params/my_case',a);

%% Scale with number of generators:
% 
% inds = [4 5 9 10 11 12 13 14 15 16];
% for k=1:size(gens,1)
%     a.gen(k,inds) = a.gen(k,inds) * sum(ON_dies(gens(k,:)));
% end
% 
% % b = runpf(a);
% % b = runopf(a);
% b = runopf(a, mpoption('verbose', 0, 'out.all', 0));
% 
% losses = sum(real(get_losses(b)))
% volts  = b.bus(:, 8)

