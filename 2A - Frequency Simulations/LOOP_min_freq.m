clear all;
close all;
clc;

warning('off','all');

my_power1 = -1.50e6;
my_power2 = -2.75e6;

% ##################################### %
% # CHECK my_power1 and my_power2 !!! #
% ##################################### %

% ########################################## %
% G_disturbance - C_disturbance <  my_power1 %
% G_PV_steady   - C_steady      > -my_power2 %
% ########################################## %

f_acceptable = 45;

% Noms de l'estructura d'informació    
    
% Data:
field1 = 'nom_sim';     % simulation name
field2 = 'num_dies';    % numeber of diesel gen
field3 = 'P_bat';       % initial battery power
field4 = 'P_pv_curt';   % max available PV power
field7 = 'min_dies';    % min required n of dies gen for feasable simulation
field8 = 'addit_dies';  % diff between act and min dies (num_dies-min_dies)

% Results:
field5 = 'f_max';       % maximum obtained frequency (after disturbance)
field6 = 'f_min';       % minimum obtained frequency (after disturbance)
    
% Structure initialization:
STRUCT = struct(field1,[],field2,[],field3,[],field4,[],field5,[],field6,[],field7,[],field8,[]);

my_params = load('../../Data/System Params/params');

% % Definition of simulation scenarios (ranges):
range_bat = (my_params.P_bat_min:550:my_params.P_bat_max)*1e3;
range_PV = (my_params.P_PV_inst*1e3):-0.25e6:1e6;    % max available PV power (PV Curtailment - almost Setpoint)
range_ndies = 1:my_params.N_dies;       % number of diesel generators

clear my_params;

% range_bat =  -0000000;    % potencia inicial de la bateria
% range_PV = 3000000;    % potencia màxima fotovoltaica
% range_ndies = 2;                      % número de generadors dièsel

% Definition of simulation event times:
t_init_dies = 10; % loading event for cons and PV (from 0 -> initial)
t_init      = 30; % disturbance event for cons and PV (initial -> disturb)
% p_time_sim  = 50; % simulation duration (ends at 80s)
p_time_sim  = 20; % simulation duration (ends at 80s)


% warning about the number of simulations that can be done
num_sim = length(range_bat)*length(range_PV)*length(range_ndies);
if (num_sim)>50
%     wning = warndlg(strcat('Alert, you are about to do ',num2str(num_sim),' simulations'));
end

% Loop initialization:  
k = 0;
f_end = [];

