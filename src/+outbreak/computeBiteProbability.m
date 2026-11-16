function probability = computeBiteProbability(cfg, adjacentInfected)
%COMPUTEBITEPROBABILITY Probability of at least one successful bite attempt.
probability = min(cfg.MaximumBiteProbability, ...
    1 - (1 - cfg.BiteProbability) .^ adjacentInfected);
end
