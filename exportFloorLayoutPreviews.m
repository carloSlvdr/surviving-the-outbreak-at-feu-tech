%EXPORTFLOORLAYOUTPREVIEWS Export static model-layout images without simulation.

projectRoot = string(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, "config"));
addpath(fullfile(projectRoot, "src"));

cfg = defaultConfig();
data = outbreak.loadProjectData(projectRoot);
outbreak.validateInputs(cfg, data);
building = outbreak.buildBuildingModel(cfg, data);

outputDirectory = fullfile(projectRoot, "output", "layouts");
if ~isfolder(outputDirectory), mkdir(outputDirectory); end

mapColors = [0.08 0.10 0.12; 0.97 0.97 0.97; 0.88 0.84 0.73; ...
    0.55 0.55 0.55; 0.43 0.66 0.82; 1.00 0.62 0.05; ...
    0.84 0.75 0.57; 0.75 0.75 0.75; 0.34 0.72 0.45];
cellLabels = {'Wall', 'Walkable', 'Occupied area', 'Stairs', ...
    'Regular elevator', 'Exit', 'Special', 'Door', 'Green elevator'};

for floorIndex = 1:cfg.NumFloors
    fig = figure('Visible', 'off', 'Color', 'white', 'Position', [50 50 1300 800]);
    ax = axes(fig, 'Position', [0.06 0.10 0.76 0.80]);
    imagesc(ax, double(building.floors(floorIndex).grid) + 1);
    colormap(fig, mapColors);
    clim(ax, [1 9]);
    axis(ax, 'image');
    xlim(ax, [0.5 cfg.GridColumns + 0.5]);
    ylim(ax, [0.5 cfg.GridRows + 0.5]);
    set(ax, 'YDir', 'reverse', 'XTick', 0:5:cfg.GridColumns, ...
        'YTick', 0:5:cfg.GridRows, 'Box', 'on', 'LineWidth', 1.2, ...
        'XColor', 'black', 'YColor', 'black');
    grid(ax, 'on');
    ax.GridColor = [0.75 0.75 0.75];
    ax.GridAlpha = 0.22;
    title(ax, building.floors(floorIndex).floorLabel + " - " + ...
        building.floors(floorIndex).mainFunction, 'FontSize', 18, ...
        'FontWeight', 'bold', 'Color', 'black');
    xlabel(ax, 'Grid column'); ylabel(ax, 'Grid row');
    colorBar = colorbar(ax, 'eastoutside');
    colorBar.Ticks = 1:9;
    colorBar.TickLabels = cellLabels;
    colorBar.FontSize = 10;
    colorBar.Color = 'black';
    if building.floors(floorIndex).physicalFloorId == 2
        exitMask = building.floors(floorIndex).grid == cfg.Cell.Exit;
        [exitRows, exitColumns] = find(exitMask);
        text(ax, min(exitColumns) - 1, mean(exitRows), 'ENTRANCE / EXIT', ...
            'HorizontalAlignment', 'right', 'FontWeight', 'bold', ...
            'FontSize', 12, 'Color', [0.75 0.30 0.00], ...
            'BackgroundColor', 'white', 'Margin', 3);
    end
    fileName = sprintf('floor_%02d_layout.png', building.floors(floorIndex).physicalFloorId);
    exportgraphics(fig, fullfile(outputDirectory, fileName), 'Resolution', 160);
    close(fig);
end

fig = figure('Visible', 'off', 'Color', 'white', 'Position', [40 40 1800 1050]);
layout = tiledlayout(fig, 3, 5, 'TileSpacing', 'compact', 'Padding', 'compact');
for floorIndex = 1:cfg.NumFloors
    ax = nexttile(layout, floorIndex);
    imagesc(ax, double(building.floors(floorIndex).grid) + 1);
    clim(ax, [1 9]);
    axis(ax, 'image');
    xlim(ax, [0.5 cfg.GridColumns + 0.5]);
    ylim(ax, [0.5 cfg.GridRows + 0.5]);
    set(ax, 'YDir', 'reverse', 'XTick', [], 'YTick', [], 'Box', 'on');
    title(ax, building.floors(floorIndex).floorLabel, 'FontSize', 10, ...
        'FontWeight', 'bold', 'Color', 'black');
end
colormap(fig, mapColors);
title(layout, 'FEU Tech Static Model Layout Atlas', 'FontSize', 18, ...
    'FontWeight', 'bold', 'Color', 'black');
exportgraphics(fig, fullfile(outputDirectory, 'all_floor_layout_atlas.png'), 'Resolution', 150);
close(fig);

fprintf('Static floor layouts written to %s\n', outputDirectory);
