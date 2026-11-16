%RUNGRIDPROJECT Build, validate, and run the authoritative fifteen-floor model.

projectRoot = string(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, "config"));
addpath(fullfile(projectRoot, "src"));

cfg = defaultConfig();
data = outbreak.loadProjectData(projectRoot);
outbreak.validateInputs(cfg, data);
building = outbreak.buildBuildingModel(cfg, data);
validationReport = outbreak.validateBuildingModel(cfg, building, data);
roomDraws = outbreak.generateRoomOccupancy(cfg, data);

outputRoot = fullfile(projectRoot, "results", "authoritative_scenarios");
if ~isfolder(outputRoot), mkdir(outputRoot); end
writetable(roomDraws, fullfile(outputRoot, "room_occupancy_draws.csv"));
writetable(validationReport, fullfile(outputRoot, "building_validation.csv"));

summaries = cell(height(data.scenarios), 1);
for scenarioIndex = 1:height(data.scenarios)
    result = outbreak.runGridScenario(cfg, data, building, roomDraws, data.scenarios(scenarioIndex, :));
    outbreak.writeScenarioOutputs(result, outputRoot);
    outbreak.writeGridScenarioOutputs(result, building, outputRoot);
    safeName = lower(regexprep(result.scenarioName, "[^A-Za-z0-9]+", "_"));
    writetable(result.finalAgents, fullfile(outputRoot, safeName, "final_agents.csv"));
    summaries{scenarioIndex} = result.summary;
end

scenarioSummary = vertcat(summaries{:});
writetable(scenarioSummary, fullfile(outputRoot, "scenario_comparison.csv"));
outbreak.writeScenarioComparison(scenarioSummary, outputRoot);
disp(scenarioSummary);
fprintf('Authoritative 15-floor results written to %s\n', outputRoot);
