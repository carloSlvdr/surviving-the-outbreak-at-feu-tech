%RUN_ALL_TESTS Validate the authoritative fifteen-floor implementation.
projectRoot = string(fileparts(fileparts(mfilename('fullpath'))));
addpath(fullfile(projectRoot, "config")); addpath(fullfile(projectRoot, "src"));
cfg = defaultConfig(); data = outbreak.loadProjectData(projectRoot);
outbreak.validateInputs(cfg, data);
assert(isequal(cfg.PhysicalFloorIds, [1:12 14:16]));
assert(~any(ismember(cfg.PhysicalFloorIds, [13 17])));
assert(abs(outbreak.computeBiteProbability(cfg, 1) - 0.12) < 1e-12);
assert(abs(outbreak.computeBiteProbability(cfg, 2) - 0.2256) < 1e-12);
assert(abs(outbreak.computeBiteProbability(cfg, 3) - 0.318528) < 1e-12);
assert(abs(outbreak.computeBiteProbability(cfg, 4) - 0.35) < 1e-12);
assert(abs(outbreak.computeBiteProbability(cfg, 1, 4) - 0.12) < 1e-12);
assert(abs(outbreak.computeBiteProbability(cfg, 1, 5) - 0.15) < 1e-12);
assert(abs(outbreak.computeBiteProbability(cfg, 4, 30) - 0.75) < 1e-12);
assert(outbreak.computeBiteProbability(cfg, 0, 30) == 0);
assert(cfg.InfectionGivenBiteProbability == 1.0);
assert(cfg.InfectedMovementProbability == 0.65 && cfg.InfectedPursuitProbability == 0.75);

building = outbreak.buildBuildingModel(cfg, data);
report = outbreak.validateBuildingModel(cfg, building, data);
assert(all(report.framework_validation == "passed"));
floor2 = building.floors(2); floor8 = building.floors(8); floor14 = building.floors(13);
assert(nnz(floor2.roomMap) > 1500 && nnz(floor8.roomMap) > 1500);
assert(nnz(floor14.roomMap) > 900);
assert(isequal(building.floors(11).grid, building.floors(12).grid));
assert(sum(data.rooms.physical_floor_id == 12) == 14);
assert(nnz(floor2.grid == cfg.Cell.Exit) == 18);
for floorIndex = 2:cfg.NumFloors
    floorGrid = building.floors(floorIndex).grid;
    assert(nnz(floorGrid == cfg.Cell.RegularElevator) == 160);
    assert(nnz(building.floors(floorIndex).grid == cfg.Cell.GreenElevator) == 20);
    transportMask = floorGrid == cfg.Cell.RegularElevator | floorGrid == cfg.Cell.GreenElevator;
    transportMargin = conv2(double(transportMask), ones(3), 'same') > 0;
    assert(~any(floorGrid(transportMargin) == cfg.Cell.Room));
    assert(~any(floorGrid(transportMargin) == cfg.Cell.Door));
end
assert(~any(building.floors(1).grid(:) == cfg.Cell.Stair));
assert(~any(building.floors(1).grid(:) == cfg.Cell.RegularElevator));

drawsA = outbreak.generateRoomOccupancy(cfg, data);
drawsB = outbreak.generateRoomOccupancy(cfg, data);
assert(isequal(drawsA.generated_occupancy, drawsB.generated_occupancy));
assert(all(drawsA.generated_occupancy >= drawsA.min_occupancy));
assert(all(drawsA.generated_occupancy <= drawsA.max_occupancy));
agents = outbreak.initializeGridAgents(cfg, building, data, drawsA);
initialTotal = sum(drawsA.generated_occupancy);
assert(height(agents) == initialTotal && numel(unique(agents.agent_id)) == initialTotal);
assert(sum(agents.status == cfg.Status.Infected) == cfg.InitialInfectedCount);

shortCfg = cfg; shortCfg.NumSteps = 6; shortCfg.DurationHours = 1;
scenario = data.scenarios(data.scenarios.scenario_name == "Second-Floor Outbreak", :);
scenario.evacuation_start_hour = 0;
result = outbreak.runGridScenario(shortCfg, data, building, drawsA, scenario);
replayed = outbreak.runGridScenario(shortCfg, data, building, drawsA, scenario);
totals = result.timeSeries.infected + result.timeSeries.non_infected + result.timeSeries.escaped;
assert(all(totals == initialTotal));
assert(size(result.spatial.floorPopulation, 2) == 15);
assert(size(result.spatial.occupancyVisits, 3) == 15);
assert(all(result.finalAgents.status >= 1 & result.finalAgents.status <= 3));
assert(all(result.finalAgents.floor_index(result.finalAgents.status ~= cfg.Status.Escaped) >= 1));
assert(isequal(result.timeSeries, replayed.timeSeries));
assert(all(result.timeSeries.new_bite_infections >= 0));

fprintf('All authoritative model tests passed for %d generated agents.\n', initialTotal);
