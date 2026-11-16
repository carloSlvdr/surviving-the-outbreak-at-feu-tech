function probability = computeBiteProbability(cfg, adjacentInfected, entrapmentHours)
%COMPUTEBITEPROBABILITY Probability of at least one successful bite attempt.
if nargin < 3
    entrapmentHours = 0;
end
baseProbability = min(cfg.MaximumBiteProbability, ...
    1 - (1 - cfg.BiteProbability) .^ adjacentInfected);
growthHours = max(0, entrapmentHours - cfg.EntrapmentRiskDelayHours);
entrapmentIncrease = growthHours * cfg.EntrapmentBiteProbabilityIncreasePerHour;
probability = min(cfg.EntrapmentMaximumBiteProbability, baseProbability + entrapmentIncrease);
probability(adjacentInfected <= 0) = 0;
end
