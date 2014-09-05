function representation = compute3DMTM(GESTURE, t)
%function [depthMHI, depthMHIs, depthSHI, depthSHIs, AMI, ASI] = compute3DMTM(GESTURE, t)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% %% version 1.0, implementation according to definition 
% num_frames = length(GESTURE);
% 
% %% if paramter t is omitted, default t is the length of the whole gesture sequence
% if nargin < 2
%     t = num_frames;
% end
% 
% ORIGINAL = GESTURE{1};
% %ORIGINAL_IMG = 255 * mat2gray(ORIGINAL);
% 
% %% if t equals 1, MHI is the first frame (pixel values range from 0 to 1)    
% if t == 1
%     depthMHI = mat2gray(ORIGINAL);
%     return;
% end
% 
% %% generate depth images (pixel values range from 0 to 255)
% CURRENT = GESTURE{t};
% CURRENT_IMG = 255 * mat2gray(CURRENT);
% PREVIOUS = GESTURE{t - 1};
% PREVIOUS_IMG = 255 * mat2gray(PREVIOUS);
% 
% % threshold for compute the differences of consecutive frmames
% threshold = 10;
% 
% DIFF_IMG = depthFrameDiff(CURRENT_IMG, PREVIOUS_IMG, threshold);
% 
% depthMHI = DIFF_IMG;
% 
% depthMHI(DIFF_IMG == 1) = num_frames;
% 
% TMP = max(0, computeDepthMHI(GESTURE, t-1) -1);
% depthMHI(DIFF_IMG ~= 1) = TMP(DIFF_IMG ~= 1);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% version 1.1, implementation without iteration
%% value of t
if nargin < 2
    t = length(GESTURE);
end

num_frames = length(GESTURE);

%% frame nomalization 
ORIGINAL_FRAME = GESTURE{1};
ORIGINAL_IMG = mat2gray(ORIGINAL_FRAME);
[~, ORIGINAL_XOZ_IMG, ORIGINAL_YOZ_IMG] = reproject(ORIGINAL_FRAME);

%% a set of MHIs
depthMHIs = cell(t,1);
depthMHIs{1} = ORIGINAL_IMG;

%% a set of SHIs
depthSHIs = cell(t,1);
depthSHIs{1} = ORIGINAL_IMG;

%% a set of XOZ_MHIs and XOZ_SHIs
XOZ_MHIs = cell(t,1);
XOZ_MHIs{1} = ORIGINAL_XOZ_IMG;

XOZ_SHIs = cell(t,1);
XOZ_SHIs{1} = ORIGINAL_XOZ_IMG;

%% a set of YOZ_MHIs and YOZ_SHIs
YOZ_MHIs = cell(t,1);
YOZ_MHIs{1} = ORIGINAL_YOZ_IMG;

YOZ_SHIs = cell(t,1);
YOZ_SHIs{1} = ORIGINAL_YOZ_IMG;

%% AMI and ASI initialization
[row, col] = size(ORIGINAL_FRAME);
AMI = zeros(row, col);
ASI = zeros(row, col);

% AMI and ASI on other two planes
[row_xoz, col_xoz] = size(ORIGINAL_XOZ_IMG);
XOZ_AMI = zeros(row_xoz, col_xoz);
XOZ_ASI = zeros(row_xoz, col_xoz);

[row_yoz, col_yoz] = size(ORIGINAL_YOZ_IMG);
YOZ_AMI = zeros(row_yoz, col_yoz);
YOZ_ASI = zeros(row_yoz, col_yoz);

%% compute the other MHIs and SHIs
xoy_motion_threshold = 10;
xoy_static_threshold = 50;

other_motion_threshold = 10;
other_static_threshold = 50;

