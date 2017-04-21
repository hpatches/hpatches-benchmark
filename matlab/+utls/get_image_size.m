function [ size ] = imageSize(imagePath)
%IMAGESIZE Get image size helper
%   SIZE = IMAGESIZE(IMAGEPATH) returns size of the image defined by path
%   IMAGEPATH. Size is defined as size of Matlab matrix, i.e. as
%   [num_rows num_cols num_planes].

% Authors: Karel Lenc

% AUTORIGHTS
info = imfinfo(imagePath);
switch info.ColorType
  case 'grayscale'
    numPlanes = 1;
  case 'truecolor'
    numPlanes = 3;
  case 'indexed'
    numPlanes = 3;
end

size = [info.Height, info.Width numPlanes];
end

