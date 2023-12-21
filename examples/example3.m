

iterations = 30000;
memory_volterra = 8;
order_nonlinearity = 3;
step_size = 0.0005;

rng('default'); % For reproducibility

% Generate input signals
linear_input_signal = 0.1 + (0.3 - 0.1) * rand(iterations, 1);
nonlinear_input_signal = 0.3 + (0.8 - 0.3) * rand(iterations, 1);

% Known system
known_system = rand(32, 1);
linear_desired_signal = filter(known_system, 1, linear_input_signal);
nonlinear_desired_signal = filter(known_system, 1, nonlinear_input_signal);

% Initialize Volterra filters
volterra_filter = 0.01 * rand(order_nonlinearity, memory_volterra, memory_volterra);

% Update Volterra filters
volterra_filter_linear = update_volterra_filter(linear_input_signal, linear_desired_signal, volterra_filter, step_size, iterations, memory_volterra, order_nonlinearity);
volterra_filter_nonlinear = update_volterra_filter(nonlinear_input_signal, nonlinear_desired_signal, volterra_filter, step_size, iterations, memory_volterra, order_nonlinearity);

% Process signals through the updated Volterra filters
linear_output_signal = process_signal(linear_input_signal, volterra_filter_linear, iterations, memory_volterra, order_nonlinearity);
nonlinear_output_signal = process_signal(nonlinear_input_signal, volterra_filter_nonlinear, iterations, memory_volterra, order_nonlinearity);

% Calculate ERLE values
linear_erle_values = calculate_erle(linear_desired_signal, linear_output_signal, iterations);
nonlinear_erle_values = calculate_erle(nonlinear_desired_signal, nonlinear_output_signal, iterations);

% Plot the ERLE values
figure;
plot(linear_erle_values, 'DisplayName', 'Linear region');
hold on;
plot(nonlinear_erle_values, 'DisplayName', 'Nonlinear region');
xlabel('Iteration');
ylabel('ERLE (dB)');
title('ERLE plot for linear and nonlinear regions');
legend;
grid on;
hold off;

function volterra_filter = update_volterra_filter(input_signal, desired_signal, volterra_filter, step_size, iterations, memory_volterra, order_nonlinearity)
    for j = 1:iterations
        delayed_inputs = zeros(memory_volterra, 1);
        for k = 1:memory_volterra
            if j - k >= 1
                delayed_inputs(k) = input_signal(j - k);
            end
        end
        
        output_signal = 0;
        for i = 1:order_nonlinearity
            output_signal = output_signal + sum(sum(volterra_filter(i, :, :) .* (delayed_inputs * delayed_inputs').^i));
        end
        
        error_signal = desired_signal(j) - output_signal;
        
        for i = 1:order_nonlinearity
            gradient = i * (delayed_inputs * delayed_inputs').^(i - 1);
            volterra_filter(i, :, :) = volterra_filter(i, :, :) + step_size * error_signal .* reshape(gradient, [1, memory_volterra, memory_volterra]);
        end
    end
end





function volterra_output = process_signal(input_signal, volterra_filter, iterations, memory_volterra, order_nonlinearity)
    volterra_output = zeros(iterations, 1);
    for j = 1:iterations
        delayed_inputs = zeros(memory_volterra, 1);
        for k = 1:memory_volterra
            if j - k >= 1
                delayed_inputs(k) = input_signal(j - k);
            end
        end
        
        for i = 1:order_nonlinearity
            volterra_output(j) = volterra_output(j) + sum(sum(volterra_filter(i, :, :) .* reshape((delayed_inputs * delayed_inputs').^i, [1, memory_volterra, memory_volterra])));
        end
    end
end


function erle_values = calculate_erle(desired_signal, output_signal, iterations)
    erle_values = zeros(iterations, 1);
    for i = 1:iterations
        error_signal = desired_signal(1:i) - output_signal(1:i);
        erle_values(i) = 10 * log10(mean(desired_signal(1:i).^2) / mean(error_signal.^2));
    end
end

