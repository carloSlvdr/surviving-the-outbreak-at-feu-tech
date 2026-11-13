function validateInputs(cfg, data)
%VALIDATEINPUTS Fail early when project inputs violate fixed requirements.

assert(height(data.floors) == 16, "Expected exactly 16 floor records.");
assert(isequal(data.floors.floor_index(:), (1:16)'), "Floor indices must be 1 through 16.");
assert(sum(data.occupancy.population) == cfg.NumAgents, ...
    "Floor occupancy must total %d agents.", cfg.NumAgents);
assert(all(data.occupancy.population >= 0), "Floor populations cannot be negative.");
assert(height(data.scenarios) == 3, "Expected exactly three scenarios.");
assert(height(data.planTraceability) == 6, ...
    "Expected traceability records for the six represented physical levels.");
assert(all(ismember(["Baseline"; "Early Evacuation"; "Delayed Evacuation"], ...
    data.scenarios.scenario_name)), "Required scenario names are missing.");
assert(cfg.NumSteps == 144, "The 24-hour, 10-minute configuration must have 144 steps.");
end

