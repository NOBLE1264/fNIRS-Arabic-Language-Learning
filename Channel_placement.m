clc;clear;close all
% Load the data from the file
data = load('ChannelCoor.txt');
% Read and display the brain image
img = imread('Brain.jpg');
h=imshow(img);
hold on;

% Reduce the transparency of the image
set(h, 'AlphaData', 0.3);  % Set transparency to 50% 

% Get the size of the image (height and width)
img_size = size(img);

% Extract source, detector, and channel number from your data
source = data(:, 1);      % X-coordinates
detector = data(:, 2);    % Y-coordinates
channel = data(:, 3);     % Channel number

% Scale the source and detector coordinates to fit the image size
xCoordinates = source * img_size(2) / 16;    % Scale to image width (15 max in source data)
yCoordinates = detector * img_size(1) / 14;  % Scale to image height

% Flip the detector coordinates (to match the image coordinate system)
yCoordinates_flipped = img_size(1) - yCoordinates;

% Plot the source-detector pairings with black color
scatter(xCoordinates, yCoordinates_flipped, 100, 'r', 'filled');

% Add channel numbers as text labels on the plot
text(xCoordinates + 0.1 * img_size(2) / 15, yCoordinates_flipped, num2str(channel), 'FontSize', 15);

% Set axis limits based on the image size to fit everything properly
axis([0 img_size(2) 0 img_size(1)]);
