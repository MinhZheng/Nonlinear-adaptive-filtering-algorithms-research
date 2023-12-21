function [w1, w2] = identify_lnl_cascade_structure(input_signal, echo_signal_noisy, M1, M2, N, mu, num_iterations)
    % Initialize the filter coefficients
    w1 = zeros(M1, 1);
    w2 = zeros(M2, 1);
    epsilon = 1e-6; % Small constant to prevent division by zero or near-zero values
    
    % Implement the LMS algorithm for identifying the LNL cascade structure
    for iter = 1:num_iterations
        error_sum = 0;
        for n = max(M1, M2):length(input_signal)
            
            % Create input vector for the input filter (FIR)
            u1 = input_signal(n:-1:n-M1+1).';
            
            % Update the input filter coefficients
            e1 = echo_signal_noisy(n) - w1' * u1;
            w1 = w1 + mu * e1 * u1 / (norm(u1)^2 + epsilon);
            
            % Apply the nonlinear function (memoryless polynomial of order N)
            nonlinear_output = apply_nonlinear_function(w1' * u1, N);
            
            % Create input vector for the output filter (IIR)
            u2 = [nonlinear_output; w2(1:end-1)];
            
            % Update the output filter coefficients
            e2 = echo_signal_noisy(n) - w2' * u2;
            w2 = w2 + mu * e2 * u2 / (norm(u2)^2 + epsilon);
            
            error_sum = error_sum + e2^2;
        end

        % Calculate mean squared error
        mse = error_sum / (length(input_signal) - max(M1, M2));

        % Print progress
        fprintf('Iteration: %d, Mean Squared Error: %f\n', iter, mse);

        % Stopping condition
        if iter >= num_iterations
            break;
        end
    end
end
