%CREATESAMPLEANIMATION Generate a short all-floor outbreak animation sample.

projectRoot = string(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, "config"));
addpath(fullfile(projectRoot, "src"));

cfg = defaultConfig();
cfg.DurationHours = 6;
cfg.NumSteps = cfg.DurationHours * 60 / cfg.TimeStepMinutes;
cfg.RecordAgentHistory = true;

data = outbreak.loadProjectData(projectRoot);
outbreak.validateInputs(cfg, data);
building = outbreak.buildBuildingModel(cfg, data);
roomDraws = outbreak.generateRoomOccupancy(cfg, data);
scenario = data.scenarios(data.scenarios.scenario_name == "Eighth-Floor Outbreak", :);
result = outbreak.runGridScenario(cfg, data, building, roomDraws, scenario);

outputDirectory = fullfile(projectRoot, "output", "animation");
if ~isfolder(outputDirectory), mkdir(outputDirectory); end
outputPath = fullfile(outputDirectory, "sample_eighth_floor_outbreak.mp4");

writer = VideoWriter(outputPath, "MPEG-4");
writer.FrameRate = 4;
writer.Quality = 90;
open(writer);
cleanupWriter = onCleanup(@() close(writer));

fig = figure('Visible', 'off', 'Color', 'white', 'Position', [50 50 1600 900]);
cleanupFigure = onCleanup(@() closeFigureIfValid(fig));
layout = tiledlayout(fig, 3, 5, 'TileSpacing', 'compact', 'Padding', 'compact');
axesHandles = gobjects(cfg.NumFloors, 1);
nonInfectedPlots = gobjects(cfg.NumFloors, 1);
infectedPlots = gobjects(cfg.NumFloors, 1);
escapedPlots = gobjects(cfg.NumFloors, 1);

mapColors = [0.08 0.10 0.12; 0.97 0.97 0.97; 0.88 0.84 0.73; ...
    0.55 0.55 0.55; 0.43 0.66 0.82; 1.00 0.62 0.05; ...
    0.84 0.75 0.57; 0.75 0.75 0.75; 0.34 0.72 0.45];
colormap(fig, mapColors);

for floorIndex = 1:cfg.NumFloors
    ax = nexttile(layout, floorIndex);
    axesHandles(floorIndex) = ax;
    imagesc(ax, double(building.floors(floorIndex).grid) + 1);
    clim(ax, [1 9]);
    hold(ax, 'on');
    nonInfectedPlots(floorIndex) = scatter(ax, nan, nan, 7, [0.12 0.45 0.90], 'filled');
    infectedPlots(floorIndex) = scatter(ax, nan, nan, 12, [0.88 0.10 0.12], 'filled');
    escapedPlots(floorIndex) = scatter(ax, nan, nan, 9, [0.10 0.65 0.25], 'filled');
    axis(ax, 'image');
    xlim(ax, [0.5 cfg.GridColumns + 0.5]);
    ylim(ax, [0.5 cfg.GridRows + 0.5]);
    set(ax, 'YDir', 'reverse', 'XTick', [], 'YTick', [], 'Box', 'on');
    title(ax, building.floors(floorIndex).floorLabel, 'FontSize', 8, 'Color', 'black');
end

temporaryFrame = fullfile(outputDirectory, "sample_animation_frame.png");
cleanupFrame = onCleanup(@() deleteIfPresent(temporaryFrame));
frameCount = cfg.NumSteps + 1;
for frameIndex = 1:frameCount
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
        updateScatter(escapedPlots(floorIndex), columns, rows, ...
            onFloor & statuses == cfg.Status.Escaped);
    end
    simulatedHour = (frameIndex - 1) * cfg.TimeStepMinutes / 60;
    riskIncrease = max(0, simulatedHour - 1 - cfg.EntrapmentRiskDelayHours) * ...
        cfg.EntrapmentBiteProbabilityIncreasePerHour;
    title(layout, sprintf(['Eighth-Floor Outbreak Sample | Time %.1f h | ' ...
        'Non-Infected %d | Infected %d | Escaped %d | Entrapment Bonus +%.0f pp'], ...
        simulatedHour, sum(statuses == cfg.Status.NonInfected), ...
        sum(statuses == cfg.Status.Infected), sum(statuses == cfg.Status.Escaped), ...
        100 * riskIncrease), 'FontWeight', 'bold', 'FontSize', 13, 'Color', 'black');
    exportgraphics(fig, temporaryFrame, 'Resolution', 110);
    writeVideo(writer, imread(temporaryFrame));
end

clear cleanupWriter;
fprintf('Sample animation written to %s\n', outputPath);

function updateScatter(plotHandle, columns, rows, selected)
set(plotHandle, 'XData', double(columns(selected)), 'YData', double(rows(selected)));
end

function deleteIfPresent(path)
if isfile(path), delete(path); end
end

function closeFigureIfValid(fig)
if isgraphics(fig), close(fig); end
end
