function [ y ] = simulate_PF( u  )
%SIMULATE_PF Summary of this function goes here
%   Detailed explanation goes here

% Optimization and Forecast:
n_dies        = u(1);
% Secondly Data:
P_cons_sec    = u(2)*1e-6;
P_pv_sec      = u(3)*1e-6;
P_bat_sec     = u(4)*1e-6;

%% Declaring Persistent Vars:

persistent my_init a P_PV_inst P_bat_max inds a_gen_org_d tan_fi y_pr opf pf
persistent nd_opf pv_opf bt_opf cn_opf cnsc pvsc btsc P_DEV run_opf

% To correct the disconuity due to Zero Order Hold we add a 2s delay to PF
% calculations (controlled with opf and pf variables)
% so when we calculate OPF setpoints -> we wait 2s and then calc PF

%% Initialize Power System:

if isempty(my_init)
    a = loadcase('../../Data/System Params/my_case');
    my_params = load('../../Data/System Params/params');
    P_PV_inst = my_params.P_PV_inst*1e-3;
    P_DEV     = 0.5; % MW
    P_bat_max = my_params.P_bat_max*1e-3;
    clear my_params;

    % Memorize Generator Characteristics:
    inds = [4 5 9 10 11 12 13 14 15 16]; % indices for generator power scaling
    a_gen_org_d = a.gen(1,:);
    
    tan_fi = tan(acos(0.95));

    my_init = 1;
end

if isempty(cn_opf)
    nd_opf = NaN;
    pv_opf = Inf;
    bt_opf = Inf;
    cn_opf = Inf;
    cnsc   = NaN;
    pvsc   = NaN;
    btsc   = NaN;
end

if isempty(y_pr)
    y_pr = [1,1,0];
end

%% Optimal Power Flow Setpoints:

% Rescale Diesel:
if nd_opf~=n_dies
    d1 = floor(n_dies/3) + min(1, mod(n_dies,3));
    d2 = floor(n_dies/3) + min(1, max(0,mod(n_dies,3)-1));
    d3 = floor(n_dies/3);
    a.gen(1,inds) = a_gen_org_d(inds)*d1;
    a.gen(2,inds) = a_gen_org_d(inds)*d2;
    a.gen(3,inds) = a_gen_org_d(inds)*d3;
    
    a.bus(2,2)= 1*(d2==0) + 2*(d2~=0);
    a.bus(3,2)= 1*(d3==0) + 2*(d3~=0);
    
    nd_opf  = n_dies;
    run_opf = 1;
end

% Adjust PV Setpoint (if it deviates by more than 1MW from previous):
if abs(pv_opf-P_pv_sec)>P_DEV
    Q_PV_max = 0.5*sqrt(max((P_PV_inst)^2-(P_pv_sec)^2 , 0));
    a.gen(4:5, 4) =  Q_PV_max;
    a.gen(4:5, 5) = -Q_PV_max;
    a.gen(4:5, 9) =  P_pv_sec*0.5+1e-3;
    a.gen(4:5,10) =  P_pv_sec*0.5-1e-3;
    
    pv_opf  = P_pv_sec;
    run_opf = 1;
end

% Adjust Bat Setpoint (if it deviates by more than 1MW from previous):
if abs(bt_opf-P_bat_sec)>P_DEV
    Q_BAT_max = sqrt(max(P_bat_max^2-P_bat_sec^2 , 0));
    a.gen(6, 4) =  Q_BAT_max;
    a.gen(6, 5) = -Q_BAT_max;
    a.gen(6, 9) =  P_bat_sec+1e-3;
    a.gen(6,10) =  P_bat_sec+1e-3;
    
    bt_opf  = P_bat_sec;
    run_opf = 1;
end

% Adjust Cons Setpoint (if it deviates by more than 1MW from previous):
if abs(cn_opf-P_cons_sec)>P_DEV
    a.bus(5,3) = P_cons_sec*0.3;
    a.bus(7,3) = P_cons_sec*0.3;
    a.bus(9,3) = P_cons_sec*0.4;
    a.bus(5,4) = P_cons_sec*0.3*tan_fi;
    a.bus(7,4) = P_cons_sec*0.3*tan_fi;
    a.bus(9,4) = P_cons_sec*0.4*tan_fi;
    
    cn_opf  = P_cons_sec;
    run_opf = 1;
end

% Recalculate Optimal Power and Voltage Setpoints:
if run_opf
    
    % FMINCON - Always converges, the default solver does not!!!
    %tic;
    b = runopf(a, mpoption('verbose', 0, 'out.all', 0, 'opf.ac.solver', 'FMINCON'));
    %toc;
    
    if b.success
        a.gen(:,[2,3,6]) = b.gen(:,[2,3,6]);
        % disp('OPF Converged');
        % disp(['+ OPF Converged (n=',num2str(n_dies),', pv=',num2str(pv_gen_sim),' bat=',num2str(bat_set_sim),' con=',num2str(cons_avg_sim),')']);
    else
        if n_dies~=0
            % disp('# OPF Diverged');
            disp(['# OPF Diverged  (n=',num2str(nd_opf),', pv=',num2str(pv_opf),' bat=',num2str(bt_opf),' con=',num2str(cn_opf),')']);
        end
    end
    
    run_opf = 0;
    opf = 2;
end

%% Rescaling of Regular PF:

% Wait for secondly data to catch up to setpoints (due to Mean Sampling)
if opf
    pf  = 0;
    opf = opf-1;
else
    pf  = 1;
end

% Rescale Active PV Setopionts  (for freq support):
if (pvsc~=P_pv_sec)
    a.gen(4:5, 2) = P_pv_sec*0.5;
end

% Rescale Active Bat Setopionts (for freq support):
if (btsc~=P_bat_sec)
    a.gen(6, 2) = P_bat_sec;
end

% Rescale Consumption to actual cons:
if (cnsc~=P_cons_sec)
    a.bus(5,3) = P_cons_sec*0.3;
    a.bus(7,3) = P_cons_sec*0.3;
    a.bus(9,3) = P_cons_sec*0.4;
    a.bus(5,4) = P_cons_sec*0.3*tan_fi;
    a.bus(7,4) = P_cons_sec*0.3*tan_fi;
    a.bus(9,4) = P_cons_sec*0.4*tan_fi;
end

% Perform PF:
if ((cnsc~=P_cons_sec)||(pvsc~=P_pv_sec)||(btsc~=P_bat_sec))&&pf
    c = runpf(a, mpoption('verbose', 0, 'out.all', 0));
    cnsc = P_cons_sec;
    pvsc = P_pv_sec;
    btsc = P_bat_sec;
    
    if c.success
        y_pr(1) = min(c.bus(:, 8));             % U_min
        y_pr(2) = max(c.bus(:, 8));             % U_max
        y_pr(3) = sum(real(get_losses(c)))*1e6; % P_loss
    else
        if nd_opf~=0 && cnsc~=0 % skip the initialization
            disp('- PF Diverged');
            % disp(['- PF Diverged  (n=',num2str(n_dies),', pv=',num2str(P_pv_sec),' bat=',num2str(P_bat_sec),' con=',num2str(P_cons_sec),')']);
        end
    end
end

% To stabilize frequecy initialization (first 10s before act. simulation)
if P_cons_sec==0
    y_pr(3) = 0;
end

y = y_pr;

end