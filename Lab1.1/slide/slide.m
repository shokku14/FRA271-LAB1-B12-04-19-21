%% Linear Potentiometer Analysis - 3 Runs
clear; clc; close all;

%% ---------------------------------------------------------
%  Files
% ----------------------------------------------------------
files = {
    'linear_run1_raw.mat'
    'linear_run2_raw.mat'
    'linear_run3_raw.mat'
};

numRuns = numel(files);

% ตำแหน่งที่ใช้ในการทดลอง
slidePos = 0:5:60;            % mm
travelPct = slidePos / 60 * 100;

% เตรียมตัวแปรเก็บผล
L1_voltage = zeros(numRuns, numel(slidePos));   % A3
L2_voltage = zeros(numRuns, numel(slidePos));   % A4


%% ---------------------------------------------------------
%  Folder สำหรับ Save รูป
% ----------------------------------------------------------
saveFolder = 'Linear_Plots';

if ~exist(saveFolder, 'dir')
    mkdir(saveFolder);
end


%% ---------------------------------------------------------
%  Load data and extract voltage at each Slide_Position
% ----------------------------------------------------------
for r = 1:numRuns

    S = load(files{r});
    out = S.out;

    % อ่านค่าจาก Simulink
    slideTS = out.Slide_raw;
    L1_TS   = out.A3_voltage;
    L2_TS   = out.A4_voltage;

    % แปลงเป็น double
    slide = double(squeeze(slideTS.Data));
    L1    = double(squeeze(L1_TS.Data));
    L2    = double(squeeze(L2_TS.Data));

    % เวลา
    tSlide = double(slideTS.Time);
    tL1    = double(L1_TS.Time);
    tL2    = double(L2_TS.Time);

    % ถ้า time vector ไม่ตรงกัน ให้ interpolate
    % มาที่เวลาเดียวกับ Slide_Position
    if length(L1) ~= length(slide) || any(tL1 ~= tSlide)
        L1 = interp1(tL1, L1, tSlide, 'linear', 'extrap');
    end

    if length(L2) ~= length(slide) || any(tL2 ~= tSlide)
        L2 = interp1(tL2, L2, tSlide, 'linear', 'extrap');
    end

    % ------------------------------------------------------
    % หาค่า Voltage ของแต่ละตำแหน่ง
    % ใช้ median ของข้อมูลที่มี Slide_Position เดียวกัน
    % ------------------------------------------------------
    for k = 1:numel(slidePos)

        p = slidePos(k);

        idx = (slide == p);

        if any(idx)

            L1_voltage(r,k) = median(L1(idx), 'omitnan');
            L2_voltage(r,k) = median(L2(idx), 'omitnan');

        else

            L1_voltage(r,k) = NaN;
            L2_voltage(r,k) = NaN;

            warning('Run %d: ไม่พบ Slide Position = %g mm', r, p);

        end

    end
end


%% =========================================================
%  GRAPH 1
%  L1 (A3) - Voltage Response, Run 1-3
% ==========================================================

fig1 = figure('Color','w');

hold on;

plot(slidePos, L1_voltage(1,:), '-o', ...
    'LineWidth', 1.8, ...
    'MarkerSize', 7);

plot(slidePos, L1_voltage(2,:), '-s', ...
    'LineWidth', 1.8, ...
    'MarkerSize', 7);

plot(slidePos, L1_voltage(3,:), '-^', ...
    'LineWidth', 1.8, ...
    'MarkerSize', 7);

hold off;

xlabel('Slide Position (mm)');
ylabel('Output Voltage (V)');

title('Output Voltage Response of L1 (A3) for Run 1-3');

legend( ...
    'Run 1', ...
    'Run 2', ...
    'Run 3', ...
    'Location', 'best');

grid on;

xlim([0 60]);
xticks(0:5:60);

% ---------------- SAVE ----------------
pngFile1 = fullfile(saveFolder, ...
    'Linear_L1_A3_Voltage_Response_Run1-3.png');

figFile1 = fullfile(saveFolder, ...
    'Linear_L1_A3_Voltage_Response_Run1-3.fig');

exportgraphics(fig1, pngFile1, ...
    'Resolution', 300);

savefig(fig1, figFile1);


%% =========================================================
%  GRAPH 2
%  L2 (A4) - Voltage Response, Run 1-3
% ==========================================================

fig2 = figure('Color','w');

hold on;

