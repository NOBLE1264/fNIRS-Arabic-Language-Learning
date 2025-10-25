clc; clear; close all;

%% ===================== CONFIG =====================
method      = 'ratio';      % 'delta' or 'ratio'
alpha       = 0.05;
n_Trad      = 6;            % Traditional group size
n_VR        = 6;            % VR group size
Channels    = 50;
selectedDay = 1; day = sprintf('Day%d', selectedDay);
feat        = 'MS';
lim         = 5;            % color limits for ΔSD

conds_keys  = {'Learning','ReceptivePosttest','ProductivePosttest'};
conds_ttls  = {'Learning','Receptive Test','Productive Test'};
hemoLabels  = {'\Delta[HbO]','\Delta[HbR]'};

% Brain region channel groups (by channel number in ch_data(:,3))
FrontalCh   = [1,2,3,4,5,6,7,8,9,11,13,14,15,16,17,18,19,20,23,24,25,26,27,28,29,30,31,32,33,34,35,38];
ParietalCh  = [24,26,33,34,36,37,39,40,41,42,43,44,45,46,47,48,49,50];
TemporalCh  = [10,12,21,22];
% Colors
s             = 0.35;           % Shade
FrontalColor  = [0.5 0 0.5];    % purple
ParietalColor = [0 0.6 0];      % green
TemporalColor = [1 0.5 0];      % yellow
NonSigColor   = 0.95*[1 1 1];

% Custom ΔSD colormap (blue→white→red)
nHalf       = 128;
cmap        = [linspace(0,1,nHalf)' , linspace(0,1,nHalf)' , ones(nHalf,1) ; ...
    ones(nHalf,1)        , linspace(1,0,nHalf)' , linspace(1,0,nHalf)'];
sigCMap     = [0 0.5 0 ; NonSigColor];  % green vs gray

%% ===================== DATA LOAD =====================
DB2      = load('DB2.mat');
ch_data  = load('ChannelCoor.txt');     % columns: x, y, chNum
img      = imread('Brain.jpg');

% scale channel coords to image
img_sz   = size(img);
xC = ch_data(:,1) * img_sz(2)/17;
yC = img_sz(1) - (ch_data(:,2) * img_sz(1)/17);
sh_x = 5;  sh_y = 50;

% Aliases
bL='LearningBaseline'; bPre='PretestBaseline'; bPost='PosttestBaseline';
rPre='ReceptivePretest'; rPost='ReceptivePosttest';
pPre='ProductivePretest'; pPost='ProductivePosttest';
groups = {'Trad','VR'};
hemo   = {'HbO','HbR'};
allConds = {bL,bPre,bPost,'Learning',rPost,rPre,pPost,pPre};

%% ===================== EXTRACT SD INTO DATA =====================
for gi = 1:numel(groups)
    group = groups{gi}; n = iff(strcmp(group,'Trad'), n_Trad, n_VR);
    for ci = 1:numel(allConds)
        cName = allConds{ci};
        for ch = 1:Channels
            for p = 1:n
                SD = DB2.(group).(day)(p, findCondIdx(cName)).StandardDeviation{ch};
                % SD(:,1)=HbO SD, SD(:,2)=HbR SD
                for h = 1:2
                    DATA.(cName).(group).(hemo{h}){p,ch} = SD(:,h);
                end
            end
        end
    end
end

%% ===================== NORMALIZATION =====================
NormDATA.(rPre)  = applyNormalization(DATA.(rPre),  DATA.(bPre),  [], method, feat);
NormDATA.(rPost) = applyNormalization(DATA.(rPost), DATA.(bPost), [], method, feat);
NormDATA.Learning= applyNormalization(DATA.Learning,DATA.(bL),    [], method, feat);
NormDATA.(pPre)  = applyNormalization(DATA.(pPre),  DATA.(bPre),  [], method, feat);
NormDATA.(pPost) = applyNormalization(DATA.(pPost), DATA.(bPost), [], method, feat);

%% ===================== STATS (Trad vs VR) =====================
for ci = 1:numel(conds_keys)
    key = conds_keys{ci};
    [DVals.(key), pVals.(key)] = computePvals_Std(NormDATA.(key));
