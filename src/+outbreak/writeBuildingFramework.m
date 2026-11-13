function writeBuildingFramework(cfg, building, agents, projectRoot)
%WRITEBUILDINGFRAMEWORK Save framework assets and a selected-floor preview.

gridDirectory = fullfile(projectRoot, "data", "grids");
frameworkDirectory = fullfile(projectRoot, "results", "framework");
if ~isfolder(gridDirectory)
    mkdir(gridDirectory);
end
if ~isfolder(frameworkDirectory)
    mkdir(frameworkDirectory);
end

for floorNumber = 1:numel(building.floors)
    grid = building.floors(floorNumber).grid;
    metadata = rmfield(building.floors(floorNumber), 'grid');
    save(fullfile(gridDirectory, sprintf('floor_%02d.mat', floorNumber)), 'grid', 'metadata');
end

save(fullfile(frameworkDirectory, "building_model.mat"), 'building', '-v7.3');
writetable(agents, fullfile(frameworkDirectory, "initial_agents.csv"));

selectedFloors = [1 2 8 13 16];
fig = figure('Visible', 'off', 'Color', 'white', 'Position', [100 100 1400 700]);
layout = tiledlayout(2, 3, 'Padding', 'compact', 'TileSpacing', 'compact');
for index = 1:numel(selectedFloors)
    floorNumber = selectedFloors(index);
    nexttile;
    imagesc(building.floors(floorNumber).grid);
    axis image off;
    if building.floors(floorNumber).gridSource == "Plan-derived schematic"
        sourceLabel = "Plan-derived";
    else
        sourceLabel = "Placeholder";
    end
    title(building.floors(floorNumber).floorLabel + " - " + sourceLabel, 'FontSize', 10);
    clim([double(cfg.Cell.Wall) double(cfg.Cell.Special)]);
end
title(layout, 'Mixed Grid Framework - Plan-Derived Schematics and Placeholders', 'FontSize', 14);
colormap(fig, [0.10 0.10 0.10; 0.90 0.90 0.90; 0.65 0.80 1.00; ...
    1.00 0.65 0.20; 0.65 0.35 0.85; 0.20 0.75 0.30; 0.95 0.85 0.25]);
exportgraphics(fig, fullfile(frameworkDirectory, "grid_framework_preview.png"), 'Resolution', 160);
close(fig);
end

