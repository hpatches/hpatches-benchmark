function d = rootsift( patches )
% Copyright: Karel Lenc and Giorgos Tolias
d = desc.feats.sift(patches);
vnr = sum(abs(d));
d = bsxfun (@rdivide, d, vnr);
d = sqrt(d);
d(isnan(d)) = 0;
end

