%CREATECONCLUSIVEVISUALIZATIONS Build the final outbreak-origin dashboard.

projectRoot = string(fileparts(mfilename('fullpath')));
resultRoot = fullfile(projectRoot, "results", "outbreak_origin_scenarios");
outputRoot = fullfile(projectRoot, "output", "analysis");
if ~isfolder(outputRoot), mkdir(outputRoot); end

primary = readtable(fullfile(resultRoot, "scenario_comparison.csv"), TextType="string");
replications = readtable(fullfile(resultRoot, "replicated_scenario_outcomes.csv"), TextType="string");
replications.infection_rate_percent = 100 * replications.infected ./ replications.initial_total;

scenarioNames = primary.scenario;
shortNames = ["Floor 2" "Floor 8" "Floor 16"];
colors = [0.20 0.55 0.85; 0.95 0.55 0.12; 0.75 0.15 0.18];
primary.infection_rate_percent = 100 * primary.infected ./ primary.initial_total;

meanInfectionRate = zeros(height(primary), 1);
stdInfectionRate = zeros(height(primary), 1);
meanEscapeRate = zeros(height(primary), 1);
stdEscapeRate = zeros(height(primary), 1);
for index = 1:height(primary)
    selected = replications.scenario == scenarioNames(index);
    meanInfectionRate(index) = mean(replications.infection_rate_percent(selected));
    stdInfectionRate(index) = std(replications.infection_rate_percent(selected));
    meanEscapeRate(index) = mean(replications.escape_rate_percent(selected));
    stdEscapeRate(index) = std(replications.escape_rate_percent(selected));
end

normalizedSummary = table(scenarioNames, primary.infected, primary.non_infected, ...
    primary.escaped, primary.infection_rate_percent, primary.escape_rate_percent, ...
    meanInfectionRate, stdInfectionRate, meanEscapeRate, stdEscapeRate, ...
    'VariableNames', {'scenario', 'primary_infected', 'primary_non_infected', ...
    'primary_escaped', 'primary_infection_rate_percent', 'primary_escape_rate_percent', ...
    'three_seed_mean_infection_rate_percent', 'three_seed_std_infection_rate_percent', ...
    'three_seed_mean_escape_rate_percent', 'three_seed_std_escape_rate_percent'});
writetable(normalizedSummary, fullfile(outputRoot, "normalized_scenario_summary.csv"));

fig = figure('Visible', 'off', 'Color', 'white', 'Position', [40 40 1800 1100]);
layout = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

ax1 = nexttile(layout);
bars = bar(ax1, 1:height(primary), primary.infection_rate_percent, 0.65, 'FaceColor', 'flat');
bars.CData = colors;
setAxes(ax1, shortNames); ylabel(ax1, 'Final infected (%)'); ylim(ax1, [0 100]);
title(ax1, 'Primary Run: Infection Severity', 'Color', 'black');
addLabels(ax1, primary.infection_rate_percent, '%.1f%%');

ax2 = nexttile(layout);
bars = bar(ax2, 1:height(primary), primary.escape_rate_percent, 0.65, 'FaceColor', 'flat');
bars.CData = colors;
setAxes(ax2, shortNames); ylabel(ax2, 'Escaped (%)');
ylim(ax2, [0 max(primary.escape_rate_percent) * 1.35]);
title(ax2, 'Primary Run: Escape Throughput', 'Color', 'black');
addLabels(ax2, primary.escape_rate_percent, '%.2f%%');

ax3 = nexttile(layout); hold(ax3, 'on');
folders = ["second_floor_outbreak" "eighth_floor_outbreak" "sixteenth_floor_outbreak"];
for index = 1:numel(folders)
    series = readtable(fullfile(resultRoot, folders(index), "population_timeseries.csv"));
    plot(ax3, series.time_hours, 100 * series.infected / primary.initial_total(index), ...
        'LineWidth', 2.2, 'Color', colors(index, :));
end
set(ax3, 'Color', 'white', 'XColor', 'black', 'YColor', 'black');
xlabel(ax3, 'Simulated hour'); ylabel(ax3, 'Infected population (%)');
xlim(ax3, [0 24]); ylim(ax3, [0 100]); grid(ax3, 'on');
legend(ax3, shortNames, 'Location', 'northwest', 'TextColor', 'black', 'Color', 'white');
title(ax3, 'Primary Run: Infection Progression', 'Color', 'black');

ax4 = nexttile(layout); hold(ax4, 'on');
for index = 1:height(primary)
    errorbar(ax4, index, meanInfectionRate(index), stdInfectionRate(index), 'o', ...
        'Color', colors(index, :), 'MarkerFaceColor', colors(index, :), ...
        'LineWidth', 2.2, 'MarkerSize', 9, 'CapSize', 14);
end
setAxes(ax4, shortNames); ylabel(ax4, 'Final infected (%)'); ylim(ax4, [0 100]);
title(ax4, 'Three Seeds: Mean Infection Rate +/- SD', 'Color', 'black');
for index = 1:height(primary)
    text(ax4, index, min(97, meanInfectionRate(index) + stdInfectionRate(index) + 4), ...
        sprintf('%.1f +/- %.1f%%', meanInfectionRate(index), stdInfectionRate(index)), ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', 'black');
end

title(layout, 'Outbreak Origin Comparison: 24-Hour FEU Tech Simulation', ...
    'FontSize', 18, 'FontWeight', 'bold', 'Color', 'black');
exportgraphics(fig, fullfile(outputRoot, "outbreak_origin_conclusive_dashboard.png"), ...
    'Resolution', 180);
close(fig);

function setAxes(ax, labels)
set(ax, 'Color', 'white', 'XColor', 'black', 'YColor', 'black', ...
    'XTick', 1:numel(labels), 'XTickLabel', labels);
grid(ax, 'on');
end

function addLabels(ax, values, formatText)
for index = 1:numel(values)
    text(ax, index, values(index) + max(values) * 0.04, sprintf(formatText, values(index)), ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', 'black');
end
end
