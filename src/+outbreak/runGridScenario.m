function result = runGridScenario(cfg, data, building, roomDraws, scenarioRow)
%RUNGRIDSCENARIO Execute a reproducible 24-hour spatial scenario.

rng(cfg.RandomSeed, "twister");
agents = outbreak.initializeGridAgents(cfg, building, data, roomDraws, scenarioRow);
totalAgents = height(agents);
numFloors = cfg.NumFloors;
scenarioName = string(scenarioRow.scenario_name(1));
organizedEvacuation = logical(scenarioRow.organized_evacuation(1));
evacuationStartHour = scenarioRow.evacuation_start_hour(1);

distanceMaps = cell(numFloors, 1);
for floorIndex = 1:numFloors
    grid = building.floors(floorIndex).grid;
    if floorIndex == 1 || floorIndex == 2
        target = grid == cfg.Cell.Exit;
    else
        target = grid == cfg.Cell.Stair | grid == cfg.Cell.RegularElevator | ...
            grid == cfg.Cell.GreenElevator;
    end
    distanceMaps{floorIndex} = outbreak.computeDistanceMap(grid, target, cfg.TraversableCellCodes);
end

timeHours = (0:cfg.NumSteps)' * cfg.TimeStepMinutes / 60;
infected = zeros(cfg.NumSteps + 1, 1);
nonInfected = zeros(cfg.NumSteps + 1, 1);
escaped = zeros(cfg.NumSteps + 1, 1);
indoor = zeros(cfg.NumSteps + 1, 1);
newBites = zeros(cfg.NumSteps + 1, 1);
occupancyVisits = zeros(cfg.GridRows, cfg.GridColumns, numFloors, 'uint32');
infectedVisits = zeros(cfg.GridRows, cfg.GridColumns, numFloors, 'uint32');
floorPopulation = zeros(cfg.NumSteps + 1, numFloors);
stairQueue = zeros(cfg.NumSteps + 1, numFloors);
regularElevatorQueue = zeros(cfg.NumSteps + 1, numFloors);
greenElevatorQueue = zeros(cfg.NumSteps + 1, numFloors);
stairTransfers = zeros(cfg.NumSteps, numFloors);
regularElevatorTransfers = zeros(cfg.NumSteps, numFloors);
greenElevatorTransfers = zeros(cfg.NumSteps, numFloors);
recordAgentHistory = isfield(cfg, 'RecordAgentHistory') && cfg.RecordAgentHistory;
if recordAgentHistory
    agentHistory.floorIndex = zeros(totalAgents, cfg.NumSteps + 1, 'uint8');
    agentHistory.gridRow = zeros(totalAgents, cfg.NumSteps + 1, 'uint16');
    agentHistory.gridColumn = zeros(totalAgents, cfg.NumSteps + 1, 'uint16');
    agentHistory.status = zeros(totalAgents, cfg.NumSteps + 1, 'uint8');
    agentHistory.floorIndex(:, 1) = agents.floor_index;
    agentHistory.gridRow(:, 1) = agents.grid_row;
    agentHistory.gridColumn(:, 1) = agents.grid_column;
    agentHistory.status(:, 1) = agents.status;
end

[infected(1), nonInfected(1), escaped(1)] = countStates(agents, cfg);
indoor(1) = infected(1) + nonInfected(1);
[occupancyVisits, infectedVisits, floorPopulation(1, :), stairQueue(1, :), ...
    regularElevatorQueue(1, :), greenElevatorQueue(1, :)] = ...
    recordSpatialState(agents, building, cfg, occupancyVisits, infectedVisits);

for step = 1:cfg.NumSteps
    currentHour = (step - 1) * cfg.TimeStepMinutes / 60;
    evacuationActive = organizedEvacuation && currentHour >= evacuationStartHour;
    [agents, stairTransfers(step, :), regularElevatorTransfers(step, :), ...
        greenElevatorTransfers(step, :)] = moveAgents(agents, building, cfg, ...
        evacuationActive, distanceMaps, step);
    hoursSinceEvacuation = max(0, currentHour - evacuationStartHour);
    [agents, newBites(step + 1)] = infectAdjacentAgents(agents, cfg, ...
        evacuationActive, hoursSinceEvacuation);
    if evacuationActive
        agents = processAuthorizedExits(agents, cfg, building);
    end
    [infected(step + 1), nonInfected(step + 1), escaped(step + 1)] = countStates(agents, cfg);
    indoor(step + 1) = infected(step + 1) + nonInfected(step + 1);
    assert(infected(step + 1) + nonInfected(step + 1) + escaped(step + 1) == totalAgents, ...
        "Population conservation failed at step %d.", step);
    [occupancyVisits, infectedVisits, floorPopulation(step + 1, :), stairQueue(step + 1, :), ...
        regularElevatorQueue(step + 1, :), greenElevatorQueue(step + 1, :)] = ...
        recordSpatialState(agents, building, cfg, occupancyVisits, infectedVisits);
    if recordAgentHistory
        agentHistory.floorIndex(:, step + 1) = agents.floor_index;
        agentHistory.gridRow(:, step + 1) = agents.grid_row;
        agentHistory.gridColumn(:, step + 1) = agents.grid_column;
        agentHistory.status(:, step + 1) = agents.status;
    end
