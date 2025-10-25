%% Function to calculate Features
% Noble C. Amadi
function [Hb_Data, Histogram, Freq_S, Mean, Std, vars] = calculateFeatures(hb_data, channel_index)
% Extract data for specific channel
channel_data = hb_data(:, channel_index*2-1:channel_index*2);
channel_data(any(isnan(channel_data), 2), :) = NaN;


%% Obtain HbO and HbR Data
Hb_Data = channel_data';

%% Compute the intensity histogram
HbO_chan = channel_data(:,1); % Hbo Data
HbR_chan = channel_data(:,2); % HbR Data
% Calculate the number of bins
bw = 5; % Define bin width
T = 250; % Threshold value

% Histogram for the current channel
histogram_HbO = histcounts(HbO_chan(:), 'BinWidth', bw, 'BinLimits', [-T, T], 'Normalization', 'probability');
histogram_HbR = histcounts(HbR_chan(:), 'BinWidth', bw, 'BinLimits', [-T, T], 'Normalization', 'probability');
Histogram = [histogram_HbO;histogram_HbR];
if mean(Histogram(1, :)) == 0 && mean(Histogram(2, :)) == 0
    Histogram(:) = NaN;
end

%% Compute the frequency spectrum
%--- Parameters
Fs = 3.9063;              % Sampling frequency (Hz)
fmin = 0.2;               % Minimum frequency (Hz)
fmax = 0.6;                 % Maximum frequency (Hz)
df   = 0.01;              % Frequency resolution (Hz)
newf = fmin:df:fmax;      % Frequency vector for interpolation

%--- Get data dimensions
L = size(channel_data, 1);         % Number of time samples
nChannels = size(channel_data, 2);   % Number of channels 
Freq_S = zeros(nChannels, length(newf));  % Preallocate output matrix

%--- Precompute the FFT frequency vector and the Hanning window
f_data = Fs * (0:(L/2)) / L;   % Frequency vector up to Nyquist frequency
win = hanning(L);              % Hanning window

%--- Process each channel
for ch = 1:nChannels
    % Apply the Hanning window
    winData = channel_data(:,ch).* win;

    % Compute FFT and normalize
    X = fft(winData);
    X = abs(X / L);

    % Extract the single-sided spectrum (0 to Nyquist)
    P = X(1:floor(L/2)+1);

    % Calculate power spectrum (magnitude squared)
    P = abs(P).^2;

    % Double non-DC and non-Nyquist components
    P(2:end-1) = 2 * P(2:end-1);

    % Interpolate the spectrum over the new frequency vector
    specInterp = interp1(f_data, P, newf, 'linear', NaN);

    % Store the result (each row corresponds to a channel)
    Freq_S(ch, :) = specInterp;
end


% channel_data = hanning(length(channel_data)).*channel_data; % Hanning window
% freq_S = abs(fft(channel_data));

%% Compute the Mean
Mean = mean(channel_data);

%% Compute the Standard deviation
Std = std(channel_data);

%% USEFUL VARIABLES
vars.Fs = Fs;
vars.fmin = fmin;
vars.fmax = fmax;
vars.df = df;
vars.newf = newf;

end

