function cache_all_desc( imdb, desc_fun, cache_name )
%CACHE_ALL_DESC Cache all descriptors
%  CACHE_ALL_DESC(IMDB, DESC_FUN, CACHE_NAME) Caches all descriptors of
%  patches stored in IMDB using DESC_FUN storing the csv results files to
%  CACHE_NAME.

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
if isempty(imdb.sequences.name), return; end;
numDescs = numel(imdb.sequences.name) * numel(imdb.sequences.images{1});
status = utls.textprogressbar(numDescs); stepi = 1;
for si = 1:numel(imdb.sequences.name)
  for imi = 1:numel(imdb.sequences.images{si})
    sign = [imdb.sequences.name{si}, '.', imdb.sequences.images{si}{imi}];
    get_descriptors(imdb, sign, desc_fun, 'cacheName', cache_name);
    stepi = stepi+1; status(stepi);
  end
end

end