end
NaNVals = getNaNChannels(NormDATA, feat);  % expects fields per condition & hemo

% Build significance and Δ matrices (rows: HbO,HbR; cols: channels)
for ci = 1:numel(conds_keys)
    key   = conds_keys{ci};
    pAll  = [pVals.(key).HbO ; pVals.(key).HbR];
    DAll  = [DVals.(key).HbO ; DVals.(key).HbR];
    nanM  = [NaNVals.(key).HbO ; NaNVals.(key).HbR];

    sigMat.(key)  = zeros(size(pAll));       % 0 = sig, 1 = non-sig
    sigMat.(key)(pAll > alpha) = 1;
    sigMat.(key)(isnan(nanM))  = NaN;

    diffMat.(key) = DAll;
    diffMat.(key)(pAll > alpha) = NaN;
    diffMat.(key)(isnan(nanM))  = NaN;
end

%% ===================== PLOTS =====================
% Learning
plot_condition('Learning','Learning', sigMat, diffMat, hemoLabels, cmap, sigCMap, NonSigColor, lim, ...
    img, xC, yC, sh_x, sh_y, ch_data, Channels, ...
    FrontalCh, FrontalColor, ParietalCh, ParietalColor, TemporalCh, TemporalColor);

% Receptive
plot_condition(rPost,'Receptive Test', sigMat, diffMat, hemoLabels, cmap, sigCMap, NonSigColor, lim, ...
    img, xC, yC, sh_x, sh_y, ch_data, Channels, ...
    FrontalCh, FrontalColor, ParietalCh, ParietalColor, TemporalCh, TemporalColor);

% Productive
plot_condition(pPost,'Productive Test', sigMat, diffMat, hemoLabels, cmap, sigCMap, NonSigColor, lim, ...
    img, xC, yC, sh_x, sh_y, ch_data, Channels, ...
    FrontalCh, FrontalColor, ParietalCh, ParietalColor, TemporalCh, TemporalColor);

%% ===================== HELPERS =====================
function out = iff(cond, a, b), if cond, out=a; else, out=b; end, end

function idx = findCondIdx(name)
map = containers.Map( ...
    {'LearningBaseline','PretestBaseline','PosttestBaseline','Learning', ...
    'ReceptivePosttest','ReceptivePretest','ProductivePosttest','ProductivePretest'}, ...
    num2cell(1:8));
idx = map(name);
end

function plot_condition(key, titleStr, sigMat, diffMat, hemoLabels, cmap, sigCMap, NonSigColor, lim, ...
    img, xC, yC, sh_x, sh_y, ch_data, Channels, ...
    FrontalCh, FrontalColor, ParietalCh, ParietalColor, TemporalCh, TemporalColor)

if key == "Learning"
    fs  = 12;
    pos = [20, 150, 2000, 350];
    figure('Name',titleStr,'NumberTitle','off','Color','w','Position',pos);

    % (a) P-value heatmap
    subplot(2,1,1)
    hP = heatmap(sigMat.(key),'Colormap',sigCMap);
    hP.XLabel           = 'Channels';
    hP.YData            = hemoLabels;
    hP.Title            = '(a)';
    hP.ColorLimits      = [0 0.1];
    hP.MissingDataColor = NonSigColor;
    hP.MissingDataLabel = 'Non-Sig / Faulty';
    hP.CellLabelColor   = 'none';
    hP.FontSize         = fs;

    % (b) ΔSD heatmap
    subplot(2,1,2)
    hD = heatmap(diffMat.(key),'Colormap',cmap);
    hD.XLabel           = 'Channels';
    hD.YData            = hemoLabels;
    hD.Title            = '(b)';
    hD.ColorLimits      = [-lim lim];
    hD.MissingDataColor = NonSigColor;
    hD.MissingDataLabel = 'Non-Sig';
    hD.CellLabelColor   = 'none';
    hD.FontSize         = fs;

