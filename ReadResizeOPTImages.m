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

function [ stack, filetype ] = ReadResizeOPTImages( path, ...
    filenameformat, nImages, outsize)
%READIMAGESTACKFROMFOLDER Reads all the tiff type files from given folder.
%   Images in the folder are assumed to be the same size.

    % check that there is filesep in the end of path
    if ~strcmp(filesep,path(end))
        path = [path filesep];
    end
    % allocate
    stack = zeros(outsize, outsize, nImages);
    f = waitbar(0,'Please wait...');
    % read images and resize
    for i = 1:nImages
        filename = [path sprintf(filenameformat, i)];
        I = imread(filename);
        stack(:,:,i) = imresize(I,[outsize outsize]);
        waitbar(i/nImages ,f);
    end
    close(f);
    filetype = class(I);
    
end

