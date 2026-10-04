clear
clc
close all

%% =========================
% Load Data
% =========================
S = load('realtimeA0_weight_mV.mat');
data = S.data;

%% =========================
% Get A0 Raw Data
% =========================
A0 = data.get('A0');

t = A0.Values.Time;
raw = double(A0.Values.Data);

%% =========================
% Raw -> Voltage (V)
% Raw = 3135 -> 2.551 V
% =========================
V = raw .* (2.551 / 3135);

%% =========================
% Voltage -> Weight (kg)
% 2.551 V -> 10 kg
% =========================
weight_kg = V .* (10 / 2.551);

%% =========================
% Colors
% =========================
rawColor     = [0.00 0.67 1.00];   % Blue
voltageColor = [0.85 0.55 0.00];   % Dark Yellow
weightColor  = [0.45 0.20 0.70];   % Purple

%% =========================
% Create Figure
% =========================
figure( ...
    'Color', [0.12 0.12 0.12], ...
    'Position', [100 50 1200 900]);

tl = tiledlayout(3,1);

tl.TileSpacing = 'compact';
tl.Padding = 'compact';

%% =========================
% Graph 1 : Raw Data
% =========================
ax1 = nexttile;

plot(t, raw, '-', ...
    'LineWidth', 2.0, ...
    'Color', rawColor);

title('Load Cell Response: Raw Data', ...
    'Color', 'w', ...
    'FontSize', 16, ...
    'FontWeight', 'bold');

ylabel('Raw Data', ...
    'Color', 'w', ...
    'FontSize', 13, ...
    'FontWeight', 'bold');

grid on
grid minor
box on

set_axis_style(ax1);


%% =========================
% Graph 2 : Voltage
% =========================
ax2 = nexttile;

plot(t, V, '-', ...
    'LineWidth', 2.0, ...
    'Color', voltageColor);

title('Load Cell Response: Voltage', ...
    'Color', 'w', ...
    'FontSize', 16, ...
    'FontWeight', 'bold');

ylabel('Voltage (V)', ...
    'Color', 'w', ...
    'FontSize', 13, ...
    'FontWeight', 'bold');

grid on
grid minor
box on

set_axis_style(ax2);


%% =========================
% Graph 3 : Weight
% =========================
ax3 = nexttile;

plot(t, weight_kg, '-', ...
    'LineWidth', 2.0, ...
    'Color', weightColor);

title('Load Cell Response: Weight', ...
    'Color', 'w', ...
    'FontSize', 16, ...
    'FontWeight', 'bold');

xlabel('Time (s)', ...
    'Color', 'w', ...
    'FontSize', 13, ...
    'FontWeight', 'bold');

ylabel('Weight (kg)', ...
    'Color', 'w', ...
    'FontSize', 13, ...
    'FontWeight', 'bold');

grid on
grid minor
box on

set_axis_style(ax3);

%% =========================
% Make X axes move together
% =========================
linkaxes([ax1 ax2 ax3], 'x');


%% =========================================================
% Local Function : Axis Style
% =========================================================
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