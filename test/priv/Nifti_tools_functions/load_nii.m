% This file is copied from:
% http://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image
%  by Jimmy Shen (jimmy@rotman-baycrest.on.ca)


function nii = load_nii(filename, img_idx, dim5_idx, dim6_idx, dim7_idx, ...
			old_RGB, tolerance, preferredForm)

   if ~exist('filename','var')
      error('Usage: nii = load_nii(filename, [img_idx], [dim5_idx], [dim6_idx], [dim7_idx], [old_RGB], [tolerance], [preferredForm])');
   end

   if ~exist('img_idx','var') | isempty(img_idx)
      img_idx = [];
   end

   if ~exist('dim5_idx','var') | isempty(dim5_idx)
      dim5_idx = [];
   end

   if ~exist('dim6_idx','var') | isempty(dim6_idx)
      dim6_idx = [];
   end

   if ~exist('dim7_idx','var') | isempty(dim7_idx)
      dim7_idx = [];
   end

   if ~exist('old_RGB','var') | isempty(old_RGB)
      old_RGB = 0;
   end

   if ~exist('tolerance','var') | isempty(tolerance)
      tolerance = 0.1;			% 10 percent
   end

   if ~exist('preferredForm','var') | isempty(preferredForm)
      preferredForm= 's';		% Jeff
   end

   v = version;

   %  Check file extension. If .gz, unpack it into temp folder
   %
   if length(filename) > 2 & strcmp(filename(end-2:end), '.gz')

      if ~strcmp(filename(end-6:end), '.img.gz') & ...
	 ~strcmp(filename(end-6:end), '.hdr.gz') & ...
	 ~strcmp(filename(end-6:end), '.nii.gz')

         error('Please check filename.');
      end

      if str2num(v(1:3)) < 7.1 | ~usejava('jvm')
         error('Please use MATLAB 7.1 (with java) and above, or run gunzip outside MATLAB.');
      elseif strcmp(filename(end-6:end), '.img.gz')
         filename1 = filename;
         filename2 = filename;
         filename2(end-6:end) = '';
         filename2 = [filename2, '.hdr.gz'];

         tmpDir = tempname;
         mkdir(tmpDir);
         gzFileName = filename;

         filename1 = gunzip(filename1, tmpDir);
         filename2 = gunzip(filename2, tmpDir);
         filename = char(filename1);	% convert from cell to string
      elseif strcmp(filename(end-6:end), '.hdr.gz')
         filename1 = filename;
         filename2 = filename;
         filename2(end-6:end) = '';
         filename2 = [filename2, '.img.gz'];

         tmpDir = tempname;
         mkdir(tmpDir);
         gzFileName = filename;

         filename1 = gunzip(filename1, tmpDir);
         filename2 = gunzip(filename2, tmpDir);
         filename = char(filename1);	% convert from cell to string
      elseif strcmp(filename(end-6:end), '.nii.gz')
         tmpDir = tempname;
         mkdir(tmpDir);
         gzFileName = filename;
         filename = gunzip(filename, tmpDir);
         filename = char(filename);	% convert from cell to string
      end
   end

   %  Read the dataset header
   %
   [nii.hdr,nii.filetype,nii.fileprefix,nii.machine] = load_nii_hdr(filename);

   %  Read the header extension
   %
%   nii.ext = load_nii_ext(filename);

   %  Read the dataset body
   %
   [nii.img,nii.hdr] = load_nii_img(nii.hdr,nii.filetype,nii.fileprefix, ...
		nii.machine,img_idx,dim5_idx,dim6_idx,dim7_idx,old_RGB);

   %  Perform some of sform/qform transform
   %
   nii = xform_nii(nii, tolerance, preferredForm);

   %  Clean up after gunzip
   %
   if exist('gzFileName', 'var')

      %  fix fileprefix so it doesn't point to temp location
      %
      nii.fileprefix = gzFileName(1:end-7);
      rmdir(tmpDir,'s');
   end

   return					% load_nii

