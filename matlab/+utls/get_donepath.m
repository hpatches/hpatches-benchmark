function [ donepath ] = get_donepath( resfile )

[path, name] = fileparts(resfile);
donepath = fullfile(path, ['.', name, '.done']);

end

