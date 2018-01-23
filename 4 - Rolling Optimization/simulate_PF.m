function [ y ] = simulate_PF( u  )
%SIMULATE_PF Summary of this function goes here
%   Detailed explanation goes here

% n_dies = 5;
% pv_set_sim = 6;
% bat_set_sim = 3;
% cons_avg_sim = 10;
% consum_sim = 11;

n_dies       = u(1);
pv_set_sim   = u(2)*1e-6;
bat_set_sim  = u(3)*1e-6;
cons_avg_sim = u(4)*1e-6;
consum_sim   = u(5)*1e-6;



%% Declaring Persistent Vars:

persistent my_init a P_PV_inst P_bat_max inds a_gen_org_d tan_fi
persistent nd pvst btst cnav

%% Initialize Power System:

if isempty(my_init)
    a = loadcase('../../Data/System Params/my_case');
    my_params = load('../../Data/System Params/params');
    P_PV_inst = my_params.P_PV_inst*1e-3;
    P_bat_max = my_params.P_bat_max*1e-3;
    clear my_params;

    % Define Min Voltage:
    % a.bus([5,7,9],13) = 0.95;
    a.bus([5,7,9],13) = 0.925;

    % Rescale Generator Characteristics:
    inds = [4 5 9 10 11 12 13 14 15 16]; % indices for generator power scaling
    a_gen_org_d = a.gen(1,:);

    tan_fi = tan(acos(0.95));

    my_init = 1;
end

if isempty(cnav)
    nd   = NaN;
    pvst = NaN;
    btst = NaN;
    cnav = NaN;
end
%% Rescaling Powers for OPF:

% Rescale Diesel:
if nd~=n_dies
    d1 = floor(n_dies/3) + min(1, mod(n_dies,3));
    d2 = floor(n_dies/3) + min(1, max(0,mod(n_dies,3)-1));
    d3 = floor(n_dies/3);
    a.gen(1,inds) = a_gen_org_d(inds)*d1;
    a.gen(2,inds) = a_gen_org_d(inds)*d2;
    a.gen(3,inds) = a_gen_org_d(inds)*d3;
    
    a.bus(2,2)= 1*(d2==0) + 2*(d2~=0);
    a.bus(3,2)= 1*(d3==0) + 2*(d3~=0);
end

% Rescale PV:
if pvst~=pv_set_sim
    Q_PV_max = sqrt(max((P_PV_inst*0.5)^2-(pv_set_sim*0.5)^2 , 0));
    a.gen(4:5, 4) =  Q_PV_max;
    a.gen(4:5, 5) = -Q_PV_max;
    a.gen(4:5, 9) =  pv_set_sim*0.5*1.001;
    a.gen(4:5,10) =  pv_set_sim*0.5*0.999;
    
end

% Rescale Battery:
if btst~=bat_set_sim
    Q_BAT_max = sqrt(max((P_bat_max)^2-(bat_set_sim)^2 , 0));
    a.gen(6, 4) =  Q_BAT_max;
    a.gen(6, 5) = -Q_BAT_max;
    a.gen(6, 9) =  bat_set_sim*1.001;
    a.gen(6,10) =  bat_set_sim*0.999;
    
end

% Rescale Consumption:
if cnav~=cons_avg_sim
    a.bus(5,3) = cons_avg_sim*0.3;
    a.bus(7,3) = cons_avg_sim*0.3;
    a.bus(9,3) = cons_avg_sim*0.4;
    a.bus(5,4) = cons_avg_sim*0.3*tan_fi;
    a.bus(7,4) = cons_avg_sim*0.3*tan_fi;
    a.bus(9,4) = cons_avg_sim*0.4*tan_fi;
    
end

% Recalculate Optimal Power and Voltage Setpoints:
if (nd~=n_dies)||(pvst~=pv_set_sim)||(btst~=bat_set_sim)||(cnav~=cons_avg_sim) 
    b = runopf(a, mpoption('verbose', 0, 'out.all', 0));
    a.gen(:,[2,3,6]) = b.gen(:,[2,3,6]);
    
    nd  =n_dies;
    pvst=pv_set_sim;
    btst=bat_set_sim;
    cnav=cons_avg_sim;
    
    % disp(1);
end

%%

% Rescale Consumption:
a.bus(5,3) = consum_sim*0.3;
a.bus(7,3) = consum_sim*0.3;
a.bus(9,3) = consum_sim*0.4;
a.bus(5,4) = consum_sim*0.3*tan_fi;
a.bus(7,4) = consum_sim*0.3*tan_fi;
a.bus(9,4) = consum_sim*0.4*tan_fi;

c = runpf(a, mpoption('verbose', 0, 'out.all', 0));

% U_min  = min(c.bus(:, 8));
% P_loss = sum(real(get_losses(c)));

y(1) = min(c.bus(:, 8));
y(2) = sum(real(get_losses(c)))*1e6;

end