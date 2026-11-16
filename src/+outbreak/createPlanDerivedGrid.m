function grid = createPlanDerivedGrid(cfg, floorNumber)
%CREATEPLANDERIVEDGRID Build a normalized schematic from supplied plans.
% The grids preserve circulation topology and major zones, not drawing scale.

rows = cfg.GridRows;
cols = cfg.GridColumns;

switch floorNumber
    case 2 % Open student plaza with service core and broad common space.
        grid = openPlan(cfg);
        grid(7:17, 5:16) = cfg.Cell.Room;
        grid(23:35, 5:16) = cfg.Cell.Room;
        grid(10:30, 22:25) = cfg.Cell.Wall;
        grid(18:22, 22:25) = cfg.Cell.Walkable;
        grid(7:32, 43:55) = cfg.Cell.Special;

    case 3 % Recreation floor with a large inaccessible pool/void.
        grid = openPlan(cfg);
        grid(6:32, 35:54) = cfg.Cell.Wall;
        grid(5, 34:55) = cfg.Cell.Walkable;
        grid(33, 34:55) = cfg.Cell.Walkable;
        grid(5:33, 33:34) = cfg.Cell.Walkable;
        grid(7:17, 5:20) = cfg.Cell.Room;
        grid(23:34, 5:20) = cfg.Cell.Special;

    case {4, 5, 6, 7, 9, 10, 11, 12}
        % Double-loaded academic floors: perimeter rooms, central corridor,
        % elevator/service core, and stairs at opposite ends.
        grid = academicPlan(cfg);
        if floorNumber == 4
            grid(23:34, 43:55) = cfg.Cell.Special; % clinic/study area
        elseif floorNumber == 5
            grid(7:17, 5:18) = cfg.Cell.Special;  % administrative office
        elseif floorNumber == 6
            grid(23:34, 5:18) = cfg.Cell.Special; % study area
        elseif floorNumber == 7
            grid(23:34, 16:27) = cfg.Cell.Special; % engineering department
        elseif floorNumber == 9
            grid(7:17, 44:55) = cfg.Cell.Special; % faculty/laboratory zone
        elseif floorNumber == 10
            grid(7:17, 44:55) = cfg.Cell.Special; % computer engineering office
        elseif floorNumber == 11
            grid(7:17, 5:17) = cfg.Cell.Special;
            grid(23:34, 5:17) = cfg.Cell.Special; % student lounges
        elseif floorNumber == 12
            grid(7:17, 43:55) = cfg.Cell.Special; % CSO-MIS office
        end

    case 8 % Long canteen/event floor with a central concession block.
        grid = openPlan(cfg);
        grid(5:35, 8:12) = cfg.Cell.Room;
        grid(5:35, 48:53) = cfg.Cell.Room;
        grid(8:31, 25:35) = cfg.Cell.Wall;
        grid(10:29, 27:33) = cfg.Cell.Special;
        grid(18:22, 12:48) = cfg.Cell.Walkable;
        grid(5:35, 43:46) = cfg.Cell.Walkable;

    case 13 % Library level with open reading zones and furniture islands.
        grid = openPlan(cfg);
        grid(6:16, 5:18) = cfg.Cell.Room;   % ERC
        grid(24:35, 5:18) = cfg.Cell.Room;  % MRC
        grid(24:35, 20:33) = cfg.Cell.Room; % discussion room
        for row = [7 13 27 33]
            for column = [37 45 53]
                grid(row:row+1, column:column+3) = cfg.Cell.Wall;
            end
        end

    case 14 % Mirrored 15th-floor room-and-office arrangement.
        grid = fliplr(academicPlan(cfg));
        grid(7:17, 5:16) = cfg.Cell.Special;
        grid(23:34, 44:55) = cfg.Cell.Special;

    case 15 % 16th floor with offices and two auditorium/AVR zones.
        grid = academicPlan(cfg);
        for row = [26 29 32]
            grid(row, 16:26) = cfg.Cell.Wall;
            grid(row, 35:45) = cfg.Cell.Wall;
        end
        grid(25:34, 14:28) = cfg.Cell.Special;
        grid(25:34, 33:47) = cfg.Cell.Special;

    case 16 % 17th floor: multipurpose room and gym linked by a lobby.
        grid = openPlan(cfg);
        grid(5:17, 5:42) = cfg.Cell.Special;
        grid(23:35, 12:55) = cfg.Cell.Special;
        grid(5:17, 45:55) = cfg.Cell.Room;
        grid(23:35, 5:9) = cfg.Cell.Room;
        grid(18:22, 2:58) = cfg.Cell.Walkable;

    otherwise
        error("No plan-derived schematic is defined for floor index %d.", floorNumber);
end

% Normalize inter-floor connector coordinates for the simulation contract.
grid(3:5, 3:5) = cfg.Cell.Walkable;
grid(3, 3) = cfg.Cell.Stair;
grid(rows-4:rows-2, cols-4:cols-2) = cfg.Cell.Walkable;
grid(rows-2, cols-2) = cfg.Cell.Stair;
grid(floor(rows/2), cols-5:cols-2) = cfg.Cell.Walkable;
grid(floor(rows/2), cols-3) = cfg.Cell.Elevator;
end

function grid = openPlan(cfg)
grid = repmat(cfg.Cell.Special, cfg.GridRows, cfg.GridColumns);
grid([1 cfg.GridRows], :) = cfg.Cell.Wall;
grid(:, [1 cfg.GridColumns]) = cfg.Cell.Wall;
grid(19:21, 2:cfg.GridColumns-1) = cfg.Cell.Walkable;
end

function grid = academicPlan(cfg)
grid = repmat(cfg.Cell.Room, cfg.GridRows, cfg.GridColumns);
grid([1 cfg.GridRows], :) = cfg.Cell.Wall;
grid(:, [1 cfg.GridColumns]) = cfg.Cell.Wall;
grid(19:21, 2:cfg.GridColumns-1) = cfg.Cell.Walkable;

% Room dividers include door gaps into the central corridor.
for column = [11 20 29 39 48]
    grid(2:17, column) = cfg.Cell.Wall;
    grid(16:18, column) = cfg.Cell.Room;
    grid(23:cfg.GridRows-1, column) = cfg.Cell.Wall;
    grid(22:24, column) = cfg.Cell.Room;
end

% Central vertical-transport/service core, split by the main corridor.
grid(12:18, 27:34) = cfg.Cell.Wall;
grid(22:28, 27:34) = cfg.Cell.Wall;
grid(16:18, 29:31) = cfg.Cell.Walkable;
grid(22:24, 29:31) = cfg.Cell.Walkable;
end
