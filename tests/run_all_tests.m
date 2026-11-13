%RUN_ALL_TESTS Validate fixed requirements and model invariants.

projectRoot = string(fileparts(fileparts(mfilename('fullpath'))));
addpath(fullfile(projectRoot, "config"));
addpath(fullfile(projectRoot, "src"));

cfg = defaultConfig();
data = outbreak.loadProjectData(projectRoot);
outbreak.validateInputs(cfg, data);

building = outbreak.buildBuildingModel(cfg, data);
buildingReport = outbreak.validateBuildingModel(cfg, building);
assert(all(buildingReport.framework_validation == "passed"));
gridSources = string({building.floors.gridSource});
assert(sum(gridSources == "Plan-derived schematic") == 6);
assert(sum(gridSources == "Placeholder generated framework") == 10);

gridAgents = outbreak.initializeGridAgents(cfg, building, data.occupancy);
assert(height(gridAgents) == cfg.NumAgents);
assert(numel(unique(gridAgents.agent_id)) == cfg.NumAgents);
for agentIndex = 1:height(gridAgents)
    floorGrid = building.floors(gridAgents.floor_index(agentIndex)).grid;
    cellCode = floorGrid(gridAgents.grid_row(agentIndex), gridAgents.grid_column(agentIndex));
    assert(ismember(cellCode, cfg.TraversableCellCodes));
end

rng(cfg.RandomSeed, "twister");
agents = outbreak.initializeAgents(cfg, data.occupancy);
assert(height(agents) == 4000);
assert(sum(agents.status == cfg.Status.Infected) == 1);
assert(sum(agents.status == cfg.Status.NonInfected) == 3999);
assert(sum(agents.status == cfg.Status.Escaped) == 0);

for scenarioIndex = 1:height(data.scenarios)
    firstRun = outbreak.runScenario(cfg, data, data.scenarios(scenarioIndex, :));
    secondRun = outbreak.runScenario(cfg, data, data.scenarios(scenarioIndex, :));
    totals = firstRun.timeSeries.infected + firstRun.timeSeries.non_infected + firstRun.timeSeries.escaped;
    assert(all(totals == cfg.NumAgents));
    assert(all(ismember(firstRun.finalAgents.status, uint8([1 2 3]))));
    active = firstRun.finalAgents.status ~= cfg.Status.Escaped;
    assert(all(firstRun.finalAgents.floor_index(active) >= 1 & firstRun.finalAgents.floor_index(active) <= 16));
    assert(isequal(firstRun.timeSeries, secondRun.timeSeries), "Seed reproducibility failed.");
end

shortCfg = cfg;
shortCfg.NumSteps = 12;
gridRun = outbreak.runGridScenario(shortCfg, data, building, data.scenarios(2, :));
gridTotals = gridRun.timeSeries.infected + gridRun.timeSeries.non_infected + gridRun.timeSeries.escaped;
assert(all(gridTotals == cfg.NumAgents));
gridActive = gridRun.finalAgents.status ~= cfg.Status.Escaped;
assert(all(gridRun.finalAgents.floor_index(gridActive) >= 1 & gridRun.finalAgents.floor_index(gridActive) <= 16));

fprintf('All initial model tests passed.\n');

