%BUILDMODELFRAMEWORK Build and validate the initial 16-floor grid framework.

projectRoot = string(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, "config"));
addpath(fullfile(projectRoot, "src"));

cfg = defaultConfig();
data = outbreak.loadProjectData(projectRoot);
outbreak.validateInputs(cfg, data);

building = outbreak.buildBuildingModel(cfg, data);
validationReport = outbreak.validateBuildingModel(cfg, building);
agents = outbreak.initializeGridAgents(cfg, building, data.occupancy);

assert(height(agents) == cfg.NumAgents, "Grid initialization must place all agents.");
assert(sum(agents.status == cfg.Status.Infected) == cfg.InitialInfectedCount);
assert(sum(agents.status == cfg.Status.NonInfected) == cfg.NumAgents - cfg.InitialInfectedCount);

outbreak.writeBuildingFramework(cfg, building, agents, projectRoot);
writetable(validationReport, fullfile(projectRoot, "results", "framework", "building_validation.csv"));

fprintf('Built and validated a %d-floor grid framework with %d agents.\n', ...
    numel(building.floors), height(agents));
fprintf('Six plan-derived schematics and ten placeholder grids are in %s\n', ...
    fullfile(projectRoot, "data", "grids"));

