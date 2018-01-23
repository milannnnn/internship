clear;
close all;
clc;


load('../../Data/Generated Data/1 - Secondly/gen_seg_org');

t = (1:length(gen_seg_org))';

my_params = load('../../Data/System Params/params');

gen_seg = ramping( gen_seg_org, t, my_params.rr_PV, my_params.P_PV_inst );

plot(t,gen_seg_org,t,gen_seg);

save('../../Data/Generated Data/1 - Secondly/gen_seg','gen_seg');