# Model specification

The active model contains 15 sequence positions mapped to physical floors `[1:12, 14:16]`. Sequence positions are used internally so Floors 12 and 14 are adjacent without creating Floor 13.

Every identified room receives one independent inclusive uniform occupancy draw. The generated total is conserved at every time point. The three controlled scenarios place one initial infected agent on physical Floor 2, 8, or 16 while holding the Hour-1 evacuation policy constant. Floor 2 uses its occupied Student Plaza, Floor 8 uses its occupied Canteen, and Floor 16 selects a random occupied office because the current inventory does not classify Floor 2 or Floor 8 spaces as offices.

Agents move through four-neighbor traversable grid cells. Walls are impassable. Room doors are normalized toward the central corridor where the drawings do not show door openings. During evacuation, agents use the shortest grid distance toward stairs, regular elevators, a supported green-elevator stop, or an authorized exit boundary.

Large-area floors use plan-specific occupied regions rather than the generic classroom-room template. Floor 2 distributes Student Plaza occupants across the open floor plate and exposes a visible lower-right entrance boundary. Floor 8 distributes Canteen occupants across the full usable floor. Floor 14 distributes Library occupants across the upper full-width and lower-right library regions shown in its drawing.

Regular elevators and emergency stairs connect only the upper-floor sequence. They cannot reach Floor 1. Each upper-floor grid contains eight distinct, vertically aligned regular elevator shafts: six in the left bank and two in the middle bank. Room bands are inset from the transport core so doors open into dedicated hallway margins rather than elevator cells. A separate right-side circulation bay keeps rooms clear of the green-box elevator and adjacent stair. The green elevator serves every modeled upper floor and is the only modeled elevator connection to Floor 1. Elevator capacity is 15 per car; eight regular cars and one green car are configured. Dispatch intervals are provisional operational abstractions.

Both Non-Infected and Infected agents may become Escaped after crossing the Floor-2 entrance or Floor-1 exit. Escaped is terminal.

Infected agents move with 65% probability per update and pursue susceptible agents with 75% probability when a same-floor target exists. After movement, every susceptible agent checks its four orthogonal neighboring cells. Each adjacent infected agent contributes a 12% bite opportunity; the initial combined bite probability is `min(35%, 1-(1-0.12)^n)`. A successful bite causes infection with 100% probability. Newly infected agents become infectious on the following update. Walls, diagonals, unrelated floors, and Escaped agents cannot transmit infection.

Entrapment pressure begins after four hours of active evacuation. For each additional hour that an individual remains indoors, the bite probability increases by 3 percentage points, up to a 75% cap. This escalation applies only when at least one infected agent is orthogonally adjacent; elapsed time alone cannot create an infection. The delay, hourly increase, and cap are provisional assumptions for later sensitivity analysis.

The current analysis is comparative, not an operational emergency plan.
