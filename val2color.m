function colorRGB = val2color(value, maxAbs)
% VAL2COLOR  Maps 'value' to a blue-white-red scale around 0:
%   value < 0 => more blue
%   value = 0 => white
%   value > 0 => more red
%   'maxAbs' is the positive range limit we use for scaling.

    if isnan(value)
        % If no valid value was passed
        colorRGB = [0, 0, 0];  % black by default
        return
    end

    % Clamp 'value' to [-maxAbs, maxAbs]
    value = max( min(value, maxAbs), -maxAbs ); 
    % Normalize to [0..1]
    %   where 0 corresponds to -maxAbs (full blue),
    %         0.5 to 0 (white),
    %         1.0 to +maxAbs (full red)
    x = (value + maxAbs) / (2*maxAbs);

    % Interpolate between [0,0,1] (blue), [1,1,1] (white), [1,0,0] (red)
    if x < 0.5
        % Between blue (0..0.5) and white
        ratio = x / 0.5; 
        colorRGB = (1 - ratio)*[0, 0, 1] + ratio*[1, 1, 1];
    else
        % Between white (0.5..1) and red
        ratio = (x - 0.5) / 0.5;
        colorRGB = (1 - ratio)*[1, 1, 1] + ratio*[1, 0, 0];
    end
end
