clear all;
close all;
clc

% #################################################
% # Change Impedance Upscaling (ks) in part A !!! #
% #################################################

% #############################################################
% # Include Cases of Different U_dies_max (e.g. 1, 1.05, 1.1) #
% #         (currently you are analyzing only 1.1)            #
% #############################################################

warning('off','all');

%% Load Power Flow Case:

a = loadcase('my_case');
inds = [4 5 9 10 11 12 13 14 15 16]; % indices for generator power scaling

a_gen_org = a.gen(1,:);

cos_fi = 0.95;
tan_fi = tan(acos(cos_fi));

P_cons_MAX = 11.5;

%% Power Flow Definition:

% Bus 1 -  33% of Generators
% Bus 2 -  33% of Generators
% Bus 3 -  33% of Generators
% Bus 4 -  50% PV Generation
% Bus 5 -  30% Load Consumption
% Bus 6 - 100% Battery
% Bus 7 -  30% Load Consumption
% Bus 8 -  50% PV Generation
% Bus 9 -  40% Load Consumption

% Data:
field1 = 'n_dies_1';    % numeber of diesel gen at bus 1
field2 = 'n_dies_2';    % numeber of diesel gen at bus 2
field3 = 'n_dies_3';    % numeber of diesel gen at bus 3
field4 = 'P_bat';       % Battery Power
field5 = 'P_pv';        % PV Generation
field6 = 'P_cons';      % Load Consumption

% Results:
field7 = 'U_min';       % Minimum Grid Voltage
field8 = 'U_max';       % Minimum Grid Voltage
field9 = 'P_loss';      % Total Grid Losses
    
% Structure initialization:
STRUCT = struct(field1,[],field2,[],field3,[],field4,[],field5,[],field6,[],field7,[],field8,[],field9,[]);

my_params = load('../../Data/System Params/params');

P_dies_max = my_params.P_dies_max/1e3;
P_dies_min = my_params.P_dies_min/1e3;

range_bat   = (my_params.P_bat_min:1100:my_params.P_bat_max)/1e3;
range_PV    = (my_params.P_PV_inst/1e3):-1.5:1;

% Divide Dies Generator in 3 groups (for buses):
groups = 3;
n_gens = round(my_params.N_dies / groups);
for k = (groups-1):-1:1
    n_gens = [n_gens; round((my_params.N_dies - sum(n_gens)) / k)];
end
n_gens = sort(n_gens,'descend');


range_bat   = (my_params.P_bat_min:2200:my_params.P_bat_max)/1e3;
range_PV    = (my_params.P_PV_inst/1e3):-3:1;

tot = n_gens(1)*(n_gens(2)+1)*(n_gens(3)+1)*length(range_PV)*length(range_bat)*3;
prog = 1;

%%
% Loop over all generator combinations:
for d1 = 1:n_gens(1)
for d2 = 0:n_gens(2)
for d3 = 0:n_gens(3)
    
    % Scale the Capability Curve Params:
    a.gen(1,inds) = a_gen_org(inds)*d1;
    a.gen(2,inds) = a_gen_org(inds)*d2;
    a.gen(3,inds) = a_gen_org(inds)*d3;
    
    % Loop over all PV generation:
    for P_pv = range_PV
        
        % Input PV Generation (neg. load):
        a.bus(4,3) = -P_pv*0.5;
        a.bus(4,4) =  0; % assuming cos_fi=1
        a.bus(8,3) = -P_pv*0.5;
        a.bus(8,4) =  0; % assuming cos_fi=1
        
        % Loop over all Battery Setpoints:
        for P_bat = range_bat
            
            % Input Battery Cons (neg. load):
            a.bus(6,3) = -P_bat;
            a.bus(6,4) =  0; % assuming cos_fi=1
            
            % Loop over different Consumption:
            for delta = [0.1, 0.5, 0.9]
                
                fprintf('%d/%d\n', prog, tot);
                prog = prog+1;
                
                P_min  = P_pv + P_bat + (d1+d2+d3)*P_dies_min;
                P_max  = P_pv + P_bat + (d1+d2+d3)*P_dies_max;
                P_cons = P_min + delta*(P_max-P_min);
                
                a.bus(5,3) = P_cons*0.3;
                a.bus(7,3) = P_cons*0.3;
                a.bus(9,3) = P_cons*0.4;
                a.bus(5,4) = P_cons*0.3*tan_fi;
                a.bus(7,4) = P_cons*0.3*tan_fi;
                a.bus(9,4) = P_cons*0.4*tan_fi;
                
                % Check is the consumption positive:
                if P_cons > 0 && P_cons < P_cons_MAX % max scenario - 11.2MW
                    
                    b = runopf(a, mpoption('verbose', 0, 'out.all', 0));
                    
                    % If the flow converged
                    if b.success
                        
                        U_min  = min(b.bus(:, 8));
                        % U_max  = max(b.bus(:, 8));
                        U_max  = max(b.bus(4:end, 8)); %disregard dies bus
                        P_loss = sum(real(get_losses(b)));
                        
                        STRUCT(length(STRUCT)+1) = struct(field1,d1,field2,d2,field3,d3,field4,P_bat,field5,P_pv,field6,P_cons,field7,U_min,field8,U_max,field9,P_loss);
                        
                    end
                end
            end
        end
    end
end
end
end

STRUCT(1) = [];
save('../../Data/Generated Data/6 - Power Flows/opt_flow_sim','STRUCT');

%% 

U_min = zeros(length(STRUCT),1);
U_max = zeros(length(STRUCT),1);
for k=1:length(STRUCT)
    U_min(k) = STRUCT(k).U_min;
    U_max(k) = STRUCT(k).U_max;
end
plot(U_min); hold all; plot(U_max);
