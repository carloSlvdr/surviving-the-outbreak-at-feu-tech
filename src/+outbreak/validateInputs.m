function validateInputs(cfg, data)
%VALIDATEINPUTS Enforce the revised fifteen-floor contract.
assert(height(data.floors) == 15, "Expected exactly 15 physical floors.");
assert(isequal(data.floors.floor_index(:), (1:15)'), "Internal floor indices must be 1 through 15.");
assert(isequal(data.floors.physical_floor_id(:)', cfg.PhysicalFloorIds), ...
    "Physical floors must be 1-12 and 14-16.");
assert(~any(ismember(data.floors.physical_floor_id, [13 17])), "Floors 13 and 17 are forbidden.");
assert(all(data.rooms.floor_index >= 2 & data.rooms.floor_index <= 15), ...
    "Ground Floor cannot have an initial room population.");
assert(all(data.rooms.min_occupancy <= data.rooms.max_occupancy), "Invalid occupancy range.");
assert(numel(unique(data.rooms.room_id)) == height(data.rooms), "Room IDs must be unique.");
assert(all(ismember(data.connections.from_floor_index, 2:14)) && ...
    all(data.connections.to_floor_index == data.connections.from_floor_index + 1), ...
    "Stair connections must follow the ordered physical-floor sequence.");
assert(data.floors.physical_floor_id(12) == 12 && data.floors.physical_floor_id(13) == 14, ...
    "Floors 12 and 14 must be adjacent in sequence.");
end
