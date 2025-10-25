function NormStruct = applyNormalization(rawStruct, baseStruct, preNormStruct, method,feat)
% If "baseStruct" is empty, we skip "first step."
% If "preNormStruct" is empty, we skip "second step."
%
% Otherwise:
%   Step1 => raw vs. baseline
%   Step2 => result vs. preNormStruct
groups   = {'Trad','VR'};
hemo     = {'HbO','HbR'};
n_Trad   = 6;
n_VR     = 6;
Channels = 50;
NormStruct = struct();

for g = 1:numel(groups)
    grp = groups{g};
    if strcmp(grp,'Trad')
        n = n_Trad;
    else
        n = n_VR;
    end
    for h = 1:numel(hemo)
        NormStruct.(grp).(hemo{h}) = cell(n, Channels);

        for p = 1:n
            for c = 1:Channels
                %-----  do the first step (vs. baseline) -----
                if ~isempty(baseStruct)
                    rawHist  = rawStruct.(grp).(hemo{h}){p,c};
                    baseHist = baseStruct.(grp).(hemo{h}){p,c};
                    step1    = firstStep(rawHist, baseHist, method,feat);
                else
                    % If no baseline given, interpret "rawStruct" as already baseline-corrected
                    step1 = rawStruct.(grp).(hemo{h}){p,c};
                end

                %-----  do the second step (vs. preNormStruct) -----
                if isempty(preNormStruct)
                    % No second step
                    NormStruct.(grp).(hemo{h}){p,c} = step1;
                else
                    preHist = preNormStruct.(grp).(hemo{h}){p,c};
                    [~, step2] = secondStep(preHist, step1, method);
                    NormStruct.(grp).(hemo{h}){p,c} = step2;
                end
            end
        end
    end
end
end

function out = firstStep(test, base, method,feat)
switch lower(method)
    case 'delta'
        out = test - base;  % e.g. (Pre or Post) - Baseline
    case 'ratio'
        if feat == 'IH'
            out = 10.^(test) ./ 10.^(base); % e.g. (Pre or Post) / Baseline       
        elseif feat == 'FS'
            out = exp(log10(test./base)); % e.g. (Pre or Post) / Baseline
        elseif feat == 'MS'
            out = test./base;
        end

    otherwise
        error('Unknown method');
end
end

function [pre2, post2] = secondStep(pre, post, method)
% We want final Pre to be 0 (subtraction) or 1 (ratio),
% and final Post to be difference or ratio relative to that Pre.
switch lower(method)
    case 'delta'
        pre2  = pre - pre;    % => 0
        post2 = post - pre;   % => difference from Pre
    case 'ratio'
        pre2  = pre./pre;   % => 1
        post2 = post./pre;  % => ratio vs. Pre
    otherwise
        error('Unknown method');
end
end
