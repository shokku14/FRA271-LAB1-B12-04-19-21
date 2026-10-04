%% Rotary Potentiometer Analysis - 3 Runs
clear; clc; close all;

%% ---------------------------------------------------------
%  Files
% ----------------------------------------------------------
files = {
    'rotary_run1_raw.mat'
    'rotary_run2_raw.mat'
    'rotary_run3_raw.mat'
};

numRuns = numel(files);

% ตำแหน่ง Dial ที่ใช้ในการทดลอง
dialPos = 0:5:100;
travelPct = dialPos;   % Dial 0-100 ตรงกับ 0-100 %

% เตรียมตัวแปรเก็บผล
A0_voltage = zeros(numRuns, numel(dialPos));
A1_voltage = zeros(numRuns, numel(dialPos));
A2_voltage = zeros(numRuns, numel(dialPos));


%% ---------------------------------------------------------
%  Folder สำหรับ Save รูป
% ----------------------------------------------------------
saveFolder = 'Rotary_Plots';

if ~exist(saveFolder, 'dir')
    mkdir(saveFolder);
end


%% ---------------------------------------------------------
%  Load data
% ----------------------------------------------------------
for r = 1:numRuns

    S = load(files{r});
    out = S.out;

    % อ่านข้อมูลจาก Simulink
    dialTS = out.Dial_raw;

    A0_TS = out.A0_voltage;
    A1_TS = out.A1_voltage;
    A2_TS = out.A2_voltage;

    % Data
    dial = double(squeeze(dialTS.Data));

    A0 = double(squeeze(A0_TS.Data));
    A1 = double(squeeze(A1_TS.Data));
    A2 = double(squeeze(A2_TS.Data));

    % Time
    tDial = double(dialTS.Time);

    tA0 = double(A0_TS.Time);
    tA1 = double(A1_TS.Time);
    tA2 = double(A2_TS.Time);

    % ------------------------------------------------------
    % Interpolate ถ้า Time Vector ไม่ตรงกัน
    % ------------------------------------------------------
    if length(A0) ~= length(dial) || any(tA0 ~= tDial)
        A0 = interp1(tA0, A0, tDial, 'linear', 'extrap');
    end

    if length(A1) ~= length(dial) || any(tA1 ~= tDial)
        A1 = interp1(tA1, A1, tDial, 'linear', 'extrap');
    end

    if length(A2) ~= length(dial) || any(tA2 ~= tDial)
        A2 = interp1(tA2, A2, tDial, 'linear', 'extrap');
    end


    %% -----------------------------------------------------
    %  Extract Voltage ตาม Dial Position
    %  ใช้ Median ของข้อมูลในตำแหน่งเดียวกัน
    % ------------------------------------------------------
    for k = 1:numel(dialPos)

        p = dialPos(k);

        idx = (dial == p);

        if any(idx)

            A0_voltage(r,k) = median(A0(idx), 'omitnan');
            A1_voltage(r,k) = median(A1(idx), 'omitnan');
            A2_voltage(r,k) = median(A2(idx), 'omitnan');

        else

            A0_voltage(r,k) = NaN;
            A1_voltage(r,k) = NaN;
            A2_voltage(r,k) = NaN;

            warning('Run %d: ไม่พบ Dial Position = %g', r, p);

        end

    end
end


%% =========================================================
%  GRAPH 1
%  Rotary Potentiometer Voltage Response - Run 1-3
% ==========================================================

fig1 = figure('Color','w');

tiledlayout(1,3, ...
    'TileSpacing','compact', ...
    'Padding','compact');


%% A0
nexttile;

hold on;

plot(dialPos, A0_voltage(1,:), '-o', ...
    'LineWidth', 1.8, 'MarkerSize', 6);

plot(dialPos, A0_voltage(2,:), '-s', ...
    'LineWidth', 1.8, 'MarkerSize', 6);

plot(dialPos, A0_voltage(3,:), '-^', ...
    'LineWidth', 1.8, 'MarkerSize', 6);

hold off;

title('A0');
xlabel('Dial Scale (0-100)');
ylabel('Output Voltage (V)');

grid on;
xlim([0 100]);
xticks(0:10:100);

legend('Run 1','Run 2','Run 3', ...
    'Location','best');


%% A1
nexttile;

hold on;

plot(dialPos, A1_voltage(1,:), '-o', ...
    'LineWidth', 1.8, 'MarkerSize', 6);

plot(dialPos, A1_voltage(2,:), '-s', ...
    'LineWidth', 1.8, 'MarkerSize', 6);

plot(dialPos, A1_voltage(3,:), '-^', ...
    'LineWidth', 1.8, 'MarkerSize', 6);

hold off;

title('A1');
xlabel('Dial Scale (0-100)');
ylabel('Output Voltage (V)');

grid on;
xlim([0 100]);
xticks(0:10:100);

legend('Run 1','Run 2','Run 3', ...
    'Location','best');


%% A2
nexttile;

