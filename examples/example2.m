% Constants
memory_mi = 64;
memory_ma = 8;
order_nonlinearity = 5;
iterations = 30000;
step_size = 0.001;
regularization = 1e-6;

% Generate random input signal
input_signal = 0.3 + (0.8 - 0.3) * rand(1, iterations);

% Initialize LNL cascade structure
input_filter = rand(1, memory_mi) * 0.01;
polynomial_filter = [1, 0, 0, 0, -0.5, 0.02];
output_filter = rand(1, memory_ma) * 0.01;

% Process input signal through LNL cascade
input_filtered = filter(input_filter, 1, input_signal);

% Calculate polynomial output
input_filtered_matrix = input_filtered(:, ones(1, order_nonlinearity)) .^ (1:order_nonlinearity);
polynomial_output = sum(polynomial_filter(2:end) .* input_filtered_matrix, 2) + polynomial_filter(1) * input_filtered;

output_signal = filter(output_filter, 1, polynomial_output);

% Define a function to calculate the Echo Return Loss Enhancement (ERLE)
calculate_erle = @(true_signal, error_signal) 10 * log10(mean(true_signal.^2) / mean(error_signal.^2));

% NLMS adaptation process for input filter
error_signal = zeros(size(input_signal));

for i = 1:iterations
    % Create a matrix of delayed input signals
    input_matrix = arrayfun(@(k) input_signal(max(i - k, 1)), 1:memory_mi);

    % Calculate the output signal and error signal
    filtered_signal = dot(input_matrix, input_filter);
    error_signal(i) = input_signal(i) - filtered_signal;

    % Update the input filter coefficients using the NLMS algorithm
    input_filter = input_filter + (step_size / (norm(input_matrix)^2 + regularization)) * error_signal(i) * input_matrix;
end

% Calculate ERLE values
start_iteration = 100;

% Calculate ERLE values
erle_values = arrayfun(@(i) calculate_erle(input_signal(1:i), error_signal(1:i)), start_iteration:iterations);

% Linear region: Set the nonlinearity order to 1
linear_order_nonlinearity = 1;
linear_polynomial_filter = rand(1, linear_order_nonlinearity) * 0.01;
linear_polynomial_output = sum(linear_polynomial_filter .* input_filtered(:, ones(1, linear_order_nonlinearity)) .^ (1:linear_order_nonlinearity), 2);
linear_output_signal = filter(output_filter, 1, linear_polynomial_output);

linear_error_signal = zeros(size(input_signal));
for i = 1:iterations
    input_matrix = arrayfun(@(k) input_signal(max(i - k, 1)), 1:memory_mi);
    filtered_signal = dot(input_matrix, input_filter);
    linear_error_signal(i) = input_signal(i) - filtered_signal;
end

linear_erle_values = arrayfun(@(i) calculate_erle(input_signal(1:i), linear_error_signal(1:i)), start_iteration:iterations);

% Plot the ERLE values for both linear and nonlinear regions
figure;
plot(erle_values, 'DisplayName', 'LNL cascade with memoryless polynomial filter (Nonlinear region)');
hold on;
plot(linear_erle_values, 'DisplayName', 'LNL cascade with memoryless polynomial filter (Linear region)');
xlabel('Iteration');
ylabel('ERLE (dB)');
title('ERLE plot for LNL cascade and memoryless polynomial filter');
legend('show');
hold off;
