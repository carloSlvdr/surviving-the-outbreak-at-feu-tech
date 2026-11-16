%REGENERATESPATIALOUTPUTS Rebuild figures from saved authoritative metrics.
projectRoot = string(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, "config")); addpath(fullfile(projectRoot, "src"));
cfg = defaultConfig(); data = outbreak.loadProjectData(projectRoot);
building = outbreak.buildBuildingModel(cfg, data);
outputRoot = fullfile(projectRoot, "results", "authoritative_scenarios");
names = ["Baseline" "Early Evacuation" "Delayed Evacuation"];
folders = ["baseline" "early_evacuation" "delayed_evacuation"];
for index = 1:numel(names)
    scenarioDir = fullfile(outputRoot, folders(index));
    result.scenarioName = names(index);
    result.timeSeries = readtable(fullfile(scenarioDir, "population_timeseries.csv"), TextType="string");
    result.spatial = load(fullfile(scenarioDir, "spatial", "spatial_metrics.mat"));
    outbreak.writeGridScenarioOutputs(result, building, outputRoot);
end
