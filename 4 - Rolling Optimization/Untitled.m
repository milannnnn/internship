close all;

load('../../Data/Generated Data/1 - Secondly/cons_seg');
load('../../Data/Generated Data/1 - Secondly/gen_seg');

%%
figure();
plot(cons_seg*1e-3); hold all;
xlabel('Time [s]'); title ('Consumption'); grid minor;
ylabel('P_{CONS} [MW]'); ylim([0 10]); xlim([1 length(cons_seg)]);
myplot('cons_sec');

%%
figure();
plot(gen_seg*1e-3);
xlabel('Time [s]'); title ('PV generation'); grid minor;
ylabel('P_{PV} [MW]'); ylim([0 15]); xlim([1 length(gen_seg)]);
myplot('gen_sec');