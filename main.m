%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bin Liang (bin.liang.ty@gmail.com)
% Charles Sturt University
% Created:	September 2013
% Modified:	November 2013
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Preparing for running
% clear variables
clear all; close all; clc;

% add to path
this_dir = pwd;
addpath(genpath(this_dir));

% set dataset path
data_path = 'D:\\Research\\Projects\\Dataset\\MSR Action3D\\dataset\\';

% specify the paths to training and  test data
test_subsets = {'test_one\\', 'test_two\\', 'cross_subject_test\\'};
action_subsets = {'AS1\\', 'AS2\\', 'AS3\\'};

% training_data_dir = [data_path test_subsets{1} 'training\\' action_subsets{1}];
% test_data_dir = [data_path test_subsets{1} 'test\\' action_subsets{1}];

performed_dataset_path = [data_path test_subsets{3}, action_subsets{3}];
training_data_dir = [performed_dataset_path, 'training\\'];
test_data_dir = [performed_dataset_path, 'test\\'];

%% preparation for HOG feature extraction
nwin_x = 2;
nwin_y = 2;
num_bins = 9;
num_templates = 6;

hog_param = struct;
hog_param.nwin_x = nwin_x;
hog_param.nwin_y = nwin_y;
hog_param.num_bins = num_bins;

feature_dimensions = ( (nwin_x * nwin_y * num_bins) + ... 
                       ((nwin_x^2) * (nwin_y^2) * num_bins) + ...
                       ((nwin_x^3) * (nwin_y^3) * num_bins)) * num_templates;


%% Load training data
d = dir(training_data_dir);
isfile = [d(:).isdir] ~= 1;
files = {d(isfile).name}';

TR_Gestures = struct;
train_label = zeros(length(files), 1);
train_data = zeros(length(files), feature_dimensions);

%% Feature extraction for training dataset
fprintf('Loading training data:\n');
for i=1:length(files)
    fprintf([files{i}, '...']);
    
    % load data as a video sequence
    SEQUENCE = readDepthDataset([training_data_dir files{i}]);  % frame scale: [1 552]        

    % gesture representation using 3D-MTM
    representation = compute3DMTM(SEQUENCE);
   
    % feature extraction using HOG (fast HOG)
    features = feature_extraction(representation, hog_param);
    
    % additional information
    name = files{i};
    id = name(2:3);

    % save data
    TR_Gestures(i).Features = features;
    TR_Gestures(i).Name = name;
    TR_Gestures(i).Id = str2double(id);
    
    % save label & data
    train_label(i, 1) = str2double(id);
    train_data(i, :) = features;
    
    fprintf('done.\n');        
end

% save training data as .mat file
% save('TR_Gestures.mat', 'TR_Gestures');

% format to SVM file
% TR_SVM_file = 'TR_Gestures.svm';
% mat2SVMfile(TR_Gestures, TR_SVM_file);

%pause;

%% Load test data
d = dir(test_data_dir);
isfile = [d(:).isdir] ~= 1;
files = {d(isfile).name}';

TE_Gestures = struct;

test_label = zeros(length(files), 1);
test_data = zeros(length(files), feature_dimensions);

%% Feature extraction for test dataset
fprintf('Loading test data:\n');
for i=1:length(files)
    fprintf([files{i}, '...']);
    
    % load data as a video sequence
    SEQUENCE = readDepthDataset([test_data_dir files{i}]);    

    % gesture representation using 3D-MTM
    representation = compute3DMTM(SEQUENCE);   
    features = feature_extraction(representation, hog_param);

    % additional information
    name = files{i};
    id = name(2:3);

    % save data
    TE_Gestures(i).Features = features;
    TE_Gestures(i).Name = name;
    TE_Gestures(i).Id = str2double(id);

    % save label & data
    test_label(i, 1) = str2double(id);
    test_data(i, :) = features;
    
    fprintf('done.\n');
end

% save test data as .mat file
% save('TE_Gestures.mat', 'TE_Gestures');

% format to SVM file
% TE_SVM_file = 'TE_Gestures.svm';
% mat2SVMfile(TE_Gestures, TE_SVM_file);

%pause;

%% recognition using SVM
% scale
[train_data_scale, test_data_scale] = scaleForSVM(train_data, test_data, -1, 1);

% pca
[train_data_pca, test_data_pca] = pcaForSVM(train_data_scale, test_data_scale, 95);

[bestacc,bestc,bestg] = SVMcgForClass(train_label, train_data_pca, -5, 15, -15, 3, 5, 2, 2);
model = svmtrain(train_label, train_data_pca, ['-c ', num2str(bestc), ' -g ', num2str(bestg)]);
[predict, accuracy] = svmpredict(test_label, test_data_pca, model);
pause(0.5);beep; pause(0.5);beep; pause(0.5);beep;