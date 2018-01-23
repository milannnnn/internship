function [ P_r ] = ramping( P, t, rr, P_PV )
%RAMPING - Function for ramping of PV generation
%   
%   P     - PV  generation       [kW]
%   t     - time vector          [s]
%   rr    - ramp rate            [%/min]
%   P_PV  - installed power      [kW]
%   
%   P_r - ramped PV generation [kW]


% P_PV = 15000; % Rated PV power [kW]

max_dP =   (rr/100) * P_PV / 60; % Max power increment [kW/s]
min_dP = - (rr/100) * P_PV / 60; % Min power increment [kW/s]

P_r = zeros(length(P),1);

P_r(1) = P(1);

for k=2:length(P)

    % If the power increment is larger than max allowed - limit it at top
    if     P(k) - P_r(k-1) > max_dP*(t(k)-t(k-1))
        P_r(k) = P_r(k-1) + max_dP*(t(k)-t(k-1));
        
    % If the power increment is lower than min allowed - limit it at bottom
    elseif P(k) - P_r(k-1) < min_dP*(t(k)-t(k-1))
        P_r(k) = P_r(k-1) + min_dP*(t(k)-t(k-1));
        
    % Otherwise leave it as it was
    else
        P_r(k) = P(k);
    end
    
end

end

