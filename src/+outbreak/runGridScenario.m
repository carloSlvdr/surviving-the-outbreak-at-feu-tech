function result = runGridScenario(cfg, data, building, scenarioRow)
%RUNGRIDSCENARIO Execute spatial movement, infection, and evacuation.

rng(cfg.RandomSeed, "twister");
agents = outbreak.initializeGridAgents(cfg, building, data.occupancy);
scenarioName = string(scenarioRow.scenario_name(1));
organizedEvacuation = logical(scenarioRow.organized_evacuation(1));
evacuationStartHour = scenarioRow.evacuation_start_hour(1);

distanceToStairs = cell(16, 1);
for floorIndex = 1:16
    floorGrid = building.floors(floorIndex).grid;
    distanceToStairs{floorIndex} = outbreak.computeDistanceMap( ...
        floorGrid, floorGrid == cfg.Cell.Stair, cfg.TraversableCellCodes);
end
groundGrid = building.floors(1).grid;
distanceToExit = outbreak.computeDistanceMap( ...
    groundGrid, groundGrid == cfg.Cell.Exit, cfg.TraversableCellCodes);

timeHours = (0:cfg.NumSteps)' * cfg.TimeStepMinutes / 60;
infected = zeros(cfg.NumSteps + 1, 1);
nonInfected = zeros(cfg.NumSteps + 1, 1);
escaped = zeros(cfg.NumSteps + 1, 1);
[infected(1), nonInfected(1), escaped(1)] = countStates(agents, cfg);

for step = 1:cfg.NumSteps
    currentHour = (step - 1) * cfg.TimeStepMinutes / 60;
    evacuationActive = organizedEvacuation && currentHour >= evacuationStartHour;
    agents = moveAgents(agents, building, cfg, evacuationActive, distanceToStairs, distanceToExit);
    agents = infectAdjacentAgents(agents, cfg, building);
    if evacuationActive
        agents = processGroundExit(agents, cfg, building, data.exits);
    end
    [infected(step + 1), nonInfected(step + 1), escaped(step + 1)] = countStates(agents, cfg);
    assert(infected(step + 1) + nonInfected(step + 1) + escaped(step + 1) == cfg.NumAgents, ...
        "Population conservation failed at grid step %d.", step);
end

result.scenarioName = scenarioName;
result.timeSeries = table(timeHours, infected, nonInfected, escaped, ...
    'VariableNames', {'time_hours', 'infected', 'non_infected', 'escaped'});
result.finalAgents = agents;
result.summary = table(scenarioName, infected(end), nonInfected(end), escaped(end), ...
    100 * escaped(end) / cfg.NumAgents, ...
    'VariableNames', {'scenario', 'infected', 'non_infected', 'escaped', 'escape_rate_percent'});
end

function agents = moveAgents(agents, building, cfg, evacuationActive, distanceToStairs, distanceToExit)
occupied = false(cfg.GridRows, cfg.GridColumns, 16);
activeRows = find(agents.status ~= cfg.Status.Escaped);
for rowIndex = activeRows'
    occupied(agents.grid_row(rowIndex), agents.grid_column(rowIndex), agents.floor_index(rowIndex)) = true;
end

moveOrder = activeRows(randperm(numel(activeRows)));
directions = int16([-1 0; 1 0; 0 -1; 0 1]);
for agentIndex = moveOrder'
    floorIndex = double(agents.floor_index(agentIndex));
    row = double(agents.grid_row(agentIndex));
    column = double(agents.grid_column(agentIndex));
    currentGrid = building.floors(floorIndex).grid;

    isEvacuating = evacuationActive && agents.status(agentIndex) == cfg.Status.NonInfected;
    if isEvacuating && rand < cfg.EvacuationMovementProbability
        if floorIndex > 1 && currentGrid(row, column) == cfg.Cell.Stair
            if ismember(building.floors(floorIndex - 1).grid(row, column), cfg.TraversableCellCodes) ...
                    && ~occupied(row, column, floorIndex - 1)
                occupied(row, column, floorIndex) = false;
                agents.floor_index(agentIndex) = uint8(floorIndex - 1);
                occupied(row, column, floorIndex - 1) = true;
            end
            continue
        end
        if floorIndex == 1
            distanceMap = distanceToExit;
        else
            distanceMap = distanceToStairs{floorIndex};
        end
        [newRow, newColumn] = bestNeighbor(row, column, currentGrid, occupied(:, :, floorIndex), ...
            distanceMap, cfg.TraversableCellCodes, directions, true);
    elseif rand < cfg.NormalMovementProbability
        [newRow, newColumn] = bestNeighbor(row, column, currentGrid, occupied(:, :, floorIndex), ...
            [], cfg.TraversableCellCodes, directions, false);
    else
        continue
    end

    if newRow ~= row || newColumn ~= column
        occupied(row, column, floorIndex) = false;
        agents.grid_row(agentIndex) = uint16(newRow);
        agents.grid_column(agentIndex) = uint16(newColumn);
        occupied(newRow, newColumn, floorIndex) = true;
    end
