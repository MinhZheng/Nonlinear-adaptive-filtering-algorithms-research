function [echo_signal_linear, echo_signal_nonlinear] = generate_echo_signals(input_signal_linear, input_signal_nonlinear, fir_coeffs, amplifier_function, fir_echo_path)
    % Apply the loudspeaker model to the input signals
    [loudspeaker_output_linear, loudspeaker_output_nonlinear_linear] = loudspeaker_model(input_signal_linear, fir_coeffs, amplifier_function);
    [loudspeaker_output_nonlinear, loudspeaker_output_nonlinear_nonlinear] = loudspeaker_model(input_signal_nonlinear, fir_coeffs, amplifier_function);

    % Generate echo signals for the linear and nonlinear regions
    echo_signal_linear = filter(fir_echo_path, 1, loudspeaker_output_nonlinear_linear);
    echo_signal_nonlinear = filter(fir_echo_path, 1, loudspeaker_output_nonlinear_nonlinear);
end
