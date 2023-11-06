function alpha=wrapToPi(alpha)

q = (alpha < -pi) | (pi < alpha);
alpha(q) = wrapTo2Pi(alpha(q) + pi) - pi;
end


function alpha = wrapTo2Pi(alpha)
positiveInput = (alpha > 0);
alpha = mod(alpha, 2*pi);
alpha((alpha == 0) & positiveInput) = 2*pi;
end
