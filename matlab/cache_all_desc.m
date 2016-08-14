function cache_all_desc( imdb, desc_fun, cache_name )

status = utls.textprogressbar(numel(imdb.sequences.name));
for si = 1:numel(imdb.sequences.name)
  for imi = 1:numel(imdb.sequences.images{si})
    sign = [imdb.sequences.name{si}, '.', imdb.sequences.images{si}{imi}];
    get_descriptors(imdb, sign, desc_fun, 'cacheName', cache_name);
  end
  status(si);
end

end

