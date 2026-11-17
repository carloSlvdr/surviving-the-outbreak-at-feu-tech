function cfg = defaultConfig()
%DEFAULTCONFIG Configuration for the authoritative 15-floor model.

cfg.ProjectTitle = "Surviving the Outbreak at FEU Tech: An Agent-Based Simulation of a Zombie Outbreak";
cfg.DurationHours = 24;
cfg.TimeStepMinutes = 10;
cfg.NumSteps = cfg.DurationHours * 60 / cfg.TimeStepMinutes;
cfg.RandomSeed = 20261116;
cfg.RecordAgentHistory = false;
cfg.PhysicalFloorIds = [1:12 14:16];
cfg.NumFloors = numel(cfg.PhysicalFloorIds);

cfg.Status.NonInfected = uint8(1);
cfg.Status.Infected = uint8(2);
cfg.Status.Escaped = uint8(3);
cfg.InitialInfectedCount = 1;
cfg.InitialInfectedPhysicalFloor = 8;
cfg.InitialInfectedRoomPolicy = "any_occupied_space";

cfg.GridRows = 40;
cfg.GridColumns = 60;
cfg.Cell.Wall = uint8(0);
cfg.Cell.Walkable = uint8(1);
cfg.Cell.Room = uint8(2);
cfg.Cell.Stair = uint8(3);
cfg.Cell.RegularElevator = uint8(4);
cfg.Cell.Exit = uint8(5);
cfg.Cell.Special = uint8(6);
cfg.Cell.Door = uint8(7);
cfg.Cell.GreenElevator = uint8(8);
cfg.TraversableCellCodes = uint8(1:8);

% Provisional behavior; values are simulation assumptions, not measured data.
cfg.NormalMovementProbability = 0.08;
cfg.EvacuationMovementProbability = 0.70;
% Aggressive-zombie bite and pursuit behavior.
cfg.BiteProbability = 0.12;
cfg.InfectionGivenBiteProbability = 1.00;
cfg.MaximumBiteProbability = 0.35;
cfg.InfectedMovementProbability = 0.65;
cfg.InfectedPursuitProbability = 0.75;
% Provisional entrapment-pressure assumptions. Risk grows only when an
% infected agent is adjacent; time alone never creates an infection.
cfg.EntrapmentRiskDelayHours = 4;
cfg.EntrapmentBiteProbabilityIncreasePerHour = 0.03;
cfg.EntrapmentMaximumBiteProbability = 0.75;
cfg.StairCapacityPerStep = 24;
cfg.RegularElevatorCars = 8;
cfg.RegularElevatorCapacityPerCar = 15;
cfg.RegularElevatorDispatchIntervalSteps = 2;
cfg.GreenElevatorCars = 1;
cfg.GreenElevatorCapacityPerCar = 15;
cfg.GreenElevatorDispatchIntervalSteps = 3;
cfg.Floor2ExitCapacityPerStep = 40;
cfg.GroundExitCapacityPerStep = 30;

% Green-box stops visible in the current drawings. Floor 15 is inferred.
cfg.GreenElevatorConfirmedStops = [2 3 5 6 8 9 10 11 14 16];
cfg.GreenElevatorInferredStops = 15;
end
