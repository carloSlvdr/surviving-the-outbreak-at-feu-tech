function distance = computeDistanceMap(grid, targetMask, traversableCodes)
%COMPUTEDISTANCEMAP Four-neighbor shortest distance to the nearest target.

traversable = ismember(grid, traversableCodes);
targetMask = logical(targetMask) & traversable;
assert(any(targetMask(:)), "At least one traversable target cell is required.");

distance = inf(size(grid));
[targetRows, targetColumns] = find(targetMask);
queue = zeros(nnz(traversable), 2, 'uint16');
tail = numel(targetRows);
queue(1:tail, :) = uint16([targetRows targetColumns]);
distance(targetMask) = 0;
head = 1;
directions = int16([-1 0; 1 0; 0 -1; 0 1]);

while head <= tail
    current = int16(queue(head, :));
    head = head + 1;
    currentDistance = distance(current(1), current(2));
    for directionIndex = 1:4
        neighbor = current + directions(directionIndex, :);
        row = neighbor(1);
        column = neighbor(2);
        if row >= 1 && row <= size(grid, 1) && column >= 1 && column <= size(grid, 2) ...
                && traversable(row, column) && isinf(distance(row, column))
            distance(row, column) = currentDistance + 1;
            tail = tail + 1;
            queue(tail, :) = uint16([row column]);
        end
    end
end
end

