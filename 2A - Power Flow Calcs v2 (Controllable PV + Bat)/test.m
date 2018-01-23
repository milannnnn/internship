clear all;
close all;
clc;

a = loadcase('my_case9');
a = loadcase('case9');

%% Grid Params:

% Base Power and Base Voltage:
a.baseMVA = 10;
a.bus(:,10) = 10;

% k = 6; % impedance increase factor
% % 400 kV -> X ~ 0.30 Ohm/km; B ~ 4.0 uS/km;
% %  22 kV -> X ~ 0.35 Ohm/km; B ~ 1.4 uS/km;
% a.branch(:,5) = a.branch(:,5)*(1.4/4)/k;
% a.branch(:,3:4) = a.branch(:,3:4)*(0.35/0.3)*k;

ks = [1 1.6 2.95 1.02 1.75 1.25 1.09 2.8 1.5]'; % Branch Ratios
% z  = [0.0086	0.0030	0.0025]; % Nexans 20kV, 3x70 mm^2
% ks = ks*12; % Upscaling distances
z  = [0.0342	0.0124	0.0009]; % Nexans 10kV, 3x70 mm^2
% ks = ks*3.2; % Upscaling distances
ks = ks*3; % Upscaling distances
a.branch(:,3:5) = ks*z;

a.bus(:,3:4) = a.bus(:,3:4)/30; % P_l and Q_l
% a.gen(:,6) =  [1.08 1.08 1.08]; % U_g

% Generation Setpoints:
a.gen(:,6) =  [1.00 1.00 1.00]; % U_g
a.gen(:,2:3) =  3; % P_g, Q_g


%% OPF Params:

% Min / Max Voltage:
a.bus(:,12) = 1.025;
a.bus(:,13) = 0.90;

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



%% Capability Curves:

my_params = load('../../Data/System Params/params');

ON_dies = ones(12,1);
gens = [1 2 3 4; 5 6 7 8; 9 10 11 12];

% ON_dies([1 2 5 6 9 10]) = 0;

P_max = my_params.P_dies_max/1000;
P_min = my_params.P_dies_min/1000;

a.gen(:,  9) =  P_max; % P_g_max
a.gen(:, 10) =  P_min; % P_g_min
a.gen(:,  4) =  P_max; % Q_g_max
a.gen(:,  5) = -P_max; % Q_g_min

% CASE A (S_max = 1.1*P_max -> cos_fi = 0.9091):
k = 0.458;
% % CASE B (cos_fi = 0.95 at P_max):
% k = sin(acos(0.95))/0.95; % S_max = 1/0.95 P_max = 1.0526 P_max

a.gen(:, 11) =  k*P_max; % Pc1
a.gen(:, 12) =  1*P_max; % Pc2
a.gen(:, 13) = -1*P_max; % Qc1min
a.gen(:, 14) =  1*P_max; % Qc1max
a.gen(:, 15) = -k*P_max; % Qc2min
a.gen(:, 16) =  k*P_max; % Qc2max

inds = [4 5 9 10 11 12 13 14 15 16];

for k=1:size(gens,1)
    a.gen(k,inds) = a.gen(k,inds) * sum(ON_dies(gens(k,:)));
end

%%
% b = runpf(a);
b = runopf(a);

sum(real(get_losses(b)))