for Setp_Batt = range_bat
	for potmax_pv_init = range_PV
         mindies = 12;
         for n_diesels = range_ndies 

            k = k + 1;
            
            display(strcat(num2str(k),'/',num2str(num_sim)));              
            progressbar(k/num_sim) % Update figure 

            % Initialization 
            % Solar
            potmax_pv_sim = zeros(t_init+p_time_sim,2);
            potmax_pv_sim(1:t_init,1) = 1:t_init;
            potmax_pv_sim(1:t_init,2) = [zeros(t_init_dies,1); repmat(potmax_pv_init,t_init-t_init_dies,1)];
            % Load parameters 
            parameters_balanc;

            cons_init = 20e6;
            % Consum 
            %  consum_sim - time series vector (1st col - time, 2nd - cons data)
            consum_sim = zeros(t_init+p_time_sim,2);
            consum_sim(1:t_init,1) = 1:t_init; 
            consum_sim(1:t_init,2) = [zeros(t_init_dies,1); repmat(cons_init,t_init-t_init_dies,1)];

            % Changes in generation and consumption
            %load('../1 - PROBLEMA DETERMINAR SOC/Fitxers_resultats/M_change_pos.mat')
            %load('../1 - PROBLEMA DETERMINAR SOC/Fitxers_resultats/M_change_neg.mat')

            load('../../Data/Generated Data/3 - Changes/M_change_pos.mat')
            load('../../Data/Generated Data/3 - Changes/M_change_neg.mat')
            
            % Increase in Consumption and decrease of generation
            consum_sim((t_init+1):(t_init+p_time_sim),1) = ((t_init+1):(t_init+p_time_sim))';
            % superpose the obtained max cons change vector (since it's shorter -> when it runs out, just repeat the last element) !!!
            % consum_sim((t_init+1):(t_init+p_time_sim),2) = [(cons_init+change_con_pos*1000) ; (cons_init+change_con_pos(end)*1000)*ones(p_time_sim-length((cons_init+change_con_pos*1000)),1)];
            consum_sim((t_init+1):(t_init+p_time_sim),2) = [(cons_init+change_con_pos(1:p_time_sim)*1000)];

            % Interpolation
            int1 = floor(interp1(pv_curtail,1:length(pv_curtail),potmax_pv_init/1000,'linear'));
            % pv_curtail - vector of curtailment limitation (in kW): 4000, 3900, ..., 1000

            potmax_pv_sim((t_init+1):(t_init+p_time_sim),1) = ((t_init+1):(t_init+p_time_sim))';
            % superpose the obtained max gen change vector (since it's shorter -> when it runs out, just repeat the last element) !!!
            % potmax_pv_sim((t_init+1):(t_init+p_time_sim),2) = [(potmax_pv_init+change_gen_all_neg(int1,:)'*1000) ; (potmax_pv_init+change_gen_all_neg(int1,end)*1000)*ones(p_time_sim-length((cons_init+change_gen_all_neg(int1,:)*1000)),1)];
            potmax_pv_sim((t_init+1):(t_init+p_time_sim),2) = [(potmax_pv_init+change_gen_all_neg(int1,1:p_time_sim)'*1000)];

            % Increase resolution of data (to a total of 1000 samples)
            x = 1:length(consum_sim(:,2));
            y1 = consum_sim(:,2);
            y2 = potmax_pv_sim(:,2);
            ces1 = spline(x,y1);
            ces2 = spline(x,y2);
            xx = linspace(1,length(consum_sim(:,2)),1000);
            consum_sim = [xx' ppval(ces1,xx)'];
            potmax_pv_sim = [xx' ppval(ces2,xx)'];

            % Find the "new" t_init (normalized to 1000 samples)
            lenad = (t_init)/(t_init+p_time_sim)*1000;

            % Limit it to Max Init Power (due to spline):
            potmax_pv_sim(:,2) = min(potmax_pv_sim(:,2),potmax_pv_init);
            
            %---------------------------------------------------------------------------------------------------% 
            % ### For some reason we remove the 80% of the min PV power (stabilized at the end of simulation)???% 
            % potmax_pv_sim(:,2) = potmax_pv_sim(:,2) - min(potmax_pv_sim(lenad:end,2))*0.8;
            %---------------------------------------------------------------------------------------------------% 
            
            % Limit it to 0 (due to spline):
            potmax_pv_sim(:,2) = max(potmax_pv_sim(:,2),0);

            % Check for: - system stability (MIN TOTAL AVILABLE GEN has to overshoot MAX CONS by at least 0.5MW)
            %            - renewable utilization in steady st. (less than 0.5MW cons should be matched by diesel) 
            %
            %   1st OR term -  does the min total available generation overshoot the max consumption by more than 0.5MW??? 
            %               -> Do we have enough reserve during DISTURBANCE (min GEN & max CONS) !!!  
            %   2nd OR term -  does the max PV + BAT (without DIES) lag the min consumption by less than 0.5MW??? 
            %               -> Do we have a good matching of PV/Bat and Cons in STEADY STATE (max GEN & min CONS)???  
            %               -> its only use is to check if, when the disturbace criterion is matched, do we still have good renewable utilization?   
            %                  "positive feedback term" -> if it ever gets true it will run the while loop until 1st AND term breaks the loop!!!
%             my_power1 = 0.5e6;
%             my_power2 = 0.5e6;

            while  (cons_init>0) && (  ((max(consum_sim((lenad-100):end,2))-min(potmax_pv_sim((lenad-100):end,2))-n_diesels*P_nom_u_GS-Setp_Batt)>-my_power1) ...
                                     ||((min(consum_sim((lenad-100):end,2))-max(potmax_pv_sim((lenad-100):end,2))-Setp_Batt)<my_power2) )
                            
                
                % We repeat the loop until we get:
                %
                % G_disturbance - C_disturbance >  my_power1 # we can compnsate the difference !!! 
                % G_PV_steady   - C_steady      < -my_power2 # cons is matched by PV in steady state!!! 
                
                % We decrease the initial consumption and recalculate the vector: 
                cons_init = cons_init-100000;
                
                % Consum 
                consum_sim = zeros(t_init+p_time_sim,2);
                consum_sim(1:t_init,1) = 1:t_init; 
                consum_sim(1:t_init,2) = [zeros(t_init_dies,1); repmat(cons_init,t_init-t_init_dies,1)];
                consum_sim((t_init+1):(t_init+p_time_sim),1) = ((t_init+1):(t_init+p_time_sim))';
                % consum_sim((t_init+1):(t_init+p_time_sim),2) = [(cons_init+change_con_pos*1000) ; (cons_init+change_con_pos(end)*1000)*ones(p_time_sim-length((cons_init+change_con_pos*1000)),1)];
                consum_sim((t_init+1):(t_init+p_time_sim),2) = [(cons_init+change_con_pos(1:p_time_sim)*1000)];
                
                %lenad = (t_init)/(t_init+p_time_sim)*1000;
                
                % Increase resolution of data 
                x = 1:length(consum_sim(:,2));
                y1 = consum_sim(:,2);
                ces1 = spline(x,y1);
                xx = linspace(1,length(consum_sim(:,2)),1000);

                consum_sim = [xx' ppval(ces1,xx)'];               
            end
            
            
            % Run the simulation and save results:
            if (cons_init>0)
                
                sim('HEMS_v1')

                % SOLUTION
                f_max = max(F_HZ.Data(F_HZ.Time>t_init));
                f_min = min(F_HZ.Data(F_HZ.Time>t_init));
                %f_end = [f_end; F_HZ.Data(F_HZ.Time==(t_init+20))];
                
                str_RES = strcat(num2str(potmax_pv_init/1e6),'_bat_',num2str(Setp_Batt/1e6),'_D_',num2str(n_diesels),'.mat');

                %'Results/pv_',
                mindies = min(mindies,n_diesels);
                
                if(f_min > f_acceptable)
                    fprintf('Min Dies = %d\n', mindies);
                    STRUCT(length(STRUCT)+1) = struct(field1,str_RES,field2,n_diesels,field3,Setp_Batt,field4,potmax_pv_init,field5,f_max,field6,f_min,field7,mindies,field8,n_diesels-mindies);
                else
                    fprintf('Disregarding - f_min = %d\n', f_min);
                end
            end  
           
         end 
	end
end

STRUCT(1) = [];

save('../../Data/Generated Data/4 - Frequency/result_sim','STRUCT');

