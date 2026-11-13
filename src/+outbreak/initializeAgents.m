function agents = initializeAgents(cfg, occupancy)
%INITIALIZEAGENTS Create the complete synthetic population.

floorIndex = repelem(uint8(occupancy.floor_index), occupancy.population);
floorIndex = floorIndex(:);
assert(numel(floorIndex) == cfg.NumAgents, "Occupancy does not match NumAgents.");

agents = table(uint32((1:cfg.NumAgents)'), floorIndex, ...
    repmat(cfg.Status.NonInfected, cfg.NumAgents, 1), ...
    'VariableNames', {'agent_id', 'floor_index', 'status'});

candidates = find(agents.floor_index == cfg.InitialInfectedFloorIndex);
assert(numel(candidates) >= cfg.InitialInfectedCount, ...
    "Initial infected floor has insufficient agents.");
infectedRows = candidates(randperm(numel(candidates), cfg.InitialInfectedCount));
agents.status(infectedRows) = cfg.Status.Infected;
end

