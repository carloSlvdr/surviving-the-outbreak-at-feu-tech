%RUNGRIDPROJECT Execute all scenarios with the spatial grid framework.

projectRoot = string(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, "config"));
addpath(fullfile(projectRoot, "src"));

cfg = defaultConfig();
data = outbreak.loadProjectData(projectRoot);
outbreak.validateInputs(cfg, data);
building = outbreak.buildBuildingModel(cfg, data);
outbreak.validateBuildingModel(cfg, building);

outputRoot = fullfile(projectRoot, "results", "grid_scenarios");
if ~isfolder(outputRoot)
    mkdir(outputRoot);
end

summaries = cell(height(data.scenarios), 1);
for scenarioIndex = 1:height(data.scenarios)
    result = outbreak.runGridScenario(cfg, data, building, data.scenarios(scenarioIndex, :));
    outbreak.writeScenarioOutputs(result, outputRoot);
    safeName = lower(regexprep(result.scenarioName, "[^A-Za-z0-9]+", "_"));
    writetable(result.finalAgents, fullfile(outputRoot, safeName, "final_agents.csv"));
    summaries{scenarioIndex} = result.summary;
end

scenarioSummary = vertcat(summaries{:});
writetable(scenarioSummary, fullfile(outputRoot, "scenario_comparison.csv"));
disp(scenarioSummary);
fprintf('Grid scenario results written to %s\n', outputRoot);

