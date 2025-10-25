%% ─── Mann–Whitney U ───
function [p, DVal] = ranksumm(group1, group2)
n1 = numel(group1); n2 = numel(group2);
n = (n1+n2)/2;
if n == 1
    p = ranksum(group1,group2);
    % direction of effect
    DVal = group2 - group1;
else
% compute group means
mu1 = mean(group1(~isnan(group1)));
val1 = abs(group1-mu1);
mu2 = mean(group2(~isnan(group2)));
val2 = abs(group2-mu2);

p = ranksum(val1, val2);
% direction of effect
DVal = mu2 - mu1;
end
