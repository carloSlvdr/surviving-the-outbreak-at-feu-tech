function writeScenarioOutputs(result, outputRoot)
%WRITESCENARIOOUTPUTS Export one scenario's tables and population graph.

safeName = lower(regexprep(result.scenarioName, "[^A-Za-z0-9]+", "_"));
scenarioDir = fullfile(outputRoot, safeName);
if ~isfolder(scenarioDir)
    mkdir(scenarioDir);
end

writetable(result.timeSeries, fullfile(scenarioDir, "population_timeseries.csv"));
writetable(result.summary, fullfile(scenarioDir, "final_summary.csv"));

fig = figure('Visible', 'off', 'Color', 'white');
plot(result.timeSeries.time_hours, result.timeSeries.infected, 'r-', 'LineWidth', 1.8);
hold on;
plot(result.timeSeries.time_hours, result.timeSeries.non_infected, 'b-', 'LineWidth', 1.8);
plot(result.timeSeries.time_hours, result.timeSeries.escaped, 'g-', 'LineWidth', 1.8);
xlabel('Simulated time (hours)');
ylabel('Agents');
title(result.scenarioName + " — Population Progression");
legend('Infected', 'Non-Infected', 'Escaped', 'Location', 'best');
grid on;
exportgraphics(fig, fullfile(scenarioDir, "population_progression.png"), 'Resolution', 160);
close(fig);
end

