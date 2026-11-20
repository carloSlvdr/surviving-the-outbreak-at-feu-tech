%REGENERATESPATIALOUTPUTS Rebuild spatial figures from saved scenario metrics.

projectRoot = string(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, "config"));
addpath(fullfile(projectRoot, "src"));

cfg = defaultConfig();
data = outbreak.loadProjectData(projectRoot);
outbreak.validateInputs(cfg, data);
building = outbreak.buildBuildingModel(cfg, data);
outbreak.validateBuildingModel(cfg, building, data);

outputRoot = fullfile(projectRoot, "results", "outbreak_origin_scenarios");
assert(isfolder(outputRoot), ...
    "Run runGridProject before regenerating spatial outputs.");

for scenarioIndex = 1:height(data.scenarios)
    scenarioName = string(data.scenarios.scenario_name(scenarioIndex));
    safeName = lower(regexprep(scenarioName, "[^A-Za-z0-9]+", "_"));
    scenarioDirectory = fullfile(outputRoot, safeName);
    timeSeriesPath = fullfile(scenarioDirectory, "population_timeseries.csv");
    metricsPath = fullfile(scenarioDirectory, "spatial", "spatial_metrics.mat");
    assert(isfile(timeSeriesPath) && isfile(metricsPath), ...
        "Missing saved outputs for scenario %s. Run runGridProject first.", scenarioName);

    result.scenarioName = scenarioName;
    result.timeSeries = readtable(timeSeriesPath, TextType="string");
    result.spatial = load(metricsPath);
    outbreak.writeGridScenarioOutputs(result, building, outputRoot);
end

fprintf('Regenerated spatial outputs for %d outbreak-origin scenarios in %s\n', ...
    height(data.scenarios), outputRoot);
