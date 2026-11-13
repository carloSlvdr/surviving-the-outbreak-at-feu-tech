function cfg = defaultConfig()
%DEFAULTCONFIG Central configuration for the initial outbreak model.
% Values labeled provisional require group approval or supporting sources.

cfg.ProjectTitle = "Surviving the Outbreak at FEU Tech: An Agent-Based Simulation of a Zombie Outbreak";
cfg.NumAgents = 4000;
cfg.DurationHours = 24;
cfg.TimeStepMinutes = 10;
cfg.NumSteps = cfg.DurationHours * 60 / cfg.TimeStepMinutes;
cfg.RandomSeed = 20261113;

cfg.Status.NonInfected = uint8(1);
cfg.Status.Infected = uint8(2);
cfg.Status.Escaped = uint8(3);

cfg.InitialInfectedCount = 1;
cfg.InitialInfectedFloorIndex = 8;

% Standard dimensions for the initial grid framework. These placeholder
% dimensions can be replaced per floor after the plans are digitized.
cfg.GridRows = 40;
cfg.GridColumns = 60;

% Occupancy-grid cell codes.
cfg.Cell.Wall = uint8(0);
cfg.Cell.Walkable = uint8(1);
cfg.Cell.Room = uint8(2);
cfg.Cell.Stair = uint8(3);
cfg.Cell.Elevator = uint8(4);
cfg.Cell.Exit = uint8(5);
cfg.Cell.Special = uint8(6);
cfg.TraversableCellCodes = uint8([1 2 3 4 5 6]);

% Provisional behavioral parameters per 10-minute time step.
cfg.NormalMovementProbability = 0.08;
cfg.EvacuationMovementProbability = 0.45;
cfg.ExitProbabilityPerStep = 0.35;
cfg.InfectionRate = 0.12;
cfg.MaximumInfectionProbability = 0.25;
end

