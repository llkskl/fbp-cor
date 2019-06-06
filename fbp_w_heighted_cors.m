% MIT License
% 
% Copyright (c) 2019 Olli Koskela
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%% Read the projection data
% input path
path = 'E:\acquisitions\';
% output path
outdir = 'test';
% read, arguments (input path, filename format in sprintf code, num of
% images, scale output size for square images), last argument can be used
% to decrease memory consumption
projs = ReadResizeOPTImages(path,'file(%i).tiff',400,1024);
% print the command console
fprintf('\nProjections read: %s\n',outdir);

%% Down-sample for reconstructing phase, if desired, make sinograms
% it may desired to keep the original projections in the memory but compute
% with down-sampled ones, hence another downsampling here
f = waitbar(0,'Please wait...');
down_sample = 1024;
small_projs = imresize3(projs, [down_sample down_sample 400]);
waitbar(0.75 ,f);
% make the sinograms and save the projection angles
sinos = permute(small_projs,[2 3 1]);
thetas = 0.9:0.9:360;
res_sinos = sinos;
clear sinos
% close waitbar
waitbar(1 ,f);
close(f);
fprintf('Sinograms ready.\n');

%% look only a spesific height h
% h is normally 1 and the projection height
h = 1024;
% the offset range, widen if necessary
range = -50:50;

% allocate and pick the correct sinogram
slices = zeros(size(res_sinos,3),size(res_sinos,3),numel(range));
slicesino = res_sinos(:,:,h);
% compute
f = waitbar(0,'Please wait...');
for i = 1:numel(range)
    % if GPU is available, comment/uncomment here
    % S = gpuArray(slicesino);
    S = slicesino;
    % /GPU
    S = circshift(S,floor(range(i)),1);
    rec = iradon(S,thetas,'hann',size(res_sinos,1));
    % if GPU is available, comment/uncomment here
    % slices(:,:,i) = gather(rec);
    slices(:,:,i) = rec;
    % /GPU
    waitbar(i/numel(range) ,f);
end
close(f);
% show the cor-offset reconstructions
implay(mat2gray(slices,[min(slices(:)) max(slices(:))/2]))

%% Reconstructions
% correct cor offset
cor_top = -43;
cor_bottom = -42;

% interpolate linearly the cor offset between top and bottom
cors = linspace(cor_top,cor_bottom,size(res_sinos,3));
% allocate
fixed_sinos = zeros(size(res_sinos));
recs = zeros(size(res_sinos,3),size(res_sinos,3),size(res_sinos,3));
% reconstruct
f = waitbar(0,'Please wait...');
for i = 1:size(res_sinos,3)
    % if GPU is available, comment/uncomment here
    % S = gpuArray(res_sinos(:,:,i));
    S = res_sinos(:,:,i);
    % /GPU
    S = circshift(S,floor(cors(i)),1);
    rec = iradon(S,thetas,'hann',size(res_sinos,1));
    fixed_sinos(:,:,i) = gather(S);
    % if GPU is available, comment/uncomment here
    % recs(:,:,i) = gather(rec);
    recs(:,:,i) = rec;
    % /GPU
    waitbar(i/size(res_sinos,3) ,f);
end
close(f);
% display reconstructions
implay(mat2gray(recs))
    
%% save

mkdir(outdir);

recs = mat2gray(recs);

f = waitbar(0,'Please wait...');
for i = 1:size(recs,3)
    im = uint8(recs(:,:,i)*255);
    imwrite(im,sprintf('%s/file(%i).tiff',outdir,i));
    waitbar(i/size(recs,3) ,f);
end
close(f);

fprintf('Reconstructions written.\n');
    