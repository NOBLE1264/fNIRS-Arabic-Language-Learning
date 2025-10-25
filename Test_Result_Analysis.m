%% Language Learning Study — Excel → Table + Statistics + Boxplots
clc; clear; close all;

%% 1) Load data
filename = 'Test Results.xlsx';  
raw      = readcell(filename);
data     = raw(3:end,:);

group      = string(data(:,1));      % 'VR' or 'Traditional'
Rec_Pre    = cell2mat(data(:,2));
Rec_Post   = cell2mat(data(:,3));
Prod_Pre   = cell2mat(data(:,4));
Prod_Post  = cell2mat(data(:,5));

isVR = group == "VR";
isTr = group == "Traditional";
nVR  = sum(isVR);
nTr  = sum(isTr);

%% 2) Compute descriptive stats + improvements
% Receptive Test
mRecPre   = [ mean(Rec_Pre(isVR));   mean(Rec_Pre(isTr)) ];
sdRecPre  = [ std( Rec_Pre(isVR));   std( Rec_Pre(isTr)) ];
mRecPost  = [ mean(Rec_Post(isVR));  mean(Rec_Post(isTr)) ];
sdRecPost = [ std( Rec_Post(isVR));  std( Rec_Post(isTr)) ];
impRecVR  = Rec_Post(isVR)  - Rec_Pre(isVR);
impRecTr  = Rec_Post(isTr)  - Rec_Pre(isTr);
mRecImp   = [ mean(impRecVR);       mean(impRecTr) ];
sdRecImp  = [ std( impRecVR);       std( impRecTr) ];

% Productive Test
mProdPre   = [ mean(Prod_Pre(isVR));   mean(Prod_Pre(isTr)) ];
sdProdPre  = [ std( Prod_Pre(isVR));   std( Prod_Pre(isTr)) ];
mProdPost  = [ mean(Prod_Post(isVR));  mean(Prod_Post(isTr)) ];
sdProdPost = [ std( Prod_Post(isVR));  std( Prod_Post(isTr)) ];
impProdVR  = Prod_Post(isVR) - Prod_Pre(isVR);
impProdTr  = Prod_Post(isTr) - Prod_Pre(isTr);
mProdImp   = [ mean(impProdVR);       mean(impProdTr) ];
sdProdImp  = [ std( impProdVR);       std( impProdTr) ];

%% 3) Normality test & between‐group comparison on Posttests
% — Receptive Test —
[sw_p_rec, sw_h_rec] = swtest(impRecVR);
if sw_h_rec == 0
    [~, p_rec] = ttest(impRecVR, impRecTr);
    testRec    = 't-test';
else
    p_rec      = ranksum(impRecVR, impRecTr);
    testRec    = 'rank-sum';
end

% — Productive Test —
[sw_p_prod, sw_h_prod] = swtest(impProdVR);
if sw_h_prod == 0
    [~, p_prod] = ttest(impProdVR, impProdTr);
    testProd    = 't-test';
else
    p_prod      = ranksum(impProdVR, impProdTr);
    testProd    = 'rank-sum';
end


%% 4) Box‐and‐Whisker Plots (fixed X axis)
figure('Color','w','Position',[200 200 1600 800]);
fs = 15;
% Positions
xPos = [0.5, 1.5, 3.5, 4.5];
xlabelPos = [ 1 , 4];
textX = 0.5; % X position for the text
textY = 13;  % Y position for the text

% --- Receptive Test subplot ---
subplot(1,2,1); hold on;
boxchart(xPos(1)*ones(nVR,1), Rec_Pre(isVR),  'BoxFaceColor',[0 .7 .1]);
boxchart(xPos(2)*ones(nTr,1), Rec_Pre(isTr),  'BoxFaceColor',[0 .2 .8]);
boxchart(xPos(3)*ones(nVR,1), Rec_Post(isVR), 'BoxFaceColor',[0 .7 .1]);
boxchart(xPos(4)*ones(nTr,1), Rec_Post(isTr), 'BoxFaceColor',[0 .2 .8]);
set(gca,'XTick', xlabelPos,'XTickLabel', {'Pretest','Posttest'}, fontsize=fs);
xlim([0 5]);     
ylim([0 15]); 
ylabel('Scores');
title('Receptive Test');
legend({'VR','Trad'},'Location','NorthWest');

% --- Productive Test subplot ---
subplot(1,2,2); hold on;
boxchart(xPos(1)*ones(nVR,1), Prod_Pre(isVR),  'BoxFaceColor',[0 .7 .1]);
boxchart(xPos(2)*ones(nTr,1), Prod_Pre(isTr),  'BoxFaceColor',[0 .2 .8]);
boxchart(xPos(3)*ones(nVR,1), Prod_Post(isVR), 'BoxFaceColor',[0 .7 .1]);
boxchart(xPos(4)*ones(nTr,1), Prod_Post(isTr), 'BoxFaceColor',[0 .2 .8]);
set(gca,'XTick', xlabelPos,'XTickLabel', {'Pretest','Posttest'}, fontsize=fs);
xlim([0 5]);
ylim([0 15]);
ylabel('Scores');
title('Productive Test');
legend({'VR','Trad'},'Location','NorthWest');

