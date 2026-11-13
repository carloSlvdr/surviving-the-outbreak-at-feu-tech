function data = loadProjectData(projectRoot)
%LOADPROJECTDATA Load input tables used by the initial model.

arguments
    projectRoot (1,1) string
end

data.floors = readtable(fullfile(projectRoot, "data", "floor_metadata.csv"), TextType="string", Delimiter=",");
data.occupancy = readtable(fullfile(projectRoot, "data", "floor_occupancy.csv"), TextType="string", Delimiter=",");
data.scenarios = readtable(fullfile(projectRoot, "data", "scenario_config.csv"), TextType="string", Delimiter=",");
data.connections = readtable(fullfile(projectRoot, "data", "floor_connections.csv"), TextType="string", Delimiter=",");
data.exits = readtable(fullfile(projectRoot, "data", "floor_exits.csv"), TextType="string", Delimiter=",");
data.planTraceability = readtable(fullfile(projectRoot, "data", "floor_plan_traceability.csv"), TextType="string", Delimiter=",");
end

