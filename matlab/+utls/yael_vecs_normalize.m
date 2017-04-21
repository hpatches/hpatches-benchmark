% This function normalize a set of vectors
% Parameters:
%   v     the set of vectors to be normalized (column stored)
%   nr    the norm for which the normalization is performed (Default: Euclidean)
%   rval  replace value in case the vector is 0-norm
%
% Output:
%   vout  the normalized vector
%   vnr   the norms of the input vectors
%
% Remark: the function return Nan for vectors of null norm
function [vout, vnr] = yael_vecs_normalize (v, nr, rval)

if nargin < 2, nr = 2; end

% norm of each column
vnr = (sum (v.^nr)) .^ (1 / nr);

% sparse multiplication to apply the norm
vout = bsxfun (@times, v, 1 ./ vnr);

if exist('rval')
  [~, ko] = find (isnan (vout));
  ko = unique (ko);
  vout (:, ko) = rval;
end
