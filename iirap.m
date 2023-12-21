function [num, den] = iirap(n, p, z)
% IIR all-pass filter design using the frequency sampling method
% n: filter order
% p: complex conjugate poles
% z: complex conjugate zeros
% num: numerator coefficients
% den: denominator coefficients

if mod(n, 2) ~= 0
    error('Filter order must be even.');
end

k = 0:n/2;
theta_p = angle(p);
theta_z = angle(z);

p_mag = abs(p);
z_mag = abs(z);

g = sqrt(p_mag(1)/z_mag(1));
bp = g * exp(1j * theta_p);
bz = exp(1j * theta_z);

for i = 2:n/2+1
    g = sqrt(p_mag(i)/z_mag(i)) * g;
    bp = [bp, g * exp(1j * theta_p(i))];
    bz = [bz, exp(1j * theta_z(i))];
end

omega = linspace(-pi, pi, 2^12+1);
omega = omega(1:end-1);

h_p = ones(size(omega));
h_z = ones(size(omega));

for i = 1:length(p)
    h_p = h_p .* (exp(1j*omega) - p(i));
    h_z = h_z .* (exp(1j*omega) - z(i));
end

h_ap = h_p ./ h_z;
h_ap = exp(-1j*omega*n/2) .* h_ap;

Hd = fft(h_ap);
B = [bp(end:-1:2), bp];
A = [bz(end:-1:2), bz];
H = freqz(B, A, omega);

W = abs(Hd ./ H);

b = real(ifft(W .* exp(1j*angle(H))));
b = b(1:n/2+1);
num = [b, fliplr(b(2:end-1))];
den = A;
