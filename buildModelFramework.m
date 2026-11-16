%BUILDMODELFRAMEWORK Build and validate the authoritative environment.
projectRoot = string(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, "config")); addpath(fullfile(projectRoot, "src"));
cfg = defaultConfig(); data = outbreak.loadProjectData(projectRoot);
outbreak.validateInputs(cfg, data);
building = outbreak.buildBuildingModel(cfg, data);
validationReport = outbreak.validateBuildingModel(cfg, building, data);
roomDraws = outbreak.generateRoomOccupancy(cfg, data);
agents = outbreak.initializeGridAgents(cfg, building, data, roomDraws);
assert(height(agents) == sum(roomDraws.generated_occupancy));
frameworkDir = fullfile(projectRoot, "results", "authoritative_framework");
if ~isfolder(frameworkDir), mkdir(frameworkDir); end
save(fullfile(frameworkDir, "building_model.mat"), 'building', 'cfg', 'roomDraws');
writetable(validationReport, fullfile(frameworkDir, "building_validation.csv"));
writetable(roomDraws, fullfile(frameworkDir, "room_occupancy_draws.csv"));
fprintf('Validated 15 physical floors and generated %d initial agents.\n', height(agents));
