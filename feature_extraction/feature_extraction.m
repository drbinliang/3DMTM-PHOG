function features = feature_extraction(representation, hog_param)
%FEATURE_EXTRACTION Summary of this function goes here
%   feature extraction, return row feature vector

%% decomposition of representation
% xoy plane
XOY_MHI = representation.XOY_MHI;
XOY_SHI = representation.XOY_SHI;
XOY_AMI = representation.XOY_AMI;
XOY_ASI = representation.XOY_ASI;

% xoz plane
XOZ_MHI = representation.XOZ_MHI;
XOZ_SHI = representation.XOZ_SHI;
XOZ_AMI = representation.XOZ_AMI;
XOZ_ASI = representation.XOZ_ASI;

% yoz plane
YOZ_MHI = representation.YOZ_MHI;
YOZ_SHI = representation.YOZ_SHI;
YOZ_AMI = representation.YOZ_AMI;
YOZ_ASI = representation.YOZ_ASI;

%% 2 * 2 HOG Feature extraction
% xoy plane
vector_1 = HOG(XOY_MHI, hog_param);
vector_2 = HOG(XOY_SHI, hog_param);
vector_3 = HOG(XOY_AMI, hog_param);
vector_4 = HOG(XOY_ASI, hog_param);

% xoz pane
vector_5 = HOG(XOZ_MHI, hog_param);
% vector_6 = HOG(XOZ_SHI, hog_param);
% vector_7 = HOG(XOZ_AMI, hog_param);
% vector_8 = HOG(XOZ_ASI, hog_param);

% yoz plane
vector_6 = HOG(YOZ_MHI, hog_param);
% vector_10 = HOG(YOZ_SHI, hog_param);
% vector_11 = HOG(YOZ_AMI, hog_param);
% vector_12 = HOG(YOZ_ASI, hog_param);

%% 4 * 4 HOG Feature extraction
hog_param.nwin_x = 2^2;
hog_param.nwin_y = 2^2;

% xoy plane
vector_7 = HOG(XOY_MHI, hog_param);
vector_8 = HOG(XOY_SHI, hog_param);
vector_9 = HOG(XOY_AMI, hog_param);
vector_10 = HOG(XOY_ASI, hog_param);

% xoz pane
vector_11 = HOG(XOZ_MHI, hog_param);
% vector_6 = HOG(XOZ_SHI, hog_param);
% vector_7 = HOG(XOZ_AMI, hog_param);
% vector_8 = HOG(XOZ_ASI, hog_param);

% yoz plane
vector_12 = HOG(YOZ_MHI, hog_param);

%% 8 * 8 HOG Feature extraction
hog_param.nwin_x = 2^3;
hog_param.nwin_y = 2^3;

% xoy plane
vector_13 = HOG(XOY_MHI, hog_param);
vector_14 = HOG(XOY_SHI, hog_param);
vector_15 = HOG(XOY_AMI, hog_param);
vector_16 = HOG(XOY_ASI, hog_param);

% xoz pane
vector_17 = HOG(XOZ_MHI, hog_param);
% vector_6 = HOG(XOZ_SHI, hog_param);
% vector_7 = HOG(XOZ_AMI, hog_param);
% vector_8 = HOG(XOZ_ASI, hog_param);

% yoz plane
vector_18 = HOG(YOZ_MHI, hog_param);

% % % original 6 templates
% % features = [vector_1' vector_2' vector_3' ...
% %             vector_4' vector_5' vector_9'];
 
% % all templates
% features = [vector_1' vector_2' vector_3' vector_4' ...
%             vector_5' vector_6' vector_7' vector_8' ...
%             vector_9' vector_10' vector_11' vector_12'];        

% features with window number 4 * 4
features_2_2 = [vector_1' vector_2' vector_3' vector_4' vector_5' vector_6'];
features_4_4 = [vector_7' vector_8' vector_9' vector_10' vector_11' vector_12'];
features_8_8 = [vector_13' vector_14' vector_15' vector_16' vector_17' vector_18'];


features = [features_2_2 features_4_4 features_8_8];

end

