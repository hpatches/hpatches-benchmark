% PCA with automatic selection of the method: covariance or gram matrix
% Usage: [X, eigvec, eigval, Xm] = pca (X, dout, center, verbose)
%   X       input vector set (1 vector per column)
%   dout    number of principal components to be computed
%   center  need to center data?
% 
% Note: the eigenvalues are given in decreasing order of magnitude
%
% Author: Herve Jegou, 2011. 
% Last revision: 08/10/2013
function [X, eigvec, eigval, Xm] = yael_pca (X, dout, center, verbose)

if nargin < 3,         center = true; end
if ~exist ('verbose', 'var'), verbose = false; end

X = double (X);
d = size (X, 1);
n = size (X, 2);

if nargin < 2
  dout = d;
end

if center
  Xm = mean (X, 2);
  X = bsxfun (@minus, X, Xm);
else
  Xm = zeros (d, 1);
end


opts.issym = true;
opts.isreal = true;
opts.tol = eps;
opts.disp = 0;

% PCA with covariance matrix
if n > d 
  if verbose, fprintf ('PCA with covariance matrix: %d -> %d\n', d, dout); end
  Xcov = X * X';
  Xcov = (Xcov + Xcov') / (2 * n);
  
  if dout < d
    [eigvec, eigval] = eigs (Xcov, dout, 'LM', opts);
  else
    [eigvec, eigval] = eig (Xcov);
  end
else
  % PCA with gram matrix
  if verbose, fprintf ('PCA with gram matrix: %d -> %d\n', d, dout); end
  Xgram = X' * X;
  Xgram = (Xgram + Xgram') / 2;
  if dout < d
    [eigvec, eigval] = eigs (Xgram, dout, 'LM', opts);
  else
    [eigvec, eigval] = eig (Xgram);
  end
  eigvec = single (X * eigvec);
  eigvec = utls.yael_vecs_normalize (eigvec);
end
           

X = eigvec' * X;
X = single (X);
eigval = diag(eigval);

% We prefer a consistent order
[~, eigord] = sort (eigval, 'descend');
eigval = eigval (eigord);
eigvec = eigvec (:, eigord);
X = X(eigord, :);
