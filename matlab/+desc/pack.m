function pack(descname)
%PACK Pack a descriptor to a zip file together with meta

% Copyright (C) 2016-2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

if nargin < 1, error('Descriptor not specified.'); end

descInfoFile = fullfile(hb_path, 'data', 'descriptors', descname, 'info.txt');
if ~exist(descInfoFile, 'file') ||...
    numel(utls.readfile(descInfoFile)) ~= 2
  fprintf('\nTo continue, we need to know few details about your submission:\n');
  submissisonName = input('Please enter submission name: ', 's');
  emailAddress = input('Please enter contact email: ', 's');
  ifd = fopen(descInfoFile, 'w');
  fprintf(ifd, '%s\n%s', submissisonName, emailAddress);
  fclose(ifd);
  fprintf('Submission info wrote to %s. Edit this file for changes.\n', ...
    descInfoFile);
end

zipFile = fullfile(hb_path(), [descname, '_descriptors.zip']);
fprintf('Packing the descriptors to %s.\n', zipFile);
zip(zipFile, fullfile(hb_path, 'data', 'descriptors', descname));

end