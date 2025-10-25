function [H, pValue, W] = swtest(x, alpha)
%SWTEST Shapiro-Wilk parametric hypothesis test of composite normality.
%   H = SWTEST(X) performs the Shapiro-Wilk test to determine if the null
%   hypothesis of composite normality is a reasonable assumption regarding
%   the population distribution of a random sample X. The result is H=0 if
%   the null hypothesis cannot be rejected at the 5% significance level, or
%   H=1 if the null hypothesis can be rejected.
%
%   [H, PVALUE, W] = SWTEST(X,ALPHA) returns the p-value and W statistic
%   of the Shapiro-Wilk test. The default significance level is 0.05.

% Reference:
% Shapiro, S.S. & Wilk, M.B. (1965). "An analysis of variance test for
% normality (complete samples)", Biometrika, Vol. 52, pp. 591–611.

if nargin < 2
    alpha = 0.05;
end

x = sort(x(:));          % ensure column vector and sort
n = length(x);

if n < 3
    error('Sample size must be at least 3.');
elseif n > 50
    warning('Test is not accurate for n > 50. Use with caution.');
end

mtilde = norminv(((1:n)' - 3/8) / (n + 1/4));
u = mtilde / norm(mtilde);
a = flipud(u);           % coefficients

xbar = mean(x);
s2 = sum((x - xbar).^2);
W = (a' * x)^2 / s2;

% Approximate p-value (Royston 1995 approximation)
mu = -1.2725 + 1.0521 * log(n);
sigma = exp(-1.111 + 0.60306 * log(n));
z = log(1 - W);
pValue = normcdf((z - mu) / sigma, 0, 1);

H = pValue < alpha;

end
