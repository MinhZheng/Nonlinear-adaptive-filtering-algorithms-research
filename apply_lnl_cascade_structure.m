function echo_signal_canceled = apply_lnl_cascade_structure(input_signal, w1, w2, N)
    M1 = length(w1);
    M2 = length(w2);
    L = length(input_signal);
    
    echo_signal_canceled = zeros(1, L);
    
    for n = max(M1, M2):L
        % Create input vector for the input filter (FIR)
        u1 = input_signal(n:-1:n-M1+1).';
        
        % Apply the input filter
        input_filter_output = w1' * u1;
        
        % Apply the nonlinear function (memoryless polynomial of order N)
        nonlinear_output = apply_nonlinear_function(input_filter_output, N);
        
        % Create input vector for the output filter (IIR)
        u2 = [nonlinear_output; w2(1:end-1)];
        
        % Apply the output filter
        echo_signal_canceled(n) = w2' * u2;
    end
end


