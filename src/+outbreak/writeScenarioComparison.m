function writeScenarioComparison(summary, outputRoot)
%WRITESCENARIOCOMPARISON Export a split-scale cross-scenario chart.

scenarioLabels = string(summary.scenario);
fig = figure('Visible', 'off', 'Color', 'white', 'Position', [100 100 1400 650]);
layout = tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

ax1 = nexttile;
bar(ax1, 1:height(summary), summary.non_infected, 0.65, 'FaceColor', [0.20 0.55 0.85]);
set(ax1, 'Color', 'white', 'XColor', 'black', 'YColor', 'black');
xticks(ax1, 1:height(summary));
xticklabels(ax1, scenarioLabels);
xtickangle(ax1, 20);
ylabel(ax1, 'Non-Infected agents', 'Color', 'black');
title(ax1, 'Non-Infected at 24 Hours', 'Color', 'black');
grid(ax1, 'on');

ax2 = nexttile;
bar(ax2, 1:height(summary), [summary.infected summary.escaped], 'grouped');
set(ax2, 'Color', 'white', 'XColor', 'black', 'YColor', 'black');
xticks(ax2, 1:height(summary));
xticklabels(ax2, scenarioLabels);
xtickangle(ax2, 20);
ylabel(ax2, 'Agents', 'Color', 'black');
title(ax2, 'Infected and Escaped at 24 Hours', 'Color', 'black');
legend(ax2, 'Infected', 'Escaped', 'Location', 'best');
grid(ax2, 'on');

title(layout, 'Scenario Outcome Comparison', 'FontSize', 15, 'Color', 'black');
exportgraphics(fig, fullfile(outputRoot, "scenario_outcome_comparison.png"), 'Resolution', 180);
close(fig);
end
