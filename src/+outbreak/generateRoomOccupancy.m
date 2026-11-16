function roomDraws = generateRoomOccupancy(cfg, data)
%GENERATEROOMOCCUPANCY Draw one inclusive uniform occupancy per room.
rng(cfg.RandomSeed, "twister");
counts = zeros(height(data.rooms), 1);
for row = 1:height(data.rooms)
    counts(row) = randi([data.rooms.min_occupancy(row), data.rooms.max_occupancy(row)]);
end
roomDraws = data.rooms(:, {'floor_index', 'physical_floor_id', 'room_id', 'room_type', ...
    'min_occupancy', 'max_occupancy', 'evidence_status'});
roomDraws.generated_occupancy = counts;
roomDraws.random_seed = repmat(cfg.RandomSeed, height(roomDraws), 1);
end
