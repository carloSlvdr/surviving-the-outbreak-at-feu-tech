function writeGridScenarioOutputs(result, building, outputRoot)
%WRITEGRIDSCENARIOOUTPUTS Export spatial, queue, and transport diagnostics.

safeName = lower(regexprep(result.scenarioName, "[^A-Za-z0-9]+", "_"));
scenarioDir = fullfile(outputRoot, safeName);
spatialDir = fullfile(scenarioDir, "spatial");
matrixDir = fullfile(spatialDir, "matrices");
if ~isfolder(matrixDir), mkdir(matrixDir); end

S = result.spatial;
timeHours = result.timeSeries.time_hours;
save(fullfile(spatialDir, "spatial_metrics.mat"), '-struct', 'S');

numFloors = numel(building.floors);
floorIndex = repelem((1:numFloors)', numel(timeHours));
physicalFloorId = repelem(double(building.physicalFloorIds(:)), numel(timeHours));
timeColumn = repmat(timeHours, numFloors, 1);
floorTimeTable = table(floorIndex, physicalFloorId, timeColumn, ...
    reshape(S.floorPopulation, [], 1), reshape(S.stairQueue, [], 1), ...
    reshape(S.regularElevatorQueue, [], 1), reshape(S.greenElevatorQueue, [], 1), ...
    'VariableNames', {'floor_index', 'physical_floor_id', 'time_hours', 'active_agents', ...
    'stair_queue', 'regular_elevator_queue', 'green_elevator_queue'});
writetable(floorTimeTable, fullfile(spatialDir, "floor_time_metrics.csv"));

summary = table((1:numFloors)', double(building.physicalFloorIds(:)), result.spatial.floorLabels(:), ...
    mean(S.floorPopulation, 1)', max(S.floorPopulation, [], 1)', ...
    max(S.stairQueue, [], 1)', max(S.regularElevatorQueue, [], 1)', max(S.greenElevatorQueue, [], 1)', ...
    sum(S.stairTransfers, 1)', sum(S.regularElevatorTransfers, 1)', sum(S.greenElevatorTransfers, 1)', ...
    squeeze(sum(S.occupancyVisits, [1 2])), squeeze(sum(S.infectedVisits, [1 2])), ...
    'VariableNames', {'floor_index', 'physical_floor_id', 'floor_label', 'mean_active_agents', ...
    'peak_active_agents', 'peak_stair_queue', 'peak_regular_elevator_queue', ...
    'peak_green_elevator_queue', 'stair_transfers', 'regular_elevator_transfers', ...
    'green_elevator_transfers', 'cumulative_agent_cell_visits', 'cumulative_infected_cell_visits'});
writetable(summary, fullfile(spatialDir, "floor_spatial_summary.csv"));

for index = 1:numFloors
    physicalId = building.physicalFloorIds(index);
    writematrix(S.occupancyVisits(:, :, index), fullfile(matrixDir, sprintf('physical_floor_%02d_occupancy_visits.csv', physicalId)));
    writematrix(S.infectedVisits(:, :, index), fullfile(matrixDir, sprintf('physical_floor_%02d_infected_visits.csv', physicalId)));
end

writeAtlas(S.occupancyVisits, building, result.scenarioName, "Cumulative Agent Cell Visits", fullfile(spatialDir, "occupancy_heatmap_atlas.png"));
writeAtlas(S.infectedVisits, building, result.scenarioName, "Cumulative Infected Cell Visits", fullfile(spatialDir, "infected_presence_heatmap_atlas.png"));
writeFloorTimeHeatmap(S.floorPopulation, timeHours, result.spatial.floorLabels, result.scenarioName, fullfile(spatialDir, "floor_population_over_time_heatmap.png"));
writeTransportChart(S, result.spatial.floorLabels, result.scenarioName, fullfile(spatialDir, "transport_and_queue_summary.png"));
end

function writeAtlas(metric, building, scenarioName, metricLabel, outputPath)
globalMaximum = max(metric, [], 'all'); if globalMaximum == 0, globalMaximum = 1; end
fig = figure('Visible', 'off', 'Color', 'white', 'Position', [50 50 1800 1200]);
layout = tiledlayout(3, 5, 'Padding', 'compact', 'TileSpacing', 'compact');
for index = 1:numel(building.floors)
    ax = nexttile; values = double(metric(:, :, index)); values(building.floors(index).grid == 0) = NaN;
    imagesc(ax, values); axis(ax, 'image', 'off'); set(ax, 'Color', [0.35 0.35 0.35]); clim(ax, [0 double(globalMaximum)]);
    title(ax, building.floors(index).floorLabel, 'FontSize', 9, 'Color', 'black');
end
colormap(fig, hot(256)); cb = colorbar; cb.Layout.Tile = 'east'; cb.Label.String = metricLabel; cb.Color = 'black';
title(layout, scenarioName + " - " + metricLabel, 'FontSize', 15, 'Color', 'black');
exportgraphics(fig, outputPath, 'Resolution', 180); close(fig);
end

function writeFloorTimeHeatmap(population, timeHours, labels, scenarioName, outputPath)
fig = figure('Visible', 'off', 'Color', 'white', 'Position', [100 100 1400 800]);
imagesc(timeHours, 1:numel(labels), population'); axis xy; xlabel('Simulated time (hours)'); ylabel('Physical floor');
yticks(1:numel(labels)); yticklabels(labels); title(scenarioName + " - Indoor Population by Floor");
cb = colorbar; cb.Label.String = 'Active agents'; colormap(fig, parula(256));
exportgraphics(fig, outputPath, 'Resolution', 180); close(fig);
end

function writeTransportChart(S, labels, scenarioName, outputPath)
fig = figure('Visible', 'off', 'Color', 'white', 'Position', [100 100 1500 700]);
layout = tiledlayout(1, 2, 'Padding', 'compact');
ax1 = nexttile; bar(ax1, [sum(S.stairTransfers, 1)' sum(S.regularElevatorTransfers, 1)' sum(S.greenElevatorTransfers, 1)'], 'grouped');
set(ax1, 'Color', 'white', 'XColor', 'black', 'YColor', 'black');
xticks(1:numel(labels)); xticklabels(labels); xtickangle(35); ylabel('Completed transfers', 'Color', 'black');
lg1 = legend('Stairs', 'Regular elevators', 'Green elevator', 'Location', 'best', 'TextColor', 'black'); set(lg1, 'Color', 'white', 'EdgeColor', 'black'); title('Vertical Transport Throughput', 'Color', 'black'); grid on;
ax2 = nexttile; bar(ax2, [max(S.stairQueue, [], 1)' max(S.regularElevatorQueue, [], 1)' max(S.greenElevatorQueue, [], 1)'], 'grouped');
set(ax2, 'Color', 'white', 'XColor', 'black', 'YColor', 'black');
xticks(1:numel(labels)); xticklabels(labels); xtickangle(35); ylabel('Peak agents waiting/on connector', 'Color', 'black');
lg2 = legend('Stairs', 'Regular elevators', 'Green elevator', 'Location', 'best', 'TextColor', 'black'); set(lg2, 'Color', 'white', 'EdgeColor', 'black'); title('Peak Connector Queues', 'Color', 'black'); grid on;
title(layout, scenarioName + " - Transport and Queue Summary", 'Color', 'black');
set(fig, 'Color', 'white');
exportgraphics(fig, outputPath, 'Resolution', 180); close(fig);
end
