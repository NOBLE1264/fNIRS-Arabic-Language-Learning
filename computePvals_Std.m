function [DValStruct, pValStruct] = computePvals_Std(NormDATA)
%% 1) Define parameters
nT        = 6;            % Traditional Group
nV        = 6;            % VR Group
Channels  = 50;           % Number of channels
hemoTypes = {'HbO','HbR'};

%% 2) Pre-allocate output structs
pValStruct = struct('HbO', NaN(1,Channels), 'HbR', NaN(1,Channels));
DValStruct = struct('HbO', NaN(1,Channels), 'HbR', NaN(1,Channels));

%% 3) Loop over hemodynamic types and channels
for h = 1:2
    measure = hemoTypes{h};
    for c = 1:Channels
        % --- gather SDs for each group ---
        stdTrad = zeros(nT,1);
        stdVR   = zeros(nV,1);
        for p = 1:nT
            stdTrad(p) = NormDATA.Trad.(measure){p,c};
        end
        for p = 1:nV
            stdVR(p)   = NormDATA.VR  .(measure){p,c};
        end

        % ------- Normality Check -------- %
        [hTrad,~,~] = swtest(stdTrad, 0.05);
        [hVR,~,~] = swtest(stdVR, 0.05);

        % stdVR = mean(stdVR(~isnan(stdVR)));
        % stdTrad = mean(stdTrad(~isnan(stdTrad)));

        if hTrad || hVR == 1
            % --- run the Mann–Whitney U test ---
            [pVal, DVal] = ranksumm(stdTrad, stdVR);
        elseif hTrad && hVR == 0
            % --- run the t test ---
            [pVal, DVal] = ttest(stdTrad, stdVR);
        end

        % --- store ---
        pValStruct.(measure)(c) = pVal;
        DValStruct.(measure)(c) = DVal;
    end
end
end