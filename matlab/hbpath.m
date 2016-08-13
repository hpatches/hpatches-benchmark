function dpath = hbpath()

funpath = fileparts(mfilename('fullpath'));
dpath = fullfile(fileparts(funpath));