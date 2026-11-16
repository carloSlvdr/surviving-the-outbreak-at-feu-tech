# Model specification

The active model contains 15 sequence positions mapped to physical floors `[1:12, 14:16]`. Sequence positions are used internally so Floors 12 and 14 are adjacent without creating Floor 13.

Every identified room receives one independent inclusive uniform occupancy draw. The generated total is conserved at every time point. One initial infected agent is placed on physical Floor 8 by default.

Agents move through four-neighbor traversable grid cells. Walls are impassable. Room doors are normalized toward the central corridor where the drawings do not show door openings. During evacuation, agents use the shortest grid distance toward stairs, regular elevators, a supported green-elevator stop, or an authorized exit boundary.

Regular elevators and emergency stairs connect only the upper-floor sequence. They cannot reach Floor 1. The green-box elevator is the only modeled connection to Floor 1. Elevator capacity is 15 per car; eight regular cars and one green car are configured. Dispatch intervals are provisional operational abstractions.

Both Non-Infected and Infected agents may become Escaped after crossing the Floor-2 entrance or Floor-1 exit. Escaped is terminal. Infection uses same-floor four-neighbor contact and cannot cross walls or floors.

The current analysis is comparative, not an operational emergency plan.