end

result.scenarioName = scenarioName;
result.generatedInitialTotal = totalAgents;
result.roomDraws = roomDraws;
result.timeSeries = table(timeHours, infected, nonInfected, escaped, indoor, newBites, cumsum(newBites), ...
    'VariableNames', {'time_hours', 'infected', 'non_infected', 'escaped', 'indoor_population', ...
    'new_bite_infections', 'cumulative_bite_infections'});
result.finalAgents = agents;
result.spatial.occupancyVisits = occupancyVisits;
result.spatial.infectedVisits = infectedVisits;
result.spatial.floorPopulation = floorPopulation;
result.spatial.stairQueue = stairQueue;
result.spatial.regularElevatorQueue = regularElevatorQueue;
result.spatial.greenElevatorQueue = greenElevatorQueue;
result.spatial.stairTransfers = stairTransfers;
result.spatial.regularElevatorTransfers = regularElevatorTransfers;
result.spatial.greenElevatorTransfers = greenElevatorTransfers;
result.spatial.floorLabels = string({building.floors.floorLabel});
if recordAgentHistory
    result.agentHistory = agentHistory;
end
result.summary = table(scenarioName, totalAgents, infected(end), nonInfected(end), escaped(end), ...
    100 * escaped(end) / totalAgents, ...
    'VariableNames', {'scenario', 'initial_total', 'infected', 'non_infected', 'escaped', 'escape_rate_percent'});
end

function [agents, stairCounts, regularCounts, greenCounts] = ...
        moveAgents(agents, building, cfg, evacuationActive, distanceMaps, step)
numFloors = cfg.NumFloors;
occupied = false(cfg.GridRows, cfg.GridColumns, numFloors);
activeRows = find(agents.status ~= cfg.Status.Escaped);
for agentIndex = activeRows'
    occupied(agents.grid_row(agentIndex), agents.grid_column(agentIndex), agents.floor_index(agentIndex)) = true;
end
stairCounts = zeros(1, numFloors);
regularCounts = zeros(1, numFloors);
greenCounts = zeros(1, numFloors);
greenTotal = 0;
moveOrder = activeRows(randperm(numel(activeRows)));
directions = int16([-1 0; 1 0; 0 -1; 0 1]);
pursuitMaps = cell(numFloors, 1);
for targetFloor = 1:numFloors
    susceptible = find(agents.floor_index == targetFloor & agents.status == cfg.Status.NonInfected);
    if isempty(susceptible)
        pursuitMaps{targetFloor} = [];
        continue;
    end
    targetMask = false(cfg.GridRows, cfg.GridColumns);
    indices = sub2ind([cfg.GridRows cfg.GridColumns], ...
        double(agents.grid_row(susceptible)), double(agents.grid_column(susceptible)));
    targetMask(indices) = true;
    pursuitMaps{targetFloor} = outbreak.computeDistanceMap( ...
        building.floors(targetFloor).grid, targetMask, cfg.TraversableCellCodes);
end