end
end

function [newRow, newColumn] = bestNeighbor(row, column, grid, occupied, distanceMap, traversableCodes, directions, guided)
candidates = zeros(4, 2);
candidateCount = 0;
for directionIndex = 1:4
    neighbor = int16([row column]) + directions(directionIndex, :);
    candidateRow = double(neighbor(1));
    candidateColumn = double(neighbor(2));
    if candidateRow >= 1 && candidateRow <= size(grid, 1) && candidateColumn >= 1 && candidateColumn <= size(grid, 2) ...
            && ismember(grid(candidateRow, candidateColumn), traversableCodes) ...
            && ~occupied(candidateRow, candidateColumn)
        candidateCount = candidateCount + 1;
        candidates(candidateCount, :) = [candidateRow candidateColumn];
    end
end

newRow = row;
newColumn = column;
if candidateCount == 0
    return
end
candidates = candidates(1:candidateCount, :);
if guided
    indices = sub2ind(size(distanceMap), candidates(:, 1), candidates(:, 2));
    candidateDistances = distanceMap(indices);
    bestDistance = min(candidateDistances);
    bestRows = find(candidateDistances == bestDistance);
    selected = bestRows(randi(numel(bestRows)));
else
    selected = randi(candidateCount);
end
newRow = candidates(selected, 1);
newColumn = candidates(selected, 2);
end

function agents = infectAdjacentAgents(agents, cfg, building)
infectedMaps = false(cfg.GridRows, cfg.GridColumns, 16);
infectedRows = find(agents.status == cfg.Status.Infected);
for agentIndex = infectedRows'
    infectedMaps(agents.grid_row(agentIndex), agents.grid_column(agentIndex), agents.floor_index(agentIndex)) = true;
end

susceptibleRows = find(agents.status == cfg.Status.NonInfected);
newlyInfected = false(height(agents), 1);
directions = int16([-1 0; 1 0; 0 -1; 0 1]);
for agentIndex = susceptibleRows'
    floorIndex = double(agents.floor_index(agentIndex));
    row = double(agents.grid_row(agentIndex));
    column = double(agents.grid_column(agentIndex));
    adjacentInfected = 0;
    for directionIndex = 1:4
        neighbor = int16([row column]) + directions(directionIndex, :);
        if neighbor(1) >= 1 && neighbor(1) <= size(building.floors(floorIndex).grid, 1) ...
                && neighbor(2) >= 1 && neighbor(2) <= size(building.floors(floorIndex).grid, 2)
            adjacentInfected = adjacentInfected + infectedMaps(neighbor(1), neighbor(2), floorIndex);
        end
    end
    probability = min(cfg.MaximumInfectionProbability, ...
        1 - (1 - cfg.InfectionRate) ^ adjacentInfected);
    newlyInfected(agentIndex) = adjacentInfected > 0 && rand < probability;
end
agents.status(newlyInfected) = cfg.Status.Infected;
end

function agents = processGroundExit(agents, cfg, building, exits)
exitMask = building.floors(1).grid == cfg.Cell.Exit;
[exitRows, exitColumns] = find(exitMask);
groundSusceptible = find(agents.floor_index == 1 & agents.status == cfg.Status.NonInfected);
eligible = false(numel(groundSusceptible), 1);
for index = 1:numel(groundSusceptible)
    agentIndex = groundSusceptible(index);
    distance = abs(double(agents.grid_row(agentIndex)) - exitRows) ...
        + abs(double(agents.grid_column(agentIndex)) - exitColumns);
    eligible(index) = any(distance <= 1);
end
candidates = groundSusceptible(eligible);
capacity = exits.capacity_per_step(1);
if numel(candidates) > capacity
    candidates = candidates(randperm(numel(candidates), capacity));
end
agents.status(candidates) = cfg.Status.Escaped;
agents.floor_index(candidates) = uint8(0);
agents.grid_row(candidates) = uint16(0);
agents.grid_column(candidates) = uint16(0);
end

function [infected, nonInfected, escaped] = countStates(agents, cfg)
infected = sum(agents.status == cfg.Status.Infected);
nonInfected = sum(agents.status == cfg.Status.NonInfected);
escaped = sum(agents.status == cfg.Status.Escaped);
end

