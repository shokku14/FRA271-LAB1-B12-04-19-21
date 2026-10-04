clear
clc
close all

%% =========================
%  EXPERIMENT 1 : CALIBRATION
%  =========================

% ---------- Set 1 ----------
reference1 = [ ...
    0 467 967 1441 1940 2411 2851 3347 3839 4321 ...
    4950 5443 5927 6419 6896 7395 7888 8383 8881 9347 9965];

measured1 = [ ...
    15.15 156.3 605.3 1103 1643 2176 2811 3339 3869 4411 ...
    4811 5338 5861 6403 6916 7458 7970 8485 9007 9501 9988];


% ---------- Set 2 ----------
reference2 = [ ...
    0 484 983 1474 1951 2547 3030 3516 4003 4481 ...
    4922 5421 5904 6399 6892 7391 7874 8372 8953 9447 10055];

measured2 = [ ...
    24.72 160.3 586.9 1113 1647 2266 2818 3335 3867 4370 ...
    4816 5340 5853 6388 6903 7431 7937 8458 9103 9624 9990];


%% =========================
%  Figure 12
%  Reference vs Measured
%  =========================

set1Color = [0.00 0.67 1.00];
set2Color = [0.85 0.55 0.00];
idealColor = [0.75 0.75 0.75];

figure('Color',[0.12 0.12 0.12], ...
       'Position',[100 100 1000 700]);

plot(reference1, measured1, '-', ...
    'LineWidth',2.2, ...
    'Color',set1Color);

hold on

plot(reference2, measured2, '-', ...
    'LineWidth',2.2, ...
    'Color',set2Color);

% Ideal line y = x
maxMass = max([reference1 reference2 measured1 measured2]);

plot([0 maxMass],[0 maxMass],'--', ...
    'LineWidth',1.8, ...
    'Color',idealColor);

hold off

title('Reference Mass vs Measured Mass', ...
    'Color','w', ...
    'FontSize',16, ...
    'FontWeight','bold');

xlabel('Reference Mass (g)', ...
    'Color','w', ...
    'FontSize',13, ...
    'FontWeight','bold');

ylabel('Measured Mass (g)', ...
    'Color','w', ...
    'FontSize',13, ...
    'FontWeight','bold');

legend('Set 1','Set 2','Ideal y = x', ...
    'Location','northwest', ...
    'TextColor','w', ...
    'Color',[0.12 0.12 0.12]);

grid on
grid minor
box on

ax = gca;
set_axis_style(ax);

axis equal
xlim([0 10500])
ylim([0 10500])


%% =========================
%  CALIBRATION EQUATION
%
%  x = Measured Mass
%  y = Reference Mass
%
%  Reference = a(Measured) + b
%  =========================

p1 = polyfit(measured1, reference1, 1);
p2 = polyfit(measured2, reference2, 1);

a1 = p1(1);
b1 = p1(2);

a2 = p2(1);
b2 = p2(2);

% Predicted reference mass
cal1 = polyval(p1, measured1);
cal2 = polyval(p2, measured2);

% R^2
SSres1 = sum((reference1 - cal1).^2);
SStot1 = sum((reference1 - mean(reference1)).^2);
R2_1 = 1 - SSres1/SStot1;

SSres2 = sum((reference2 - cal2).^2);
SStot2 = sum((reference2 - mean(reference2)).^2);
R2_2 = 1 - SSres2/SStot2;


%% Display calibration results
fprintf('\n===== CALIBRATION RESULT =====\n');

fprintf('Set 1:\n');
fprintf('Reference = %.6f(Measured) + %.3f\n',a1,b1);
fprintf('R^2 = %.5f\n\n',R2_1);

fprintf('Set 2:\n');
fprintf('Reference = %.6f(Measured) + %.3f\n',a2,b2);
fprintf('R^2 = %.5f\n\n',R2_2);

slopeDifference = abs(a1-a2)/((a1+a2)/2)*100;

fprintf('Slope difference = %.3f %%\n',slopeDifference);


%% =========================
%  Figure 13
%  Calibration Regression
%  =========================

xFit = linspace(0,10500,500);

yFit1 = polyval(p1,xFit);
yFit2 = polyval(p2,xFit);

figure('Color',[0.12 0.12 0.12], ...
       'Position',[150 100 1000 700]);

% Experimental points
scatter(measured1,reference1,55, ...
    set1Color,'filled');

hold on

scatter(measured2,reference2,55, ...
    set2Color,'filled');

% Regression
plot(xFit,yFit1,'-', ...
    'LineWidth',2.3, ...
    'Color',set1Color);

plot(xFit,yFit2,'-', ...
    'LineWidth',2.3, ...
    'Color',set2Color);

% Ideal
plot(xFit,xFit,'--', ...
    'LineWidth',1.8, ...
    'Color',idealColor);

hold off

title('Load Cell Calibration and Linear Regression', ...
    'Color','w', ...
    'FontSize',16, ...
    'FontWeight','bold');

xlabel('Measured Mass (g)', ...
    'Color','w', ...
    'FontSize',13, ...
    'FontWeight','bold');

ylabel('Reference Mass (g)', ...
    'Color','w', ...
    'FontSize',13, ...
    'FontWeight','bold');

legend( ...
    'Set 1 Data', ...
    'Set 2 Data', ...
    sprintf('Set 1: y = %.4fx %+.2f, R^2 = %.5f',a1,b1,R2_1), ...
    sprintf('Set 2: y = %.4fx %+.2f, R^2 = %.5f',a2,b2,R2_2), ...
    'Ideal y = x', ...
    'Location','northwest', ...
    'TextColor','w', ...
    'Color',[0.12 0.12 0.12]);

grid on
grid minor
box on

ax = gca;
set_axis_style(ax);

axis equal
xlim([0 10500])
ylim([0 10500])


%% =========================
%  Percentage Error
%  =========================

error1 = abs(measured1-reference1)./reference1*100;
error2 = abs(measured2-reference2)./reference2*100;

% Percentage error at 0 g is undefined
error1(reference1 == 0) = NaN;
error2(reference2 == 0) = NaN;

allError = [error1 error2];

meanPercentError = mean(allError,'omitnan');

fprintf('\n===== ERROR =====\n');
fprintf('Mean Percentage Error = %.2f %%\n',meanPercentError);


%% =========================
%  Axis Style Function
%  =========================

function set_axis_style(ax)

    ax.Color = [0.05 0.05 0.05];

    ax.XColor = [0.85 0.85 0.85];
    ax.YColor = [0.85 0.85 0.85];

    ax.FontSize = 11;
    ax.LineWidth = 1.2;

    ax.GridColor = [0.5 0.5 0.5];
    ax.MinorGridColor = [0.35 0.35 0.35];

    ax.GridAlpha = 0.35;
    ax.MinorGridAlpha = 0.25;

end