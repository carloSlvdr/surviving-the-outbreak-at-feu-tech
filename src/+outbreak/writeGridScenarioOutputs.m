function writeGridScenarioOutputs(result, building, outputRoot)
%WRITEGRIDSCENARIOOUTPUTS Export spatial heat maps and congestion outputs.

safeName = lower(regexprep(result.scenarioName, "[^A-Za-z0-9]+", "_"));
scenarioDir = fullfile(outputRoot, safeName);
spatialDir = fullfile(scenarioDir, "spatial");
matrixDir = fullfile(spatialDir, "matrices");
if ~isfolder(matrixDir)
    mkdir(matrixDir);
end

occupancyVisits = result.spatial.occupancyVisits;
infectedVisits = result.spatial.infectedVisits;
floorPopulation = result.spatial.floorPopulation;
stairDemand = result.spatial.stairDemand;
timeHours = result.timeSeries.time_hours;

save(fullfile(spatialDir, "spatial_metrics.mat"), ...
    'occupancyVisits', 'infectedVisits', 'floorPopulation', 'stairDemand', 'timeHours');

floorIndex = repelem((1:16)', numel(timeHours));
timeColumn = repmat(timeHours, 16, 1);
populationColumn = reshape(floorPopulation, [], 1);
stairColumn = reshape(stairDemand, [], 1);
floorTimeTable = table(floorIndex, timeColumn, populationColumn, stairColumn, ...
    'VariableNames', {'floor_index', 'time_hours', 'active_agents', 'agents_on_stairs'});
writetable(floorTimeTable, fullfile(spatialDir, "floor_time_metrics.csv"));

summary = table((1:16)', result.spatial.floorLabels(:), ...
    mean(floorPopulation, 1)', max(floorPopulation, [], 1)', ...
    mean(stairDemand, 1)', max(stairDemand, [], 1)', ...
    squeeze(sum(occupancyVisits, [1 2])), squeeze(sum(infectedVisits, [1 2])), ...
    'VariableNames', {'floor_index', 'floor_label', 'mean_active_agents', ...
    'peak_active_agents', 'mean_stair_demand', 'peak_stair_demand', ...
    'cumulative_agent_cell_visits', 'cumulative_infected_cell_visits'});
writetable(summary, fullfile(spatialDir, "floor_spatial_summary.csv"));

for index = 1:16
    occupancyTable = array2table(occupancyVisits(:, :, index));
    infectedTable = array2table(infectedVisits(:, :, index));
    writetable(occupancyTable, fullfile(matrixDir, sprintf('floor_%02d_occupancy_visits.csv', index)), ...
        WriteVariableNames=false);
    writetable(infectedTable, fullfile(matrixDir, sprintf('floor_%02d_infected_visits.csv', index)), ...
        WriteVariableNames=false);
end

writeAtlas(occupancyVisits, building, result.scenarioName, ...
    "Cumulative Agent Cell Visits", fullfile(spatialDir, "occupancy_heatmap_atlas.png"));
writeAtlas(infectedVisits, building, result.scenarioName, ...
    "Cumulative Infected Cell Visits", fullfile(spatialDir, "infected_presence_heatmap_atlas.png"));
writeFloorTimeHeatmap(floorPopulation, timeHours, result.spatial.floorLabels, ...
    result.scenarioName, fullfile(spatialDir, "floor_population_over_time_heatmap.png"));
writeStairTraffic(stairDemand, result.spatial.floorLabels, result.scenarioName, ...
    fullfile(spatialDir, "cumulative_stair_traffic.png"));
end

function writeAtlas(metric, building, scenarioName, metricLabel, outputPath)
occupiedFloors = 2:16;
globalMaximum = max(metric(:, :, occupiedFloors), [], 'all');
if globalMaximum == 0
    globalMaximum = 1;
end

fig = figure('Visible', 'off', 'Color', 'white', 'Position', [50 50 1800 1200]);
layout = tiledlayout(3, 5, 'Padding', 'compact', 'TileSpacing', 'compact');
for floorIndex = occupiedFloors
    ax = nexttile;
    values = double(metric(:, :, floorIndex));
    values(building.floors(floorIndex).grid == 0) = NaN;
    imagesc(ax, values);
    axis(ax, 'image', 'off');
    set(ax, 'Color', [0.38 0.38 0.38]);
    clim(ax, [0 double(globalMaximum)]);
    title(ax, building.floors(floorIndex).floorLabel, 'FontSize', 9, 'Color', 'black');
end
colormap(fig, hot(256));
cb = colorbar;
cb.Layout.Tile = 'east';
cb.Label.String = metricLabel;
cb.Color = 'black';
title(layout, scenarioName + " - " + metricLabel, 'FontSize', 15, 'Color', 'black');
exportgraphics(fig, outputPath, 'Resolution', 180);
close(fig);
end

function writeFloorTimeHeatmap(floorPopulation, timeHours, floorLabels, scenarioName, outputPath)
fig = figure('Visible', 'off', 'Color', 'white', 'Position', [100 100 1400 800]);
imagesc(timeHours, 1:16, floorPopulation');
ax = gca;
set(ax, 'Color', 'white', 'XColor', 'black', 'YColor', 'black');
axis xy;
xlabel('Simulated time (hours)', 'Color', 'black');
ylabel('Level', 'Color', 'black');
yticks(1:16);
yticklabels(floorLabels);
title(scenarioName + " - Active Agents by Floor and Time", 'Color', 'black');
cb = colorbar;
cb.Label.String = 'Active agents';
cb.Color = 'black';
colormap(fig, parula(256));
exportgraphics(fig, outputPath, 'Resolution', 180);
close(fig);
end

function writeStairTraffic(stairDemand, floorLabels, scenarioName, outputPath)
fig = figure('Visible', 'off', 'Color', 'white', 'Position', [100 100 1400 750]);
cumulativeDemand = sum(stairDemand, 1);
bar(1:16, cumulativeDemand, 0.75, 'FaceColor', [0.85 0.33 0.10]);
ax = gca;
set(ax, 'Color', 'white', 'XColor', 'black', 'YColor', 'black');
if max(cumulativeDemand) == 0
    ylim([0 1]);
end
xlabel('Level', 'Color', 'black');
ylabel('Cumulative agent-time observations on stair cells', 'Color', 'black');
xticks(1:16);
xticklabels(floorLabels);
xtickangle(35);
title(scenarioName + " - Cumulative Stair Traffic", 'Color', 'black');
grid on;
exportgraphics(fig, outputPath, 'Resolution', 180);
close(fig);
end
