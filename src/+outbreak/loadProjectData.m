function data = loadProjectData(projectRoot)
%LOADPROJECTDATA Load authoritative building, room, and scenario inputs.
arguments
    projectRoot (1,1) string
end
data.floors = readtable(fullfile(projectRoot, "data", "floor_metadata.csv"), TextType="string", Delimiter=",");
data.rooms = readtable(fullfile(projectRoot, "data", "room_inventory.csv"), TextType="string", Delimiter=",");
data.scenarios = readtable(fullfile(projectRoot, "data", "scenario_config.csv"), TextType="string", Delimiter=",");
data.connections = readtable(fullfile(projectRoot, "data", "floor_connections.csv"), TextType="string", Delimiter=",");
data.exits = readtable(fullfile(projectRoot, "data", "floor_exits.csv"), TextType="string", Delimiter=",");
end