for agentIndex = moveOrder'
    floorIndex = double(agents.floor_index(agentIndex));
    row = double(agents.grid_row(agentIndex));
    column = double(agents.grid_column(agentIndex));
    grid = building.floors(floorIndex).grid;
    cellCode = grid(row, column);

    if evacuationActive
        if floorIndex > 2 && cellCode == cfg.Cell.Stair && stairCounts(floorIndex) < cfg.StairCapacityPerStep
            [agents, occupied, moved] = transferSameCell(agents, occupied, agentIndex, floorIndex - 1, row, column, building, cfg);
            if moved, stairCounts(floorIndex) = stairCounts(floorIndex) + 1; end
            continue;
        elseif floorIndex > 2 && cellCode == cfg.Cell.RegularElevator ...
                && mod(step, cfg.RegularElevatorDispatchIntervalSteps) == 0 ...
                && regularCounts(floorIndex) < cfg.RegularElevatorCars * cfg.RegularElevatorCapacityPerCar
            [agents, occupied, moved] = transferSameCell(agents, occupied, agentIndex, floorIndex - 1, row, column, building, cfg);
            if moved, regularCounts(floorIndex) = regularCounts(floorIndex) + 1; end
            continue;
        elseif floorIndex > 1 && cellCode == cfg.Cell.GreenElevator ...
                && mod(step, cfg.GreenElevatorDispatchIntervalSteps) == 0 ...
                && greenTotal < cfg.GreenElevatorCars * cfg.GreenElevatorCapacityPerCar
            [targetRow, targetColumn] = firstFreeCell(building.floors(1).grid == cfg.Cell.GreenElevator, occupied(:, :, 1));
            if targetRow > 0
                occupied(row, column, floorIndex) = false;
                agents.floor_index(agentIndex) = uint8(1);
                agents.grid_row(agentIndex) = uint16(targetRow);
                agents.grid_column(agentIndex) = uint16(targetColumn);
                occupied(targetRow, targetColumn, 1) = true;
                greenCounts(floorIndex) = greenCounts(floorIndex) + 1;
                greenTotal = greenTotal + 1;
            end
            continue;
        end
    end

    if agents.status(agentIndex) == cfg.Status.Infected
        if rand >= cfg.InfectedMovementProbability
            continue;
        end
        guidedPursuit = ~isempty(pursuitMaps{floorIndex}) && rand < cfg.InfectedPursuitProbability;
        [newRow, newColumn] = bestNeighbor(row, column, grid, occupied(:, :, floorIndex), ...
            pursuitMaps{floorIndex}, cfg.TraversableCellCodes, directions, guidedPursuit);
    elseif evacuationActive && rand < cfg.EvacuationMovementProbability
        distanceMap = distanceMaps{floorIndex};
        [newRow, newColumn] = bestNeighbor(row, column, grid, occupied(:, :, floorIndex), ...
            distanceMap, cfg.TraversableCellCodes, directions, true);
    elseif rand < cfg.NormalMovementProbability
        [newRow, newColumn] = bestNeighbor(row, column, grid, occupied(:, :, floorIndex), ...
            [], cfg.TraversableCellCodes, directions, false);
    else
        continue;
    end
    if newRow ~= row || newColumn ~= column
        occupied(row, column, floorIndex) = false;
        agents.grid_row(agentIndex) = uint16(newRow);
        agents.grid_column(agentIndex) = uint16(newColumn);
        occupied(newRow, newColumn, floorIndex) = true;
    end
end
end

function [agents, occupied, moved] = transferSameCell(agents, occupied, agentIndex, targetFloor, row, column, building, cfg)
moved = false;
if ismember(building.floors(targetFloor).grid(row, column), cfg.TraversableCellCodes) ...
        && ~occupied(row, column, targetFloor)
    sourceFloor = double(agents.floor_index(agentIndex));
    occupied(row, column, sourceFloor) = false;
    agents.floor_index(agentIndex) = uint8(targetFloor);
    occupied(row, column, targetFloor) = true;
    moved = true;
end
end

function [row, column] = firstFreeCell(mask, occupied)
index = find(mask & ~occupied, 1, 'first');
if isempty(index), row = 0; column = 0; else, [row, column] = ind2sub(size(mask), index); end
end

function [newRow, newColumn] = bestNeighbor(row, column, grid, occupied, distanceMap, traversableCodes, directions, guided)
candidates = zeros(4, 2); count = 0;
for directionIndex = 1:4
    neighbor = int16([row column]) + directions(directionIndex, :);
    r = double(neighbor(1)); c = double(neighbor(2));
    if r >= 1 && r <= size(grid, 1) && c >= 1 && c <= size(grid, 2) ...
            && ismember(grid(r, c), traversableCodes) && ~occupied(r, c)
        count = count + 1; candidates(count, :) = [r c];
    end
end
newRow = row; newColumn = column;
if count == 0, return; end
candidates = candidates(1:count, :);
if guided
    values = distanceMap(sub2ind(size(distanceMap), candidates(:, 1), candidates(:, 2)));
    best = find(values == min(values)); selected = best(randi(numel(best)));
else
    selected = randi(count);
end
newRow = candidates(selected, 1); newColumn = candidates(selected, 2);
end

