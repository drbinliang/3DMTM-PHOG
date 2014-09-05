function [XOY_IMG, XOZ_IMG, YOZ_IMG, XOZ_BIN_IMG, YOZ_BIN_IMG] = reproject(IN_XOY_IMG)
%REPROJECT Summary of this function goes here
%   Detailed explanation goes here
% output: XOY_IMG, XOZ_IMG, YOZ_IMG pixel values range from 0 to 255

%% scale XOY_IMG
IN_XOY_IMG = uint8(255 * mat2gray(IN_XOY_IMG));
[y_len, x_len] = size(IN_XOY_IMG); % [row, col]
z_len = 256;

%% coordinates generation
num_elements = y_len * x_len;

% coordinates mapping
COR_MAP = zeros(num_elements, 3);

COR_X = COR_MAP(:, 1);
COR_Y = COR_MAP(:, 2);
COR_Z = COR_MAP(:, 3);

% generate x and y coordinates
for i=1:x_len
    start_idx = 1 + (i-1) * y_len;
    end_idx = start_idx + y_len -1;
    
    COR_X(start_idx:end_idx) = ones(y_len, 1) * i;    
    COR_Y(start_idx:end_idx) = [1:y_len]';
end

COR_Z = IN_XOY_IMG(:);

COR_MAP(:, 1) = COR_X;
COR_MAP(:, 2) = COR_Y;
COR_MAP(:, 3) = COR_Z;

%%
idx = COR_MAP(:,3) ~= 0;
SELECTED_COR_MAP = COR_MAP(idx, :);

% %% test XOY image
% T_XOY = zeros(y_len, x_len);
% 
% for i=1:length(SELECTED_COR_MAP)
%     T_XOY(SELECTED_COR_MAP(i,2), SELECTED_COR_MAP(i,1)) = SELECTED_COR_MAP(i,3);
% end


%% XOZ and YOZ image
XOZ_IMG = zeros(z_len,x_len);
YOZ_IMG = zeros(y_len, z_len);

%SELECTED_COR_MAP(:, 3) = SELECTED_COR_MAP(:, 3) - z_len;

for i=1:length(SELECTED_COR_MAP)    
    XOZ_IMG(SELECTED_COR_MAP(i,3), SELECTED_COR_MAP(i,1)) = XOZ_IMG(SELECTED_COR_MAP(i,3), SELECTED_COR_MAP(i,1)) + 1;
    YOZ_IMG(SELECTED_COR_MAP(i,2), SELECTED_COR_MAP(i,3)) = YOZ_IMG(SELECTED_COR_MAP(i,2), SELECTED_COR_MAP(i,3)) + 1;
end

XOZ_IMG = flipdim(XOZ_IMG,1);
%% Scale XOY, XOZ and YOZ image to [0 255]
% XOY_IMG = mat2gray(IN_XOY_IMG);
% XOZ_IMG = mat2gray(XOZ_IMG);
% YOZ_IMG = mat2gray(YOZ_IMG);

% XOZ_IMG = XOZ_IMG(1:0.5 * z_len, :);
% YOZ_IMG = YOZ_IMG(:, 0.5 * z_len:z_len);

% H = fspecial('gaussian', [3 3], 1);
% XOZ_IMG = imfilter(XOZ_IMG, H, 'replicate');
% YOZ_IMG = imfilter(YOZ_IMG, H, 'replicate');

XOY_IMG = IN_XOY_IMG;
XOZ_IMG = 255 * mat2gray(XOZ_IMG);
YOZ_IMG = 255 * mat2gray(YOZ_IMG);

XOZ_BIN_IMG = XOZ_IMG;
XOZ_BIN_IMG(XOZ_IMG > 0) = 1;

YOZ_BIN_IMG = YOZ_IMG;
YOZ_BIN_IMG(YOZ_IMG > 0) = 1;

end

