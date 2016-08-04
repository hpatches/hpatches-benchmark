classdef BinaryData < handle
% utls.BinaryData wrapper around a binary file with a simple header.
%   Allows direct acces to a binary file indexing continous chunks.
%   To create a new binary file use methods `utls.BinaryData.create` 
%   (initializing the file with zeros) or `utls.BinaryData.create_from`
%   to initialize the binary file with an existing matlab numeric array.
%   The constructor is used to open an existing binary file.
%
%   The binary file is of a simple format: 
%
%   %utls.BinaryDataHEADER$<DTYPE_NCHAR_UINT64><DTYPE_STRING><NUMDIM_UINT64>
%   <DIMS_UINT64><DATA...>
%
%   Where the header contains the data type and the dimensionality of the 
%   array.
%
%   Data can be accessed through 'readall' and 'writeall' methods or
%   through the '()' operator. However the limitation is that the only
%   continuous chunks of the data can be accessed.
%
%   No data are being cached in the memory. All read and write operations
%   are performed with low-level file access operators. After each
%   operation the file descriptor is closed.
  
% TODO setting all values with a scalar - do not pre-allocate in memory
  properties (GetAccess=public, SetAccess=protected)
    path;
    dtype;
    data_size;
    count;
    offset;
    dtype_nbytes;
    data;
    read_only;
    fid;
  end
  
  properties (Constant)
    HEADER_KEY = 'VLB_BINARY_TENSOR';
    LOCK_FILE = @(path) [path '.lock'];
  end
  
  methods
    function obj = BinaryData(path, read_only)
      if nargin < 2, read_only = false; end;
      obj.read_only = read_only;
      if ~exist(path, 'file')
        error('File %s path does not exist. Use .create for a new object.');
      end
      obj.path = path;
      if read_only
        obj.fid = fopen(path, 'r');
      else
        obj.fid = fopen(path, 'r+');
      end
      obj.read_header();
      obj.check_data_size();
      obj.unlock(obj.path);
    end
    
    function delete(obj)
      fclose(obj.fid);
    end
    
    function d = readall(obj, varargin)
      d = obj.read(0, obj.count);
      d = reshape(d, obj.data_size);
      if ~isempty(varargin)
        d = d(varargin{:});
      end
    end
    
    function nothing = writeall(obj, data)
      assert(~obj.read_only, 'Data is read only.');
      if numel(data) == 1, data = ones(obj.data_size, obj.dtype) * data; end
      assert(all(size(data) == obj.data_size), 'Invalid data size');
      obj.write(0, data);
      nothing = [];
    end
    
    function d = subsref(obj, s)
      % dispatch method calls
      if s(1).type == '.', d = builtin('subsref', obj, s); return; end; 
      [idxs, chunksize] = obj.subs2indxs(s);
      start = idxs(1) - 1;
      len = idxs(end) - idxs(1) + 1;
      d = obj.read(start, len);
      assert(numel(d) == len);
      if numel(chunksize) ~= 1
        d = reshape(d, chunksize);
      end
    end
    
    function obj = subsasgn(obj, s, data)
      assert(~obj.read_only, 'Data is read only.');
      if numel(data) == 1, data = ones(obj.data_size, obj.dtype) * data; end
      [idxs, chunksize] = obj.subs2indxs(s);
      start = idxs(1) - 1;
      len = idxs(end) - idxs(1) + 1;
      indata_size = size(data);
      % For data of size (:,:, .., 1) matlab throws away the last
      % dimensionality...
      assert(all(indata_size == chunksize(1:numel(indata_size))), ...
        'Invalid selection size: [%s] data size [%s]', ...
        sprintf('%d, ', chunksize), sprintf('%d, ', size(data)));
      assert(numel(data) == len, 'Invalid selection size.');
      obj.write(start, data);
    end
    
    function sz = size(obj, dim)
      if nargin > 1
        sz = obj.data_size(dim);
      else
        sz = obj.data_size;
      end
    end
    
    function nd = ndims(obj)
      nd = numel(obj.data_size);
    end
    
    function d = reshape(obj, varargin)
      d = reshape(obj.readall(), varargin{:});
    end
  end
  
  methods (Access=protected, Hidden=true)
    function [idxs, chunksize] = subs2indxs(obj, s)
      % TODO allow indexing ala (1,1,1)
      assert(strcmp(s.type, '()'));
      if ~(numel(s.subs) == 1 || numel(s.subs) == numel(obj.data_size))
        error('Invalid number of dimensions for indexing.');
      end
      if numel(s.subs) == 1 && s.subs{1} == ':'
        idxs = [1, obj.count];
        chunksize = [obj.count, 1];
        return;
      else
        chunksize = zeros(1, numel(s.subs));
        for ci = 1:numel(s.subs)
          if (ischar(s.subs{ci}) && s.subs{ci} == ':')
            s.subs{ci} = [1, obj.data_size(ci)];
            chunksize(ci) = obj.data_size(ci);
          elseif isscalar(s.subs{ci})
            s.subs{ci} = [s.subs{ci}, s.subs{ci}];
            chunksize(ci) = 1;
          else
            assert(ci == numel(s.subs), ...
              'Only last dimension can be directly indexed.');
            assert(all(diff(s.subs{ci}(:))==1), ...
              'Indexing must be a continous chunk.');
            s.subs{ci} = [s.subs{ci}(1), s.subs{ci}(end)];
            chunksize(ci) = s.subs{ci}(end) - s.subs{ci}(1) + 1;
          end
        end
      end
      idxs = sub2ind(obj.data_size, s.subs{:});
    end
    
    function array = read(obj, start, len)
      % Start is zero-based
      fseek(obj.fid, start*obj.dtype_nbytes + obj.offset, 'bof');
      array = fread(obj.fid, len, ['*' obj.dtype]);
    end
    
    function write(obj, start, data)
      % Start is zero-based
      assert(strcmp(class(data), obj.dtype), ...
        sprintf('Invalid data type of the input array (%s, expected %s).', ...
        class(data), obj.dtype));
      assert(numel(data) - start <= obj.count, ...
        'Unable to append to the file.');
      obj.lock(obj.path);
      fseek(obj.fid, (start*obj.dtype_nbytes) + obj.offset, 'bof');
      count_fw = fwrite(obj.fid, data(:), obj.dtype);
      obj.unlock(obj.path);
      assert(count_fw == numel(data), ...
        sprintf('Error writing to a file %s.', obj.path));
      obj.check_data_size();
    end
    
    function check_data_size(obj)
      finfo = dir(obj.path);
      file_sz = finfo.bytes;
      if (file_sz - obj.offset)/obj.dtype_nbytes ~= obj.count
        error('Invalid file size.');
      end
    end
    
    function read_header(obj)
      key = utls.BinaryData.HEADER_KEY;
      fkey = fread(obj.fid, numel(key), '*char')';
      if ~strcmp(key, fkey)
        error('Invalid file header.');
      end; % Do nothing
      dtype_sz = double(fread(obj.fid, 1, '*uint64'));
      assert(dtype_sz > 0 && dtype_sz < 20, ...
        'Invalid dtype specification in header.');
      obj.dtype = fread(obj.fid, dtype_sz, '*char')';
      ndim = double(fread(obj.fid, 1, '*uint64'));
      assert(ndim > 0 && ndim < 6, 'Invalid ndim header value.');
      obj.data_size = double(fread(obj.fid, ndim, '*uint64'))';
      assert(all(obj.data_size > 0), 'Invalid data sizes in header.');
      obj.count = prod(obj.data_size);
      obj.offset = ftell(obj.fid);
      obj.dtype_nbytes = obj.get_dtype_nbytes(obj.dtype);
    end
    
  end
  
  methods (Static)
    function obj = create_from(path, data)
      obj.path = path;
      obj.dtype = class(data);
      obj.data_size = size(data);
      obj.count = prod(obj.data_size);
      utls.BinaryData.lock(obj.path);
      fid_tmp = fopen(path, 'w');
      fid_tmp = utls.BinaryData.write_header(obj, fid_tmp);
      count_fw = fwrite(fid_tmp, data, obj.dtype);
      assert(count_fw == obj.count, ...
        sprintf('Error writing to a file %s.', path));
      fclose(fid_tmp);
      utls.BinaryData.unlock(obj.path);
      % Reload it...
      obj = utls.BinaryData(path);
    end
    
    function obj = zeros(path, varargin)
      if ~ischar(varargin{end})
        varargin{end+1} = 'double';
      end
      size = varargin{1:end-1};
      dtype = varargin{end};
      obj.path = path;
      obj.dtype = dtype;
      obj.data_size = size;
      obj.count = prod(obj.data_size);
      utls.BinaryData.lock(obj.path);
      fid_tmp = fopen(path, 'w');
      fid_tmp = utls.BinaryData.write_header(obj, fid_tmp);
      nbytes = obj.count*utls.BinaryData.get_dtype_nbytes(dtype);
      utls.BinaryData.alloc_data(fid_tmp, nbytes);
      fclose(fid_tmp);
      utls.BinaryData.unlock(obj.path);
      % Reload it...
      obj = utls.BinaryData(path);
    end
  end
    
  
  methods (Static, Access=protected, Hidden=true)
    function alloc_data(fid, count)
      MAX_CHUNK_SIZE = 1024^3; % Alloc at most 1GB in memory
      sequence = [1:MAX_CHUNK_SIZE:count, count+1];
      stime = tic;
      for stepi = 1:numel(sequence)-1
        seq_sel = sequence(stepi:stepi+1);
        nel = seq_sel(2) - seq_sel(1);
        fwrite(fid, zeros(1, nel, 'uint8'), 'uint8');
        if toc(stime) > 3
          helpers.progressbar('zero_filler', stepi ./ (numel(sequence)-1));
        end
      end
    end
    
    function nbytes = get_dtype_nbytes(dtype)
      tmp = ones(1, dtype);
      W = whos('tmp');
      nbytes = W.bytes;
    end
    
    function [fid] = write_header(obj, fid)
      key = utls.BinaryData.HEADER_KEY;
      fwrite(fid, key, 'char');
      fwrite(fid, numel(obj.dtype), 'uint64');
      fwrite(fid, obj.dtype, 'char');
      fwrite(fid, numel(obj.data_size), 'uint64');
      fwrite(fid, obj.data_size, 'uint64');
    end
    
    function lock(path)
      lock_file = utls.BinaryData.LOCK_FILE(path);
      assert(exist(lock_file, 'file') == 0, 'Unable to write to a file - file locked.');
      fid_lock = fopen(lock_file, 'w'); fclose(fid_lock);
    end
    
    function unlock(path)
      lock_file = utls.BinaryData.LOCK_FILE(path);
      if exist(lock_file, 'file')
        delete(lock_file);
      end
    end
  end
  
end
