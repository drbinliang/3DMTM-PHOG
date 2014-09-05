function SEQUENCE = readDepthDataset(file)

%% read file
fid = fopen(file);
num_frames = fread(fid, 1 ,'ubit32');
n_cols = fread(fid, 1 ,'ubit32');
n_rows = fread(fid, 1 ,'ubit32');

%% construct sequence
%SEQUENCE = zeros(num_frames, n_cols * n_rows); % each row represents a frame

SEQUENCE = cell(num_frames, 1);
FRAME = zeros(n_rows,n_cols);


%% read frame
for f = 1:num_frames
    for i = 1:n_rows
        tempRow = fread(fid, n_cols, 'ubit32');
        for j = 1:n_cols
            FRAME(i,j) = tempRow(j);
        end
    end
    
    %% save to sequence
    FRAME_IMG = FRAME;
    %SEQUENCE(f, :) = FRAME_IMG(:);
    SEQUENCE{f} = FRAME_IMG;
    
     %figure, imshow(SEQUENCE{f}, [], 'border', 'tight');
end

fclose(fid);

end