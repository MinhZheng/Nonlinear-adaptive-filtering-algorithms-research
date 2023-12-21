function y = apply_nonlinear_function(x, N)
    y = x;
    for i = 2:N
        y = y + x.^i;
    end
end
