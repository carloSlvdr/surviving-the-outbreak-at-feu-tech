function [grid, roomMap] = createPlanDerivedGrid(cfg, floorIndex, rooms)
%CREATEPLANDERIVEDGRID Build a drawing-derived normalized occupancy grid.
% Geometry preserves the relative top/bottom room bands, central transport
% core, red stair approaches, and green-box elevator shown in the drawings.

rows = cfg.GridRows;
cols = cfg.GridColumns;
grid = repmat(cfg.Cell.Walkable, rows, cols);
grid([1 rows], :) = cfg.Cell.Wall;
grid(:, [1 cols]) = cfg.Cell.Wall;
roomMap = zeros(rows, cols, 'uint16');

if floorIndex == 1
    grid(:) = cfg.Cell.Wall;
    grid(20:22, 8:56) = cfg.Cell.Walkable;
    grid(18:22, 54:56) = cfg.Cell.GreenElevator;
    grid(20:39, 8:10) = cfg.Cell.Walkable;
    grid(39, 8) = cfg.Cell.Exit;
    return;
end

floorRoomRows = find(rooms.floor_index == floorIndex);
hasRightRooms = any(rooms.layout_band(floorRoomRows) == "right");
placeBand("top", 2, 14);
placeBand("bottom", 27, 39);

areaRows = floorRoomRows(rooms.layout_band(floorRoomRows) == "area");
for k = 1:numel(areaRows)
    sourceRow = areaRows(k);
    left = 4 + (k - 1) * 24;
    right = min(left + 20, 54);
    placeRoom(sourceRow, 3, 15, left, right, "bottom");
end

rightRows = floorRoomRows(rooms.layout_band(floorRoomRows) == "right");
for k = 1:numel(rightRows)
    sourceRow = rightRows(k);
    left = 39 + (k - 1) * 10;
    right = min(left + 9, 58);
    placeRoom(sourceRow, 14, 26, left, right, "left");
end

% Central corridor and vertical transport drawn consistently on most plans.
grid(19:21, 2:cols-1) = cfg.Cell.Walkable;
grid(18:22, 27:32) = cfg.Cell.RegularElevator;
physicalFloorId = cfg.PhysicalFloorIds(floorIndex);
if ismember(physicalFloorId, [cfg.GreenElevatorConfirmedStops cfg.GreenElevatorInferredStops])
    grid(18:20, 35:37) = cfg.Cell.GreenElevator;
end
grid(20, 2:4) = cfg.Cell.Stair;
grid(20, cols-3:cols-1) = cfg.Cell.Stair;

% The Floor-2 Student Plaza entrance is the verified external boundary.
if floorIndex == 2
    grid(20, cols) = cfg.Cell.Exit;
end
roomMap(grid ~= cfg.Cell.Room) = 0;

    function placeBand(bandName, top, bottom)
        selected = floorRoomRows(rooms.layout_band(floorRoomRows) == bandName);
        if isempty(selected)
            return;
        end
        [~, order] = sort(rooms.layout_order(selected));
        selected = selected(order);
        if hasRightRooms
            bandRight = 38;
        else
            bandRight = cols - 1;
        end
        edges = round(linspace(2, bandRight, numel(selected) + 1));
        for index = 1:numel(selected)
            left = edges(index);
            right = edges(index + 1);
            if bandName == "top"
                doorSide = "bottom";
            else
                doorSide = "top";
            end
            placeRoom(selected(index), top, bottom, left, right, doorSide);
        end
    end

    function placeRoom(sourceRow, top, bottom, left, right, doorSide)
        if right - left < 4 || bottom - top < 4
            error("Room %s is too small for the configured grid.", rooms.room_id(sourceRow));
        end
        grid(top:bottom, left:right) = cfg.Cell.Wall;
        grid(top+1:bottom-1, left+1:right-1) = cfg.Cell.Room;
        roomMap(top+1:bottom-1, left+1:right-1) = uint16(sourceRow);
        centerRow = round((top + bottom) / 2);
        centerCol = round((left + right) / 2);
        switch doorSide
            case "bottom"
                grid(bottom, centerCol) = cfg.Cell.Door;
            case "top"
                grid(top, centerCol) = cfg.Cell.Door;
            case "left"
                grid(centerRow, left) = cfg.Cell.Door;
        end
    end
end
