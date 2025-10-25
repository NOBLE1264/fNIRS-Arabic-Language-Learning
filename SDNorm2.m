clc; clear; close all;

%% ========= SETTINGS =========
method       = 'ratio';        % 'ratio' for Post/Pre
Channels     = 50;
selectedDay  = 1; 
day          = sprintf('Day%d', selectedDay);

targetConds  = {'Receptive','Productive'};   % Step-2 (Post/Pre) plots
hemoLabels   = {'\Delta[HbO]','\Delta[HbR]'};
missCol      = [0 0 0];

% --- Blue → White → Red colormap centered at 1 ---
numColorsHalf = 128;
blueToWhite = [linspace(0,1,numColorsHalf)', linspace(0,1,numColorsHalf)', ones(numColorsHalf,1)];
whiteToRed  = [ones(numColorsHalf,1), linspace(1,0,numColorsHalf)', linspace(1,0,numColorsHalf)'];
cmap = [blueToWhite; whiteToRed];
ratioCLim = [0.5 1.5];  % range around center=1

%% ========= LOAD DB =========
DB2 = load('DB2.mat');

%% ========= CONDITION MAPS / HELPERS =========
condNames = {'LearningBaseline','PretestBaseline','PosttestBaseline', ...
             'Learning','ReceptivePosttest','ReceptivePretest', ...
             'ProductivePosttest','ProductivePretest'};
condIdxMap = containers.Map(condNames, num2cell(1:numel(condNames)));
groups = {'Trad','VR'};  hemo = {'HbO','HbR'};

%% ========= EXTRACT SD -> DATA =========
for gi = 1:numel(groups)
    G = groups{gi};
    GDay = DB2.(G).(day);
    nP   = size(GDay,1);

    for ci = 1:numel(condNames)
        cName = condNames{ci};
        idx   = condIdxMap(cName);
        for ch = 1:Channels
            for p = 1:nP
                SD = GDay(p,idx).StandardDeviation{ch};
                for h = 1:2
                    DATA.(cName).(G).(hemo{h}){p,ch} = SD(:,h);
                end
            end
        end
    end
end

%% ========= STEP-1 BASELINE NORMALIZATION =========
NormDATA.ReceptivePretest  = applyNormalization(DATA.ReceptivePretest,  DATA.PretestBaseline,  [], method, 'MS');
NormDATA.ReceptivePosttest = applyNormalization(DATA.ReceptivePosttest, DATA.PosttestBaseline, [], method, 'MS');
NormDATA.ProductivePretest  = applyNormalization(DATA.ProductivePretest,  DATA.PretestBaseline,  [], method, 'MS');
NormDATA.ProductivePosttest = applyNormalization(DATA.ProductivePosttest, DATA.PosttestBaseline, [], method, 'MS');
NormDATA.Learning = applyNormalization(DATA.Learning, DATA.LearningBaseline, [], method, 'MS');

%% ========= STEP-2: BUILD Post/Pre MATRICES =========
Step2.Receptive.Trad = build_step2_mats(NormDATA, 'Trad', 'ReceptivePretest',  'ReceptivePosttest',  Channels, method);
Step2.Receptive.VR   = build_step2_mats(NormDATA, 'VR',   'ReceptivePretest',  'ReceptivePosttest',  Channels, method);
Step2.Productive.Trad = build_step2_mats(NormDATA, 'Trad', 'ProductivePretest', 'ProductivePosttest', Channels, method);
Step2.Productive.VR   = build_step2_mats(NormDATA, 'VR',   'ProductivePretest', 'ProductivePosttest', Channels, method);

%% ========= PLOT FIGURES (6×1 layout) =========
for tc = 1:numel(targetConds)
    tag = targetConds{tc};
    plot_group_heatmaps_6x1(Step2.(tag).Trad, 'Traditional', tag, hemoLabels, ratioCLim, missCol, cmap);
    plot_group_heatmaps_6x1(Step2.(tag).VR,   'VR',          tag, hemoLabels, ratioCLim, missCol, cmap);
end

%% ======================= FUNCTIONS =======================
function mats = build_step2_mats(NormDATA, group, preKey, postKey, Channels, method)
    HbO_pre = NormDATA.(preKey).(group).HbO;
    HbR_pre = NormDATA.(preKey).(group).HbR;
    HbO_post= NormDATA.(postKey).(group).HbO;
    HbR_post= NormDATA.(postKey).(group).HbR;
    nP = size(HbO_pre,1); mats = cell(nP,1);

    for p = 1:nP
        M = nan(2, Channels);
        for ch = 1:Channels
            preO  = fetch_scalar(HbO_pre,  p, ch);
            preR  = fetch_scalar(HbR_pre,  p, ch);
            postO = fetch_scalar(HbO_post, p, ch);
            postR = fetch_scalar(HbR_post, p, ch);
            if strcmpi(method,'ratio')
                M(1,ch) = safe_div(postO, preO);
                M(2,ch) = safe_div(postR, preR);
            else
                M(1,ch) = postO - preO;
                M(2,ch) = postR - preR;
            end
        end
        mats{p} = M;
    end
end

function x = fetch_scalar(C, p, ch)
    x = NaN;
    try
        v = C{p,ch};
        if isempty(v), return; end
        if isscalar(v), x = v; else, x = mean(v(:),'omitnan'); end
    catch, x = NaN; end
end

function z = safe_div(a,b)
    if isnan(a)||isnan(b)||b==0, z = NaN; else, z = a/b; end
end

function plot_group_heatmaps_6x1(mats, groupName, condName, ytickLabels, climVals, missCol, cmap)
    nP = numel(mats);
    nRows = nP; nCols = 1;

    figure('Color','w','Name',sprintf('%s — %s (SDNorm2)',groupName,condName), ...
           'NumberTitle','off','Position',[200 50 1800 1200]);
    % tl = tiledlayout(nRows, nCols, 'Padding','compact','TileSpacing','compact');
    % title(tl, sprintf('%s — %s (SDNorm2)', groupName, condName), 'FontWeight','bold');

    for p = 1:nP
        subplot(6,1,p)
        H = heatmap(mats{p});
        H.YData = ytickLabels;
        H.XLabel = 'Channels'; 
        H.YLabel = '';
        H.Title  = sprintf('Participant %d', p);
        H.ColorLimits = climVals;
        H.MissingDataColor = missCol;
        H.MissingDataLabel = 'NaN';
        H.CellLabelColor   = 'none';
        H.Colormap = cmap;
        H.FontSize= 12;
    end
end
