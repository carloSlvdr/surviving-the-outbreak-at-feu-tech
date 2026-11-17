function writeScenarioAnimation(result, building, cfg, scenarioRow, outputPath, frameStride)
%WRITESCENARIOANIMATION Render recorded agent states as an all-floor MP4.
arguments
    result struct
    building struct
    cfg struct
    scenarioRow table
    outputPath (1,1) string
    frameStride (1,1) double {mustBeInteger, mustBePositive} = 3
end
assert(isfield(result, 'agentHistory'), ...
    'Agent history must be enabled before writing an animation.');

outputDirectory = fileparts(outputPath);
if ~isfolder(outputDirectory), mkdir(outputDirectory); end

writer = VideoWriter(outputPath, 'MPEG-4');
writer.FrameRate = 4;
writer.Quality = 90;
open(writer);
cleanupWriter = onCleanup(@() closeVideoWriter(writer));

fig = figure('Visible', 'off', 'Color', 'white', 'Position', [50 50 1600 900]);
cleanupFigure = onCleanup(@() closeFigureIfValid(fig));
layout = tiledlayout(fig, 3, 5, 'TileSpacing', 'compact', 'Padding', 'compact');
nonInfectedPlots = gobjects(cfg.NumFloors, 1);
infectedPlots = gobjects(cfg.NumFloors, 1);

mapColors = [0.08 0.10 0.12; 0.97 0.97 0.97; 0.88 0.84 0.73; ...
    0.55 0.55 0.55; 0.43 0.66 0.82; 1.00 0.62 0.05; ...
    0.84 0.75 0.57; 0.75 0.75 0.75; 0.34 0.72 0.45];
colormap(fig, mapColors);

for floorIndex = 1:cfg.NumFloors
    ax = nexttile(layout, floorIndex);
    imagesc(ax, double(building.floors(floorIndex).grid) + 1);
    clim(ax, [1 9]);
    hold(ax, 'on');
    nonInfectedPlots(floorIndex) = scatter(ax, nan, nan, 7, [0.12 0.45 0.90], 'filled');
    infectedPlots(floorIndex) = scatter(ax, nan, nan, 12, [0.88 0.10 0.12], 'filled');
    axis(ax, 'image');
    xlim(ax, [0.5 cfg.GridColumns + 0.5]);
    ylim(ax, [0.5 cfg.GridRows + 0.5]);
    set(ax, 'YDir', 'reverse', 'XTick', [], 'YTick', [], 'Box', 'on');
    title(ax, building.floors(floorIndex).floorLabel, 'FontSize', 8, 'Color', 'black');
end

framePath = string(fullfile(outputDirectory, 'animation_frame.png'));
cleanupFrame = onCleanup(@() deleteIfPresent(framePath));
historyLength = size(result.agentHistory.status, 2);
frameIndices = unique([1:frameStride:historyLength historyLength]);
evacuationStartHour = scenarioRow.evacuation_start_hour(1);
for frameIndex = frameIndices
    statuses = result.agentHistory.status(:, frameIndex);
    floors = result.agentHistory.floorIndex(:, frameIndex);
    rows = result.agentHistory.gridRow(:, frameIndex);
    columns = result.agentHistory.gridColumn(:, frameIndex);
    for floorIndex = 1:cfg.NumFloors
        onFloor = floors == floorIndex;
        updateScatter(nonInfectedPlots(floorIndex), columns, rows, ...
            onFloor & statuses == cfg.Status.NonInfected);
        updateScatter(infectedPlots(floorIndex), columns, rows, ...
            onFloor & statuses == cfg.Status.Infected);
    end
    simulatedHour = (frameIndex - 1) * cfg.TimeStepMinutes / 60;
    elapsedEvacuation = max(0, simulatedHour - evacuationStartHour);
    riskIncrease = max(0, elapsedEvacuation - cfg.EntrapmentRiskDelayHours) * ...
        cfg.EntrapmentBiteProbabilityIncreasePerHour;
    riskIncrease = min(riskIncrease, cfg.EntrapmentMaximumBiteProbability);
    title(layout, sprintf(['%s | Time %.1f h | Non-Infected %d | ' ...
        'Infected %d | Escaped %d | Entrapment Bonus +%.0f pp'], ...
        result.scenarioName, simulatedHour, sum(statuses == cfg.Status.NonInfected), ...
        sum(statuses == cfg.Status.Infected), sum(statuses == cfg.Status.Escaped), ...
        100 * riskIncrease), 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'black');
    exportgraphics(fig, framePath, 'Resolution', 110);
    writeVideo(writer, imread(framePath));
end

clear cleanupWriter;
end

function updateScatter(plotHandle, columns, rows, selected)
set(plotHandle, 'XData', double(columns(selected)), 'YData', double(rows(selected)));
end

function deleteIfPresent(path)
if isfile(path), delete(path); end
end

function closeFigureIfValid(fig)
if isgraphics(fig), close(fig); end
end

function closeVideoWriter(writer)
try
    close(writer);
catch
end
end
