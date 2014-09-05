function [MOTION_IMG, STATIC_IMG] = depthFrameDiff(CURRENT_IMG, PREVIOUS_IMG, motion_threshold, static_threshold)

% if nargin < 3
%     threshold = 10;
% end

DIFF = abs(CURRENT_IMG - PREVIOUS_IMG);
MOTION_IMG = DIFF;
MOTION_IMG(DIFF >= motion_threshold) = 1;
MOTION_IMG(DIFF < motion_threshold) = 0;

% STATIC_IMG = DIFF;
% STATIC_IMG(DIFF < static_threshold) = 1;
% STATIC_IMG(DIFF >= static_threshold) = 0;
STATIC_REGION = CURRENT_IMG - DIFF;
STATIC_IMG = STATIC_REGION;
STATIC_IMG(STATIC_REGION > static_threshold) = 1;
STATIC_IMG(STATIC_REGION <= static_threshold) = 0;
end