function [input_signal_linear, input_signal_nonlinear] = generate_input_signal()
    % Set the input signal range for the linear and nonlinear regions
    input_range_linear = [0.1, 0.3];
    input_range_nonlinear = [0.3, 0.8];
    N = 10000;

    % Generate input signals for the linear and nonlinear regions
    input_signal_linear = input_range_linear(1) + (input_range_linear(2) - input_range_linear(1)) * rand(1, N);
    input_signal_nonlinear = input_range_nonlinear(1) + (input_range_nonlinear(2) - input_range_nonlinear(1)) * rand(1, N);
end
