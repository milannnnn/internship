function [] = myplot(name)
%MYPLOT Summary of this function goes here
%   Detailed explanation goes here
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperSize = [20 10];
fig.PaperPosition = [0-0.25 0+0.35 20-0.10 10-0.65];

ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

print(fig,['../../Figures/' name],'-dpdf')

end

% ax = gca;
% outerpos = ax.OuterPosition;
% ti = ax.TightInset; 
% left = outerpos(1) + ti(1);
% bottom = outerpos(2) + ti(2);
% ax_width = outerpos(3) - ti(1) - ti(3);
% ax_height = outerpos(4) - ti(2) - ti(4);
% ax.Position = [left bottom ax_width ax_height];
% 
% fig = gcf;
% fig.PaperUnits = 'centimeters';
% fig.PaperSize = [15 11.5];
% print(fig,['Latex/photos/' name],'-dpdf')
% 
% end

