function desc = desc_none( signature, patches, desc_name )
sparts = strsplit(signature, '.');
error('Unable to find descriptor file: %s.\n', ...
  fullfile('data', 'descriptors', desc_name, ...
  sparts{1}, [sparts{2}, '.csv']));
end