hold on;

plot(dialPos, A2_voltage(1,:), '-o', ...
    'LineWidth', 1.8, 'MarkerSize', 6);

plot(dialPos, A2_voltage(2,:), '-s', ...
    'LineWidth', 1.8, 'MarkerSize', 6);

plot(dialPos, A2_voltage(3,:), '-^', ...
    'LineWidth', 1.8, 'MarkerSize', 6);

hold off;

title('A2');
xlabel('Dial Scale (0-100)');
ylabel('Output Voltage (V)');

grid on;
xlim([0 100]);
xticks(0:10:100);

legend('Run 1','Run 2','Run 3', ...
    'Location','best');


sgtitle('Rotary Potentiometer Voltage Response for Run 1-3');


%% Save GRAPH 1
pngFile1 = fullfile(saveFolder, ...
    'Rotary_Voltage_Response_Run1-3.png');

figFile1 = fullfile(saveFolder, ...
    'Rotary_Voltage_Response_Run1-3.fig');

exportgraphics(fig1, pngFile1, ...
    'Resolution', 300);

savefig(fig1, figFile1);



%% =========================================================
%  GRAPH 2
%  Measured Rotary Potentiometer Tapers
% ==========================================================

% Normalize แต่ละ Run แยกเป็น 0-100 %
A0_norm = zeros(size(A0_voltage));
A1_norm = zeros(size(A1_voltage));
A2_norm = zeros(size(A2_voltage));

for r = 1:numRuns

    A0_norm(r,:) = ...
        (A0_voltage(r,:) - A0_voltage(r,1)) ./ ...
        (A0_voltage(r,end) - A0_voltage(r,1)) * 100;

    A1_norm(r,:) = ...
        (A1_voltage(r,:) - A1_voltage(r,1)) ./ ...
        (A1_voltage(r,end) - A1_voltage(r,1)) * 100;

    A2_norm(r,:) = ...
        (A2_voltage(r,:) - A2_voltage(r,1)) ./ ...
        (A2_voltage(r,end) - A2_voltage(r,1)) * 100;

end


% ค่าเฉลี่ยจาก 3 Runs
A0_mean = mean(A0_norm, 1, 'omitnan');
A1_mean = mean(A1_norm, 1, 'omitnan');
A2_mean = mean(A2_norm, 1, 'omitnan');

% Linear Reference
linearReference = travelPct;


fig2 = figure('Color','w');

hold on;

plot(travelPct, A0_mean, '-o', ...
    'LineWidth', 2, ...
    'MarkerSize', 7);

plot(travelPct, A1_mean, '-s', ...
    'LineWidth', 2, ...
    'MarkerSize', 7);

plot(travelPct, A2_mean, '-^', ...
    'LineWidth', 2, ...
    'MarkerSize', 7);

plot(travelPct, linearReference, '--', ...
    'LineWidth', 1.8);

hold off;

xlabel('Travel (% of Dial Span)');
ylabel('Normalized Output (%)');

title('Measured Rotary Potentiometer Tapers');

legend( ...
    'A0 (Mean of 3 Runs)', ...
    'A1 (Mean of 3 Runs)', ...
    'A2 (Mean of 3 Runs)', ...
    'Linear Reference', ...
    'Location','best');

grid on;

xlim([0 100]);
ylim([0 100]);

xticks(0:10:100);
yticks(0:10:100);


%% Save GRAPH 2
pngFile2 = fullfile(saveFolder, ...
    'Rotary_Potentiometer_Tapers_Mean3Runs.png');

figFile2 = fullfile(saveFolder, ...
    'Rotary_Potentiometer_Tapers_Mean3Runs.fig');

exportgraphics(fig2, pngFile2, ...
    'Resolution', 300);

savefig(fig2, figFile2);



%% ---------------------------------------------------------
%  แสดงตารางค่า Voltage
% ----------------------------------------------------------

disp(' ');
disp('A0 Voltage');

disp(array2table( ...
    A0_voltage, ...
    'VariableNames', compose('Dial_%d', dialPos), ...
    'RowNames', {'Run1','Run2','Run3'}));


disp(' ');
disp('A1 Voltage');

disp(array2table( ...
    A1_voltage, ...
    'VariableNames', compose('Dial_%d', dialPos), ...
    'RowNames', {'Run1','Run2','Run3'}));


disp(' ');
disp('A2 Voltage');

disp(array2table( ...
    A2_voltage, ...
    'VariableNames', compose('Dial_%d', dialPos), ...
    'RowNames', {'Run1','Run2','Run3'}));


%% ---------------------------------------------------------
%  แจ้งตำแหน่ง Save
% ----------------------------------------------------------

fprintf('\n========================================\n');
fprintf('Saved figures to:\n');
fprintf('%s\n', fullfile(pwd, saveFolder));
fprintf('========================================\n');

fprintf('\n1. %s\n', pngFile1);
fprintf('2. %s\n', pngFile2);