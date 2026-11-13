%RUNPROJECT Execute all three initial modeling scenarios.

projectRoot = string(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, "config"));
addpath(fullfile(projectRoot, "src"));

cfg = defaultConfig();
data = outbreak.loadProjectData(projectRoot);
outbreak.validateInputs(cfg, data);

outputRoot = fullfile(projectRoot, "results");
if ~isfolder(outputRoot)
    mkdir(outputRoot);
end

summaries = cell(height(data.scenarios), 1);
for scenarioIndex = 1:height(data.scenarios)
    result = outbreak.runScenario(cfg, data, data.scenarios(scenarioIndex, :));
    outbreak.writeScenarioOutputs(result, outputRoot);
    summaries{scenarioIndex} = result.summary;
end

scenarioSummary = vertcat(summaries{:});
writetable(scenarioSummary, fullfile(outputRoot, "scenario_comparison.csv"));
disp(scenarioSummary);
fprintf('Results written to %s\n', outputRoot);

