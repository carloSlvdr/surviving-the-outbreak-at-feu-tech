function data = loadProjectData(projectRoot)
%LOADPROJECTDATA Load input tables used by the initial model.

arguments
    projectRoot (1,1) string
end

data.floors = readtable(fullfile(projectRoot, "data", "floor_metadata.csv"), TextType="string");
data.occupancy = readtable(fullfile(projectRoot, "data", "floor_occupancy.csv"), TextType="string");
data.scenarios = readtable(fullfile(projectRoot, "data", "scenario_config.csv"), TextType="string");
data.connections = readtable(fullfile(projectRoot, "data", "floor_connections.csv"), TextType="string");
data.exits = readtable(fullfile(projectRoot, "data", "floor_exits.csv"), TextType="string");
end

