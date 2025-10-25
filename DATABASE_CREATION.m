clc;clear;close all 
% Noble C. Amadi
pwd = uigetdir();
%% LOAD DATA
% Automatically set the folder paths
TradFolderPath = fullfile(pwd, 'Traditional');
VRFolderPath = fullfile(pwd, 'VR');

% Load the Subfolders
TradSubfolders = dir(fullfile(TradFolderPath, 'P*'));
VRSubfolders = dir(fullfile(VRFolderPath, 'P*'));


%% GENERATE DATABASE 1
[Trad_Day1_data] = preprocessNIRSData(TradSubfolders, TradFolderPath);
[VR_Day1_data] = preprocessNIRSData(VRSubfolders, VRFolderPath);

% Extract Productive & Receptive Tests
[Trad_Day1_data,VR_Day1_data] = Extract_Tests(Trad_Day1_data, VR_Day1_data);

% Create a structure to hold all the data
DB1 = struct;
DB1.Trad_Day1_data = Trad_Day1_data;
%DB1.Trad_Day2_data = Trad_Day2_data;
DB1.VR_Day1_data = VR_Day1_data;
%DB1.VR_Day2_data = VR_Day2_data;

% Save the structure to a .mat file
save('DB1.mat', 'DB1');


%% GENEARATE DATABASE 2
DB2 = createDatabase(Trad_Day1_data, VR_Day1_data);
save('DB2.mat', '-struct', 'DB2');
