function agents = initializeGridAgents(cfg, building, data, roomDraws)
%INITIALIZEGRIDAGENTS Place every generated person in the assigned room.

totalAgents = sum(roomDraws.generated_occupancy);
agentId = uint32((1:totalAgents)');
floorIndex = zeros(totalAgents, 1, 'uint8');
gridRow = zeros(totalAgents, 1, 'uint16');
gridColumn = zeros(totalAgents, 1, 'uint16');
status = repmat(cfg.Status.NonInfected, totalAgents, 1);
roomId = strings(totalAgents, 1);
infectionHistory = false(totalAgents, 1);

rng(cfg.RandomSeed, "twister");
nextAgent = 1;
for roomRow = 1:height(roomDraws)
    count = roomDraws.generated_occupancy(roomRow);
    currentFloor = roomDraws.floor_index(roomRow);
    candidates = find(building.floors(currentFloor).roomMap == roomRow);
    assert(numel(candidates) >= count, ...
        "Room %s has %d cells but requires %d agents.", roomDraws.room_id(roomRow), numel(candidates), count);
    selected = candidates(randperm(numel(candidates), count));
    [rows, columns] = ind2sub([cfg.GridRows cfg.GridColumns], selected);
    target = nextAgent:(nextAgent + count - 1);
    floorIndex(target) = uint8(currentFloor);
    gridRow(target) = uint16(rows);
    gridColumn(target) = uint16(columns);
    roomId(target) = roomDraws.room_id(roomRow);
    nextAgent = nextAgent + count;
end

infectedFloorIndex = find(cfg.PhysicalFloorIds == cfg.InitialInfectedPhysicalFloor, 1);
candidates = find(floorIndex == infectedFloorIndex);
selected = candidates(randperm(numel(candidates), cfg.InitialInfectedCount));
status(selected) = cfg.Status.Infected;
infectionHistory(selected) = true;

agents = table(agentId, floorIndex, gridRow, gridColumn, status, roomId, ...
    infectionHistory, floorIndex, ...
    'VariableNames', {'agent_id', 'floor_index', 'grid_row', 'grid_column', ...
    'status', 'initial_room_id', 'infection_history', 'initial_floor_index'});
end
