

%% Function for fNIRS data pre-processing
% Noble C. Amadi
function [Day1_data, Day2_data] = preprocessNIRSData(Subfolders, FolderPath)
% Initialize data cell arrays
Day1_data = cell(numel(Subfolders), 6);
%Day2_data = cell(numel(Subfolders), 6);

% Loop through subfolders for data
for a = 1:numel(Subfolders)
    subfolderName = Subfolders(a).name;

    % List files in "Day 1" folder
    day1Files = dir(fullfile(FolderPath, subfolderName, 'Day 1', '*.nirs'));
    % List files in "Day 2" folder
    %day2Files = dir(fullfile(FolderPath, subfolderName, 'Day 2', '*.nirs'));

    % Loop through the files for each day
    for b = 1:numel(day1Files)
        % Load the data for Day 1 and Day 2
        dataDay1 = nirs.io.loadDotNirs(fullfile(FolderPath, subfolderName, 'Day 1', day1Files(b).name));
        %dataDay2 = nirs.io.loadDotNirs(fullfile(FolderPath, subfolderName, 'Day 2', day2Files(b).name));

        %% DATA PRE-PROCESSING
        %% converting to Optical density
        j = nirs.modules.OpticalDensity();
        %% Bandpass Filter
        j = eeg.modules.BandPassFilter(j);
        j.highpass = 0.2;
        j.lowpass = 1;
        j.do_downsample= 0;
        %% Temporal Derivative Distribution Repair (TDDR) method
        j = nirs.modules.TDDR(j);
        %% Convert to modified BL
        j = nirs.modules.BeerLambertLaw(j);
        %% OUTPUT
        hb_Day1 = j.run(dataDay1);
        %hb_Day2 = j.run(dataDay2);
        Day1_data{a, b} = hb_Day1.data;    
        %Day2_data{a, b} = hb_Day2.data;
        
        %% QUALITY CHECK
        T = 500;
        % Store the data or NaN if any value is outside the threshold
        % (Day 1)
        for col = 1:size(Day1_data{a, b}, 2)
            if any(Day1_data{a, b}(:, col) > T | Day1_data{a, b}(:, col) < -T)
                Day1_data{a, b}(:, col) = NaN;
            end
        end
        % Store the data or NaN if any value is outside the threshold
        % (Day 2)
        % for col = 1:size(Day2_data{a, b}, 2)
        %     if any(Day2_data{a, b}(:, col) > T | Day2_data{a, b}(:, col) < -T)
        %         Day2_data{a, b}(:, col) = NaN;
        %     end
        % end
    end
end; clc
end
