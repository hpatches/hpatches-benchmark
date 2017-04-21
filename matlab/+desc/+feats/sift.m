function desc = sift( patches )
psz = [size(patches, 1), size(patches, 2)];
frm = [(psz(1) ./ 2 + 0.5) * ones(2, 1) ; psz(1) ./ 2; 0];
desc = [];
for pi = 1:size(patches, 3)
  I = single(patches(:, :, pi));
  [Ix, Iy] = vl_grad(I) ;
  mod      = sqrt(Ix.^2 + Iy.^2) ;
  ang      = atan2(Iy, Ix) ;
  grd      = shiftdim(cat(3, mod, ang), 2) ;
  d        = vl_siftdescriptor(grd, frm, 'magnif', 0.5) ;
  if isempty(desc)
    desc = zeros(numel(d), size(patches, 3), 'single');
  end
  desc(:, pi) = d;
end

end

