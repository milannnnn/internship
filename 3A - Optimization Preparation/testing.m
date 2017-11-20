clear all;
close all;
clc;

load('../../Data/Generated Data/2 - Scenarios/cons_scen.mat')
load('../../Data/Generated Data/2 - Scenarios/gen_scen.mat')

ploting = 'yes';
% ploting = 'no';

max(max(max((cons_scen-gen_scen))));

N_dies  =  12; % num of diesel generators
P_dies_max = 1100.0;
marge_dies = 2200;

t_final = length(gen_scen);
h_firm  = 3;
t_firm  = t_final/24*h_firm;

t_scen = 1:t_firm;
t_mean = (t_firm+1):t_final;

%% Plot Desired interval:

% interval = 105;
% 
% P_scen = P_dies_max*N_dies-cons_scen(:,:,interval)+gen_scen(:,:,interval);
% P_mean = mean(P_dies_max*N_dies-cons_scen(:,:,interval)+gen_scen(:,:,interval),2);
% 
% figure(); hold all;
% plot(t_scen,P_scen(t_scen,:));
% plot(t_mean,P_mean(t_mean));
% plot(marge_dies*ones(length(cons_scen),1),'r');

%% Check each interval:

k=0;
for interval = 1:size(gen_scen,3)
    
    P_scen = P_dies_max*N_dies-cons_scen(:,:,interval)+gen_scen(:,:,interval);
    P_mean = mean(P_dies_max*N_dies-cons_scen(:,:,interval)+gen_scen(:,:,interval),2);
    
    P_tot = [P_scen(t_scen,:); P_mean(t_mean)*ones(1,5)];
    
    if(sum(sum(sum((P_tot)<marge_dies)))>0)
        k = k+1;
        fprintf('Interval %d is INFEASIBLE!!!\n', interval);
        
        if strcmp(ploting,'yes')
            figure(); hold all;
            plot(P_tot); legend(['int ' num2str(interval)]);
            plot(marge_dies*ones(length(cons_scen),1),'r');
        end
    end
    
end
k


%%
% figure();
% subplot(2,2,[1 3]);
% plot(P_dies_max*N_dies-cons_scen(:,:,interval)+gen_scen(:,:,interval));
% hold all;
% plot(marge_dies*ones(length(cons_scen),1),'r');
% ylim([0 3.0e4]);
 
%%
% % figure();
% subplot(2,2,[2 4]);
% plot(mean(P_dies_max*N_dies-cons_scen(:,:,interval)+gen_scen(:,:,interval),2));
% hold all;
% plot(marge_dies*ones(length(cons_scen),1),'r');
% ylim([0 3.0e4]);

%%

% sum(sum(sum((gen_scen+N_dies*P_dies_max-cons_scen)<marge_dies)))

%%

% sum(sum(mean(gen_scen+N_dies*P_dies_max-cons_scen,2)<marge_dies))