for i = 2:t
    %% frame normalization
    CURRENT_FRAME = GESTURE{i};
    [~, CURRENT_XOZ_IMG, CURRENT_YOZ_IMG] = reproject(CURRENT_FRAME);
    
    PREVIOUS_FRAME = GESTURE{i - 1};
    [~, PREVIOUS_XOZ_IMG, PREVIOUS_YOZ_IMG] = reproject(PREVIOUS_FRAME);
    
    CURRENT_IMG = 255 * mat2gray(CURRENT_FRAME);
    PREVIOUS_IMG = 255 * mat2gray(PREVIOUS_FRAME);
    
    %% difference between consecutive frames
    [MOTION_IMG, STATIC_IMG] = depthFrameDiff(CURRENT_IMG, PREVIOUS_IMG, xoy_motion_threshold, xoy_static_threshold);
    [MOTION_XOZ_IMG, STATIC_XOZ_IMG] = depthFrameDiff(CURRENT_XOZ_IMG, PREVIOUS_XOZ_IMG, other_motion_threshold, other_static_threshold);
    [MOTION_YOZ_IMG, STATIC_YOZ_IMG] = depthFrameDiff(CURRENT_YOZ_IMG, PREVIOUS_YOZ_IMG, other_motion_threshold, other_static_threshold);
    
    %% AMI and ASI summation
    % xoy plane
    AMI = AMI + MOTION_IMG;
    ASI = ASI + STATIC_IMG;
    
    % xoz plane
    XOZ_AMI = XOZ_AMI + MOTION_XOZ_IMG;
    XOZ_ASI = XOZ_ASI +STATIC_XOZ_IMG;
    
    % yoz plane
    YOZ_AMI = YOZ_AMI + MOTION_YOZ_IMG;
    YOZ_ASI = YOZ_ASI +STATIC_YOZ_IMG;
    
    %% XOY
    %% compute current MHI according to the definition
    % if D ==1
    depthMHI = MOTION_IMG;
    depthMHI(MOTION_IMG == 1) = num_frames;
    
    % otherwise
    TMP = max(0, depthMHIs{i-1} - 1);
    idx = (MOTION_IMG ~= 1);
    depthMHI(idx) = TMP(idx);
    
    depthMHIs{i} = depthMHI;
    
    %% compute current SHI
    % if D ==1    
    depthSHI = STATIC_IMG;
    depthSHI(STATIC_IMG == 1) = num_frames;
    
    % otherwise
    TMP = max(0, depthSHIs{i-1} - 1);
    idx = (STATIC_IMG ~= 1);
    depthSHI(idx) = TMP(idx);
    
    depthSHIs{i} = depthSHI;
    
    %% XOZ
    %% compute current MHI according to the definition
    % if D ==1
    XOZ_MHI = MOTION_XOZ_IMG;
    XOZ_MHI(MOTION_XOZ_IMG == 1) = num_frames;
    
    % otherwise
    TMP = max(0, XOZ_MHIs{i-1} - 1);
    idx = (MOTION_XOZ_IMG ~= 1);
    XOZ_MHI(idx) = TMP(idx);
    
    XOZ_MHIs{i} = XOZ_MHI;
    
    %% compute current SHI
    % if D ==1    
    XOZ_SHI = STATIC_XOZ_IMG;
    XOZ_SHI(STATIC_XOZ_IMG == 1) = num_frames;
    
    % otherwise
    TMP = max(0, XOZ_SHIs{i-1} - 1);
    idx = (STATIC_XOZ_IMG ~= 1);
    XOZ_SHI(idx) = TMP(idx);
    
    XOZ_SHIs{i} = XOZ_SHI;
    
    %% YOZ
    %% compute current MHI according to the definition
    % if D ==1
    YOZ_MHI = MOTION_YOZ_IMG;
    YOZ_MHI(MOTION_YOZ_IMG == 1) = num_frames;
    
    % otherwise
    TMP = max(0, YOZ_MHIs{i-1} - 1);
    idx = (MOTION_YOZ_IMG ~= 1);
    YOZ_MHI(idx) = TMP(idx);
    
    YOZ_MHIs{i} = YOZ_MHI;
    
    %% compute current SHI
    % if D ==1    
    YOZ_SHI = STATIC_YOZ_IMG;
    YOZ_SHI(STATIC_YOZ_IMG == 1) = num_frames;
    
    % otherwise
    TMP = max(0, YOZ_SHIs{i-1} - 1);
    idx = (STATIC_YOZ_IMG ~= 1);
    YOZ_SHI(idx) = TMP(idx);
    
    YOZ_SHIs{i} = YOZ_SHI;
end

%% process of the templates
% xoy plane
depthMHI = depthMHIs{t};
depthSHI = depthSHIs{t};
AMI = AMI / t;
ASI = ASI / t;

% xoz plane
XOZ_MHI = XOZ_MHIs{t};
XOZ_SHI = XOZ_SHIs{t};
XOZ_AMI = XOZ_AMI / t;
XOZ_ASI = XOZ_ASI / t;

% yoz plane
YOZ_MHI = YOZ_MHIs{t};
YOZ_SHI = YOZ_SHIs{t};
YOZ_AMI = YOZ_AMI / t;
YOZ_ASI = YOZ_ASI / t;

representation = struct;

%% scale all the elements to [0, 255]
% xoy plane
representation.XOY_MHI = uint8(255 * mat2gray(depthMHI));
representation.XOY_SHI = uint8(255 * mat2gray(depthSHI));
representation.XOY_AMI = uint8(255 * mat2gray(AMI));
representation.XOY_ASI = uint8(255 * mat2gray(ASI));

% xoz plane
representation.XOZ_MHI = uint8(255 * mat2gray(XOZ_MHI));
representation.XOZ_SHI = uint8(255 * mat2gray(XOZ_SHI));
representation.XOZ_AMI = uint8(255 * mat2gray(XOZ_AMI));
representation.XOZ_ASI = uint8(255 * mat2gray(XOZ_ASI));

% yoz plane
representation.YOZ_MHI = uint8(255 * mat2gray(YOZ_MHI));
representation.YOZ_SHI = uint8(255 * mat2gray(YOZ_SHI));
representation.YOZ_AMI = uint8(255 * mat2gray(YOZ_AMI));
representation.YOZ_ASI = uint8(255 * mat2gray(YOZ_ASI));

end