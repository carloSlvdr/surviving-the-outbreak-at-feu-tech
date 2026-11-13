function result = runScenario(cfg, data, scenarioRow)
%RUNSCENARIO Execute one floor-level scenario.

rng(cfg.RandomSeed, "twister");
agents = outbreak.initializeAgents(cfg, data.occupancy);

scenarioName = string(scenarioRow.scenario_name(1));
organizedEvacuation = logical(scenarioRow.organized_evacuation(1));
evacuationStartHour = scenarioRow.evacuation_start_hour(1);

timeHours = (0:cfg.NumSteps)' * cfg.TimeStepMinutes / 60;
infected = zeros(cfg.NumSteps + 1, 1);
nonInfected = zeros(cfg.NumSteps + 1, 1);
escaped = zeros(cfg.NumSteps + 1, 1);
[infected(1), nonInfected(1), escaped(1)] = countStates(agents, cfg);

for step = 1:cfg.NumSteps
    currentHour = (step - 1) * cfg.TimeStepMinutes / 60;
    evacuationActive = organizedEvacuation && currentHour >= evacuationStartHour;

    agents = moveAgents(agents, cfg, evacuationActive, height(data.floors));
    agents = infectAgents(agents, cfg, height(data.floors));
    if evacuationActive
        agents = evacuateAgents(agents, cfg);
    end

    [infected(step + 1), nonInfected(step + 1), escaped(step + 1)] = countStates(agents, cfg);
    assert(infected(step + 1) + nonInfected(step + 1) + escaped(step + 1) == cfg.NumAgents, ...
        "Population conservation failed at step %d.", step);
end

result.scenarioName = scenarioName;
result.timeSeries = table(timeHours, infected, nonInfected, escaped, ...
    'VariableNames', {'time_hours', 'infected', 'non_infected', 'escaped'});
result.finalAgents = agents;
result.summary = table(scenarioName, infected(end), nonInfected(end), escaped(end), ...
    100 * escaped(end) / cfg.NumAgents, ...
    'VariableNames', {'scenario', 'infected', 'non_infected', 'escaped', 'escape_rate_percent'});
end

function agents = moveAgents(agents, cfg, evacuationActive, numFloors)
active = agents.status ~= cfg.Status.Escaped;

if evacuationActive
    evacCandidates = find(agents.status == cfg.Status.NonInfected & agents.floor_index > 1);
    movers = evacCandidates(rand(numel(evacCandidates), 1) < cfg.EvacuationMovementProbability);
    agents.floor_index(movers) = agents.floor_index(movers) - 1;
end

normalCandidates = find(active & ~(evacuationActive & agents.status == cfg.Status.NonInfected));
movers = normalCandidates(rand(numel(normalCandidates), 1) < cfg.NormalMovementProbability);
direction = ones(numel(movers), 1, 'int8');
direction(rand(numel(movers), 1) < 0.5) = -1;
newFloor = int16(agents.floor_index(movers)) + int16(direction);
newFloor = max(1, min(numFloors, newFloor));
agents.floor_index(movers) = uint8(newFloor);
end

function agents = infectAgents(agents, cfg, numFloors)
for floorIndex = 1:numFloors
    onFloor = agents.floor_index == floorIndex & agents.status ~= cfg.Status.Escaped;
    infectedCount = sum(onFloor & agents.status == cfg.Status.Infected);
    activeCount = sum(onFloor);
    if infectedCount == 0 || activeCount == 0
        continue
    end

    susceptible = find(onFloor & agents.status == cfg.Status.NonInfected);
    probability = min(cfg.MaximumInfectionProbability, ...
        cfg.InfectionRate * infectedCount / activeCount);
    newlyInfected = susceptible(rand(numel(susceptible), 1) < probability);
    agents.status(newlyInfected) = cfg.Status.Infected;
end
end

function agents = evacuateAgents(agents, cfg)
candidates = find(agents.status == cfg.Status.NonInfected & agents.floor_index == 1);
escapedRows = candidates(rand(numel(candidates), 1) < cfg.ExitProbabilityPerStep);
agents.status(escapedRows) = cfg.Status.Escaped;
agents.floor_index(escapedRows) = uint8(0);
end

function [infected, nonInfected, escaped] = countStates(agents, cfg)
infected = sum(agents.status == cfg.Status.Infected);
nonInfected = sum(agents.status == cfg.Status.NonInfected);
escaped = sum(agents.status == cfg.Status.Escaped);
end

