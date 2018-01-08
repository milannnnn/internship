clear all;
close all;
clc;

a = loadcase('case9');

%% Grid Params:

% Base Power and Base Voltage:
a.baseMVA = 10;
a.bus(:,10) = 10;

ks = [1 1.6 2.95 1.02 1.75 1.25 1.09 2.8 1.5]'; % Branch Imp Ratios
% z  = [0.0086	0.0030	0.0025]; % Nexans 20kV, 3x70 mm^2
% ks = ks*12; % Upscaling distances
z  = [0.0342 0.0124 0.0009]; % Nexans 10kV, 3x70 mm^2
% ks = ks*3.2; % Upscaling distances
ks = ks*3; % Upscaling distances
ks = ks*2.5; % Upscaling distances
a.branch(:,3:5) = ks*z;

a.bus(:,3:4) = a.bus(:,3:4)/30; % P_l and Q_l
% a.gen(:,6) =  [1.08 1.08 1.08]; % U_g

% Generation Setpoints:
a.gen(:,6) =  [1.00 1.00 1.00]; % U_g
a.gen(:,2:3) =  3; % P_g, Q_g


%% OPF Params:

% Min / Max Voltage:
a.bus(1:3,12) = 1.1;
a.bus([4,6,8],12) = 1.1;
a.bus([5,7,9],12) = 1.1;
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

%% Save Case;

savecase('my_case',a);

%% Scale with number of generators:

inds = [4 5 9 10 11 12 13 14 15 16];
for k=1:size(gens,1)
    a.gen(k,inds) = a.gen(k,inds) * sum(ON_dies(gens(k,:)));
end

% b = runpf(a);
% b = runopf(a);
b = runopf(a, mpoption('verbose', 0, 'out.all', 0));

losses = sum(real(get_losses(b)))
volts  = b.bus(:, 8)

