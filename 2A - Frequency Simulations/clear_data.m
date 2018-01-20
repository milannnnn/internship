clear all;
clc;

load('../../Data/Generated Data/4 - Frequency/result_sim_new_75');


% f_min
% P_pv_curt
% P_bat
% 

ns = [ 3    4    5    6    7    8    9   10   11   12];
fs = [47 47.2 47.4 47.5 47.5 47.6 47.8 48.1 48.2 48.3];

k = 1;
while k<=length(STRUCT)
    if(STRUCT(k).num_dies < 4)
        STRUCT(k) = [];
        k = k-1;
    end
    k = k+1;
end

k=1;
while k<=length(STRUCT)
    if(STRUCT(k).f_min < 48.65)
        STRUCT(k) = [];
        k = k-1;
    end
    k = k+1;
end

% k=1;
% while k<=length(STRUCT)
%     if(STRUCT(k).f_min < fs(STRUCT(k).num_dies-2))
%         STRUCT(k) = [];
%         k = k-1;
%     end
%     k = k+1;
% end


save('../../Data/Generated Data/4 - Frequency/result_sim','STRUCT');

