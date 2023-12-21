% Loudspeaker model function
function [loudspeaker_output, loudspeaker_output_nonlinear] = loudspeaker_model(input_signal, fir_coeffs, amplifier_function)
    % Apply the FIR filter
    loudspeaker_output = filter(fir_coeffs, 1, input_signal);

    % Apply the static nonlinearity
    loudspeaker_output_nonlinear = amplifier_function(loudspeaker_output);
end