else
    fs  = 12;
    pos = [20, 150, 1800, 1000];
    figure('Name',titleStr,'NumberTitle','off','Color','w','Position',pos);

    % (a) P-value heatmap
    subplot(7,2,[1 2])
    hP = heatmap(sigMat.(key),'Colormap',sigCMap);
    hP.XLabel           = 'Channels';
    hP.YData            = hemoLabels;
    hP.Title            = '(a)';
    hP.ColorLimits      = [0 0.1];
    hP.MissingDataColor = NonSigColor;
    hP.MissingDataLabel = 'Non-Sig / Faulty';
    hP.CellLabelColor   = 'none';
    hP.FontSize         = fs;

    % (b) ΔSD heatmap
    subplot(7,2,[5 6])
    hD = heatmap(diffMat.(key),'Colormap',cmap);
    hD.XLabel           = 'Channels';
    hD.YData            = hemoLabels;
    hD.Title            = '(b)';
    hD.ColorLimits      = [-lim lim];
    hD.MissingDataColor = NonSigColor;
    hD.MissingDataLabel = 'Non-Sig';
    hD.CellLabelColor   = 'none';
    hD.FontSize         = fs;

    % (c1–c2) Topographic ΔSD overlays (HbO row=1, HbR row=2)
    for hb = 1:2
        if hb == 1
            c = '(c1) ';
        elseif hb == 2
            c = '(c2) ';
        end
        subplot(7,2,[6+hb, 8+hb, 10+hb, 12+hb]);
        h=imshow(img); set(h,'AlphaData',0.1); hold on;set(gca,'xtick',[],'ytick',[]);
        xlabel([c,hemoLabels{hb}], 'FontSize',15,'FontWeight','bold');

        Drow = diffMat.(key)(hb,:);  % 1×Channels

        for ch = 1:Channels
            val = Drow(ch);
            if isnan(val)
                mfc = NonSigColor;
            else
                t   = (val + lim)/(2*lim);
                idx = max(1, min(size(cmap,1), round(1 + t*(size(cmap,1)-1))));
                mfc = cmap(idx,:);
            end

            chNum = ch_data(ch,3);
            % region-dependent styling
            tmfs = 11;
            if ismember(chNum, FrontalCh)
                edgeC = FrontalColor; lw = 1.5; nfs = tmfs;
            elseif ismember(chNum, ParietalCh)
                edgeC = ParietalColor; lw = 1.5; nfs = tmfs;
            elseif ismember(chNum, TemporalCh)
                edgeC = TemporalColor; lw = 1.5; nfs = tmfs;
            else
                edgeC = 0.8*[1 1 1]; lw = 0.2; nfs = tmfs/2; %mfc = NonSigColor;
            end

            scatter(xC(ch)+sh_x, yC(ch)-sh_y, 225, 'filled', ...
                'MarkerFaceColor',mfc, 'MarkerEdgeColor',edgeC, 'LineWidth',lw);
            text(xC(ch)+sh_x+8, yC(ch)-sh_y, num2str(chNum), ...
                'FontSize', nfs, 'FontWeight','bold', 'Color', edgeC);
        end

        % simple legend
        make_region_legend(FrontalColor, ParietalColor, TemporalColor, fs);
        hold off;
    end
end
end

function make_region_legend(FrontalColor, ParietalColor, TemporalColor, fs)
% draw small legend boxes at fixed normalized positions (top-left)
ax = gca; axpos = ax.Position;
x0 = axpos(1) + 0.01; y0 = axpos(2) + axpos(4) - 0.05; w = 0.015; h = 0.015;
items = {FrontalColor,'Frontal Lobe'; ParietalColor,'Parietal Lobe'; TemporalColor,'Temporal Lobe'};
for i = 1:size(items,1)
    yi = y0 - (i-1)*(h+0.01);
    annotation('rectangle','Units','normalized','Position',[x0 yi w h], ...
        'FaceColor',items{i,1},'EdgeColor',items{i,1});
    annotation('textbox','Units','normalized','Position',[x0+w+0.005 yi+0.0055 0.15 h], ...
        'String',items{i,2},'LineStyle','none','FontSize',fs);
end
end
