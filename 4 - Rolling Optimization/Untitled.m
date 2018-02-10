close all;

load('../../Data/Generated Data/1 - Secondly/cons_seg');
load('../../Data/Generated Data/1 - Secondly/gen_seg');

%%
figure();
plot(cons_seg*1e-3); hold all;
xlabel('Time [s]'); grid minor; %title ('Consumption'); 
ylabel('P_{CONS} [MW]'); ylim([0 10]); xlim([1 length(cons_seg)]);
myplot('cons_sec');

%%
figure();
plot(gen_seg*1e-3);
xlabel('Time [s]'); grid minor; %title ('PV generation'); 
ylabel('P_{PV} [MW]'); ylim([0 15]); xlim([1 length(gen_seg)]);
myplot('gen_sec');

%%

load('../../Data/Generated Data/3 - Changes/M_change_pos.mat')
load('../../Data/Generated Data/3 - Changes/M_change_neg.mat')

%% 

figure();
plot(change_con_pos*1e-3);
xlabel('Time [s]'); grid minor; %title ('Max Consumption Unbalance');
ylabel('\Delta P_{Cons} [MW]'); xlim([0 60]);
myplot('cons_unb');

%% 

figure();
plot(change_gen_all_neg'*1e-3);
xlabel('Time [s]'); grid minor; %title ('Max Generaion Unbalance');
ylabel('\Delta P_{PV} [MW]'); xlim([0 60]);
myplot('gen_unb');
