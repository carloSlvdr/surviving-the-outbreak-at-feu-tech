%RUNREPLICATIONS Execute three recorded seeds for uncertainty-aware comparison.
projectRoot = string(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, "config")); addpath(fullfile(projectRoot, "src"));
baseCfg = defaultConfig(); data = outbreak.loadProjectData(projectRoot);
outbreak.validateInputs(baseCfg, data);
seeds = [20261116 20261117 20261118];
rows = cell(numel(seeds) * height(data.scenarios), 1); nextRow = 1;
for seed = seeds
    cfg = baseCfg; cfg.RandomSeed = seed;
    building = outbreak.buildBuildingModel(cfg, data);
    roomDraws = outbreak.generateRoomOccupancy(cfg, data);
    for scenarioIndex = 1:height(data.scenarios)
        result = outbreak.runGridScenario(cfg, data, building, roomDraws, data.scenarios(scenarioIndex, :));
        row = result.summary;
        row.random_seed = seed;
        rows{nextRow} = row; nextRow = nextRow + 1;
    end
end
replications = vertcat(rows{:});
replications = movevars(replications, 'random_seed', 'Before', 'scenario');
outputRoot = fullfile(projectRoot, "results", "outbreak_origin_scenarios");
writetable(replications, fullfile(outputRoot, "replicated_scenario_outcomes.csv"));

scenarioNames = unique(replications.scenario, 'stable');
meanInfected = zeros(numel(scenarioNames), 1); stdInfected = meanInfected;
meanEscaped = meanInfected; stdEscaped = meanInfected; meanRate = meanInfected; stdRate = meanInfected;
for index = 1:numel(scenarioNames)
    selected = replications.scenario == scenarioNames(index);
    meanInfected(index) = mean(replications.infected(selected)); stdInfected(index) = std(replications.infected(selected));
    meanEscaped(index) = mean(replications.escaped(selected)); stdEscaped(index) = std(replications.escaped(selected));
    meanRate(index) = mean(replications.escape_rate_percent(selected)); stdRate(index) = std(replications.escape_rate_percent(selected));
end
summary = table(scenarioNames, repmat(numel(seeds), numel(scenarioNames), 1), meanInfected, stdInfected, ...
    meanEscaped, stdEscaped, meanRate, stdRate, ...
    'VariableNames', {'scenario', 'replicates', 'mean_infected', 'std_infected', ...
    'mean_escaped', 'std_escaped', 'mean_escape_rate_percent', 'std_escape_rate_percent'});
writetable(summary, fullfile(outputRoot, "replicated_scenario_summary.csv"));

fig = figure('Visible', 'off', 'Color', 'white', 'Position', [100 100 1300 600]);
layout = tiledlayout(1, 2, 'Padding', 'compact');
ax1 = nexttile; errorbar(ax1, 1:numel(scenarioNames), meanInfected, stdInfected, 'o-', 'LineWidth', 1.8);
set(ax1, 'Color', 'white', 'XColor', 'black', 'YColor', 'black'); xticks(ax1, 1:numel(scenarioNames)); xticklabels(ax1, scenarioNames); xtickangle(ax1, 20); ylabel(ax1, 'Final infected'); title(ax1, 'Infections: mean +/- SD'); grid(ax1, 'on');
ax2 = nexttile; errorbar(ax2, 1:numel(scenarioNames), meanEscaped, stdEscaped, 'o-', 'LineWidth', 1.8);
set(ax2, 'Color', 'white', 'XColor', 'black', 'YColor', 'black'); xticks(ax2, 1:numel(scenarioNames)); xticklabels(ax2, scenarioNames); xtickangle(ax2, 20); ylabel(ax2, 'Final escaped'); title(ax2, 'Escapes: mean +/- SD'); grid(ax2, 'on');
title(layout, 'Three-Seed Scenario Comparison', 'Color', 'black');
exportgraphics(fig, fullfile(outputRoot, "replicated_scenario_comparison.png"), 'Resolution', 180); close(fig);
disp(summary);
