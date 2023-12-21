% Parameters
M1 = 8;
M2 = 64;
M = M1 + M2 - 1;
N_iter = 20000;
snr = 21;
var_noise = 0.001;
input_range = [0.3, 0.8];

% Generate FIR filter for loudspeaker
h_lsp = [1; rand(M1-1, 1) * 0.25];

% Generate nonlinear function for amplifier
A = @(x) x - 0.5 * x.^3 + 0.02 * x.^5;

% Generate linear filter for echo path
h_echo = rand(M2, 1) + 1i * rand(M2, 1);
h_echo = h_echo ./ abs(h_echo); % normalize to have unit magnitude
h_echo(1) = h_echo(1) * 0.9 * exp(1i * 2 * pi / M2);
h_echo(2) = h_echo(2) * 1.11 * exp(1i * 2 * pi / M2);
h_echo = real(ifft(h_echo));

% Generate babble signal
babble = randn(N_iter * 2, 1) * (input_range(2) - input_range(1)) + input_range(1);

% Amplify babble signal
babble_amp = A(babble);

% Simulate echo signal
echo = conv(h_lsp, babble_amp);
echo = conv(echo, h_echo);
echo = echo(1:N_iter * 2); % truncate to the same length as input

% Add Gaussian noise to the echo signal
noise = sqrt(var_noise) * randn(N_iter * 2, 1);
echo_noise = echo + noise;

% FIR filter for acoustic echo cancellation
h_aec = zeros(M, 1);

% Initialize error and ERLE
error = zeros(N_iter * 2, 1);
ERLE = zeros(N_iter * 2, 1);

% Adaptive filter using NLMS algorithm
mu = 0.01; % step size
alpha = 1e-2; % regularization parameter for NLMS
for n = 1:N_iter * 2
    % De-amplify input for the first 20,000 iterations
    if n <= N_iter
        input = babble(n) * 0.375;
    else
        input = babble(n);
    end
    
    % Update AEC filter
    x = [input; zeros(M-1, 1)];
    y = h_aec' * x;
    error(n) = echo_noise(n) - y;
    h_aec = h_aec + (mu / (alpha + norm(x)^2)) * error(n) * x;
    
    % Calculate ERLE
    ERLE(n) = 10 * log10(sum(echo(1:n).^2) / sum(error(1:n).^2));
end

% Plot ERLE for both linear and nonlinear regions
figure;
plot(1:N_iter, ERLE(1:N_iter), 'b', 'LineWidth', 2);
hold on;
plot(N_iter+1:N_iter*2, ERLE(N_iter+1:N_iter*2), 'r', 'LineWidth', 2);
xlabel('Iteration');
ylabel('ERLE (dB)');
title('Echo Return Loss (ERLE) for Linear and Nonlinear Regions');
legend('Linear Region', 'Nonlinear Region');
grid on;
