% Function to calculate ERLE
function ERLE = calculate_ERLE(echo_signal_noisy, echo_signal_canceled, window_length)
    error_signal = echo_signal_noisy - echo_signal_canceled;
    input_power = movmean(echo_signal_noisy .^ 2, window_length);
    error_power = movmean(error_signal .^ 2, window_length);
    ERLE = 10 * log10(input_power ./ error_power);
end