function [agents, successfulBites] = infectAdjacentAgents(agents, cfg, evacuationActive, hoursSinceEvacuation)
infectedMaps = false(cfg.GridRows, cfg.GridColumns, cfg.NumFloors);
infectedRows = find(agents.status == cfg.Status.Infected);
for agentIndex = infectedRows'
    infectedMaps(agents.grid_row(agentIndex), agents.grid_column(agentIndex), agents.floor_index(agentIndex)) = true;
end
susceptibleRows = find(agents.status == cfg.Status.NonInfected);
newlyInfected = false(height(agents), 1);
directions = int16([-1 0; 1 0; 0 -1; 0 1]);
for agentIndex = susceptibleRows'
    floorIndex = double(agents.floor_index(agentIndex)); row = double(agents.grid_row(agentIndex)); column = double(agents.grid_column(agentIndex));
    adjacent = 0;
    for directionIndex = 1:4
        neighbor = int16([row column]) + directions(directionIndex, :);
        if neighbor(1) >= 1 && neighbor(1) <= cfg.GridRows && neighbor(2) >= 1 && neighbor(2) <= cfg.GridColumns
            adjacent = adjacent + infectedMaps(neighbor(1), neighbor(2), floorIndex);
        end
    end
    if evacuationActive
        entrapmentHours = hoursSinceEvacuation;
    else
        entrapmentHours = 0;
    end
    biteProbability = outbreak.computeBiteProbability(cfg, adjacent, entrapmentHours);
    infectionProbability = biteProbability * cfg.InfectionGivenBiteProbability;
    newlyInfected(agentIndex) = adjacent > 0 && rand < infectionProbability;
end
agents.status(newlyInfected) = cfg.Status.Infected;
agents.infection_history(newlyInfected) = true;
successfulBites = sum(newlyInfected);
end

function agents = processAuthorizedExits(agents, cfg, building)
for floorIndex = [1 2]
    exitMask = building.floors(floorIndex).grid == cfg.Cell.Exit;
    [exitRows, exitColumns] = find(exitMask);
    candidates = find(agents.floor_index == floorIndex & agents.status ~= cfg.Status.Escaped);
    eligible = false(numel(candidates), 1);
    for k = 1:numel(candidates)
        index = candidates(k);
        distance = abs(double(agents.grid_row(index)) - exitRows) + abs(double(agents.grid_column(index)) - exitColumns);
        eligible(k) = any(distance <= 1);
    end
    candidates = candidates(eligible);
    if floorIndex == 1, capacity = cfg.GroundExitCapacityPerStep; else, capacity = cfg.Floor2ExitCapacityPerStep; end
    if numel(candidates) > capacity, candidates = candidates(randperm(numel(candidates), capacity)); end
    agents.status(candidates) = cfg.Status.Escaped;
    agents.floor_index(candidates) = uint8(0);
    agents.grid_row(candidates) = uint16(0);
    agents.grid_column(candidates) = uint16(0);
end
end

function [occupancyVisits, infectedVisits, floorPopulation, stairQueue, regularQueue, greenQueue] = ...
        recordSpatialState(agents, building, cfg, occupancyVisits, infectedVisits)
floorPopulation = zeros(1, cfg.NumFloors); stairQueue = zeros(1, cfg.NumFloors);
regularQueue = zeros(1, cfg.NumFloors); greenQueue = zeros(1, cfg.NumFloors);
activeRows = find(agents.status ~= cfg.Status.Escaped);
for agentIndex = activeRows'
    floorIndex = double(agents.floor_index(agentIndex)); row = double(agents.grid_row(agentIndex)); column = double(agents.grid_column(agentIndex));
    occupancyVisits(row, column, floorIndex) = occupancyVisits(row, column, floorIndex) + 1;
    floorPopulation(floorIndex) = floorPopulation(floorIndex) + 1;
    if agents.status(agentIndex) == cfg.Status.Infected, infectedVisits(row, column, floorIndex) = infectedVisits(row, column, floorIndex) + 1; end
    code = building.floors(floorIndex).grid(row, column);
    if code == cfg.Cell.Stair, stairQueue(floorIndex) = stairQueue(floorIndex) + 1; end
    if code == cfg.Cell.RegularElevator, regularQueue(floorIndex) = regularQueue(floorIndex) + 1; end
    if code == cfg.Cell.GreenElevator, greenQueue(floorIndex) = greenQueue(floorIndex) + 1; end
end
end

function [infected, nonInfected, escaped] = countStates(agents, cfg)
infected = sum(agents.status == cfg.Status.Infected);
nonInfected = sum(agents.status == cfg.Status.NonInfected);
escaped = sum(agents.status == cfg.Status.Escaped);
end
