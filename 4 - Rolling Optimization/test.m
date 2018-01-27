clear all;
close all;
clc;

%% Loading Simulation Setpoints:

% ##############################################
% # ALL POWERS ARE in W!!! => Rescale to MW!!! #
% ##############################################

% clear simulate_PF;

n_dies = 5;
pv_set_sim = 6;
bat_set_sim = 3;
cons_avg_sim = 10;

consum_sim = 10;

simulate_PF( n_dies, pv_set_sim, bat_set_sim, cons_avg_sim, consum_sim)

% %% Initialize Power System:
% 
% a = loadcase('../../Data/System Params/my_case');
% my_params = load('../../Data/System Params/params');
% P_PV_inst = my_params.P_PV_inst*1e-3;
% P_bat_max = my_params.P_bat_max*1e-3;
% clear my_params;
% 
% % Define Min Voltage:
% a.bus([5,7,9],13) = 0.95;
% 
% % Rescale Generator Characteristics:
% inds = [4 5 9 10 11 12 13 14 15 16]; % indices for generator power scaling
% a_gen_org_d = a.gen(1,:);
% 
% tan_fi = tan(acos(0.95));
% 
% %% Rescaling Powers for OPF:
% 
% % Rescale Diesel:
% d1 = floor(n_dies/3) + min(1, mod(n_dies,3));
% d2 = floor(n_dies/3) + min(1, max(0,mod(n_dies,3)-1));
% d3 = floor(n_dies/3);
% a.gen(1,inds) = a_gen_org_d(inds)*d1;
% a.gen(2,inds) = a_gen_org_d(inds)*d2;
% a.gen(3,inds) = a_gen_org_d(inds)*d3;
% 
% % Rescale PV:
% Q_PV_max = sqrt(max((P_PV_inst*0.5)^2-(pv_set_sim*0.5)^2 , 0));
% a.gen(4:5, 4) =  Q_PV_max;
% a.gen(4:5, 5) = -Q_PV_max;
% a.gen(4:5, 9) =  pv_set_sim*0.5*1.001;
% a.gen(4:5,10) =  pv_set_sim*0.5*0.999;
% 
% % Rescale Battery:
% Q_BAT_max = sqrt(max((P_bat_max)^2-(bat_set_sim)^2 , 0));
% a.gen(6, 4) =  Q_BAT_max;
% a.gen(6, 5) = -Q_BAT_max;
% a.gen(6, 9) =  bat_set_sim*1.001;
% a.gen(6,10) =  bat_set_sim*0.999;
% 
% % Rescale Consumption:
% a.bus(5,3) = cons_avg_sim*0.3;
% a.bus(7,3) = cons_avg_sim*0.3;
% a.bus(9,3) = cons_avg_sim*0.4;
% a.bus(5,4) = cons_avg_sim*0.3*tan_fi;
% a.bus(7,4) = cons_avg_sim*0.3*tan_fi;
% a.bus(9,4) = cons_avg_sim*0.4*tan_fi;
% 
% b = runopf(a, mpoption('verbose', 0, 'out.all', 0));
% 
% a.gen(:,[2,3,6]) = b.gen(:,[2,3,6]);
% 
% %%
% 
% % Rescale Consumption:
% a.bus(5,3) = consum_sim*0.3;
% a.bus(7,3) = consum_sim*0.3;
% a.bus(9,3) = consum_sim*0.4;
% a.bus(5,4) = consum_sim*0.3*tan_fi;
% a.bus(7,4) = consum_sim*0.3*tan_fi;
% a.bus(9,4) = consum_sim*0.4*tan_fi;
% 
% c = runpf(a, mpoption('verbose', 0, 'out.all', 0));
% 
% U_min  = min(c.bus(:, 8));
% P_loss = sum(real(get_losses(c)));