function grid = createPlanDerivedGrid(cfg, floorNumber)
%CREATEPLANDERIVEDGRID Build a simplified schematic from the supplied plans.
% These grids preserve major spatial relationships, not drawing-scale geometry.

rows = cfg.GridRows;
cols = cfg.GridColumns;
grid = repmat(cfg.Cell.Special, rows, cols);
grid([1 rows], :) = cfg.Cell.Wall;
grid(:, [1 cols]) = cfg.Cell.Wall;

switch floorNumber
    case 2 % Student Plaza: broad open area with service core to the right.
        grid(27:38, 45:58) = cfg.Cell.Wall;
        grid(30:37, 47:55) = cfg.Cell.Room;
        grid(31, 45:47) = cfg.Cell.Walkable;
        grid(2:38, 18:20) = cfg.Cell.Walkable;
        grid(19:21, 2:58) = cfg.Cell.Walkable;

    case 3 % Swimming Pool: pool is inaccessible; circulation surrounds it.
        grid(7:31, 8:46) = cfg.Cell.Wall;
        grid(6, 7:47) = cfg.Cell.Walkable;
        grid(32, 7:47) = cfg.Cell.Walkable;
        grid(6:32, 7) = cfg.Cell.Walkable;
        grid(6:32, 47) = cfg.Cell.Walkable;
        grid(14:25, 49:58) = cfg.Cell.Room;
        grid(19:21, 47:49) = cfg.Cell.Walkable;

    case 8 % Canteen: open dining floor around central concession blocks.
        grid(11:27, 19:41) = cfg.Cell.Wall;
        grid(13:25, 21:39) = cfg.Cell.Room;
        grid(18:20, 19:41) = cfg.Cell.Walkable;
        grid(10:12, 29:31) = cfg.Cell.Walkable;
        grid(27:29, 29:31) = cfg.Cell.Walkable;
        grid(2:38, 46:48) = cfg.Cell.Walkable;

    case 13 % Library: open learning areas with furniture islands.
        for row = [9 17 25 33]
            for column = [12 25 38 51]
                grid(row:row+1, column:column+3) = cfg.Cell.Wall;
            end
        end
        grid(19:21, 2:58) = cfg.Cell.Walkable;
        grid(2:38, 29:31) = cfg.Cell.Walkable;

    case 15 % Audio Visual Room: stepped seating with a front hallway.
        grid(33:38, 2:58) = cfg.Cell.Walkable;
        for row = [8 13 18 23 28]
            grid(row, 7:25) = cfg.Cell.Wall;
            grid(row, 36:54) = cfg.Cell.Wall;
        end
        grid(2:38, 29:31) = cfg.Cell.Walkable;
        grid(32:34, [12:14 46:48]) = cfg.Cell.Walkable;

    case 16 % 17th Floor: multipurpose room and gym linked by a lobby.
        grid(19:21, 2:58) = cfg.Cell.Walkable;
        grid(2:18, 2:43) = cfg.Cell.Special;
        grid(22:38, 10:58) = cfg.Cell.Special;
        grid(2:18, 44:58) = cfg.Cell.Room;
        grid(19:23, 29:31) = cfg.Cell.Walkable;
        grid(22:38, 2:8) = cfg.Cell.Room;

    otherwise
        error("No plan-derived schematic is defined for floor index %d.", floorNumber);
end

% Shared connector coordinates support the inter-floor software contract.
grid(3, 3) = cfg.Cell.Stair;
grid(rows-2, cols-2) = cfg.Cell.Stair;
grid(floor(rows/2), cols-3) = cfg.Cell.Elevator;

% Ensure short connector approaches are open.
grid(3:5, 3:5) = cfg.Cell.Walkable;
grid(3, 3) = cfg.Cell.Stair;
grid(rows-4:rows-2, cols-4:cols-2) = cfg.Cell.Walkable;
grid(rows-2, cols-2) = cfg.Cell.Stair;
grid(floor(rows/2), cols-5:cols-2) = cfg.Cell.Walkable;
grid(floor(rows/2), cols-3) = cfg.Cell.Elevator;
end