plot(slidePos, L2_voltage(1,:), '-o', ...
    'LineWidth', 1.8, ...
    'MarkerSize', 7);

plot(slidePos, L2_voltage(2,:), '-s', ...
    'LineWidth', 1.8, ...
    'MarkerSize', 7);

plot(slidePos, L2_voltage(3,:), '-^', ...
    'LineWidth', 1.8, ...
    'MarkerSize', 7);

hold off;

xlabel('Slide Position (mm)');
ylabel('Output Voltage (V)');

title('Output Voltage Response of L2 (A4) for Run 1-3');

legend( ...
    'Run 1', ...
    'Run 2', ...
    'Run 3', ...
    'Location', 'best');

grid on;

xlim([0 60]);
xticks(0:5:60);

% ---------------- SAVE ----------------
pngFile2 = fullfile(saveFolder, ...
    'Linear_L2_A4_Voltage_Response_Run1-3.png');

figFile2 = fullfile(saveFolder, ...
    'Linear_L2_A4_Voltage_Response_Run1-3.fig');

exportgraphics(fig2, pngFile2, ...
    'Resolution', 300);

savefig(fig2, figFile2);


%% =========================================================
%  GRAPH 3
%  Measured Linear Potentiometer Tapers
% ==========================================================

% Normalize แต่ละ Run แยกกันเป็น 0-100 %
L1_norm = zeros(size(L1_voltage));
L2_norm = zeros(size(L2_voltage));

for r = 1:numRuns

    L1_norm(r,:) = ...
        (L1_voltage(r,:) - L1_voltage(r,1)) ./ ...
        (L1_voltage(r,end) - L1_voltage(r,1)) * 100;

    L2_norm(r,:) = ...
        (L2_voltage(r,:) - L2_voltage(r,1)) ./ ...
        (L2_voltage(r,end) - L2_voltage(r,1)) * 100;

end

% ค่าเฉลี่ยของ 3 Runs
L1_mean = mean(L1_norm, 1, 'omitnan');
L2_mean = mean(L2_norm, 1, 'omitnan');

% Linear Reference
linearReference = travelPct;


fig3 = figure('Color','w');

hold on;

plot(travelPct, L1_mean, '-o', ...
    'LineWidth', 2, ...
    'MarkerSize', 7);

plot(travelPct, L2_mean, '-s', ...
    'LineWidth', 2, ...
    'MarkerSize', 7);

plot(travelPct, linearReference, '--', ...
    'LineWidth', 1.8);

hold off;

xlabel('Slide Travel (% of 60 mm)');
ylabel('Normalized Output (%)');

title('Measured Linear Potentiometer Tapers');

legend( ...
    'L1: A3 (Mean of 3 Runs)', ...
    'L2: A4 (Mean of 3 Runs)', ...
    'Linear Reference', ...
    'Location', 'best');

grid on;

xlim([0 100]);
ylim([0 100]);

xticks(0:10:100);
yticks(0:10:100);

% ---------------- SAVE ----------------
pngFile3 = fullfile(saveFolder, ...
    'Linear_Potentiometer_Tapers_Mean3Runs.png');

figFile3 = fullfile(saveFolder, ...
    'Linear_Potentiometer_Tapers_Mean3Runs.fig');

exportgraphics(fig3, pngFile3, ...
    'Resolution', 300);

savefig(fig3, figFile3);


%% ---------------------------------------------------------
%  แสดงค่าที่สรุปได้
% ----------------------------------------------------------

disp(' ');
disp('L1 (A3) Voltage');

disp(array2table( ...
    L1_voltage, ...
    'VariableNames', compose('Pos_%dmm', slidePos), ...
    'RowNames', {'Run1','Run2','Run3'}));


disp(' ');
disp('L2 (A4) Voltage');

disp(array2table( ...
    L2_voltage, ...
    'VariableNames', compose('Pos_%dmm', slidePos), ...
    'RowNames', {'Run1','Run2','Run3'}));


%% ---------------------------------------------------------
%  แจ้งตำแหน่งที่ Save รูป
% ----------------------------------------------------------

fprintf('\n========================================\n');
fprintf('Saved figures to folder:\n');
fprintf('%s\n', fullfile(pwd, saveFolder));
fprintf('========================================\n');

fprintf('\n1. %s\n', pngFile1);
fprintf('2. %s\n', pngFile2);
fprintf('3. %s\n', pngFile3);