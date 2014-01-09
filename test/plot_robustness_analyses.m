function varargout = plotRobustnessResults(varargin)
% plotRobustnessResults

% Edited 2013-12-23 by Gabriele Arnulfo <gabriele.arnulfo@gmail.com>
method = 1;

subjects_dir = '/biomix/home/staff/gabri/Dropbox/DEETO-DATA/';
% pre allocate mem to speed up computation


subjs_idx = [1,2,3,6,8,9,11,15,17,19,20,21,24,25,26,28,31,34,35,37,38,39,40,41,42];
%subjs_idx = [42];
%subjs_idx = [11,15,17,19,24,31,34,39,40,41,42]; % 38 ??
nSubjects = numel(subjs_idx);

subj_offset= 0;

nCentersPerDistance = 5;
nDistancePoints = 4;

x = zeros(1,nDistancePoints);
DD= zeros(nDistancePoints,nSubjects*nCentersPerDistance);
MM= zeros(nDistancePoints,nSubjects*nCentersPerDistance);
CC= zeros(nDistancePoints,nSubjects*nCentersPerDistance);

% for each subject in subjects dir
for subj_id = subjs_idx
	parent_folder = [subjects_dir 'subject' num2str(sprintf('%02d',subj_id))];
	
	% build path to the original recon.file
	Afname = [parent_folder '/recon_test.fcsv'];

	if method == 1
		recon_files   = dir([parent_folder '/data/recon_test*.fcsv']);
		filenames	  = arrayfun(@(x)(x.name),recon_files,'UniformOutput',false);
		samples_order = regexp(filenames,'\d+','match');
		samples_order = reshape(cat(2,samples_order{:}),[2, numel(samples_order)]);
		samples_order = cellfun(@str2num, samples_order);

		dist_indices  = unique(samples_order(1,:));

		for id = 1:numel(recon_files)
			% one for each recon_files_d*_c*.fcsv
			Bfname = [parent_folder '/data/' recon_files(id).name];

			dist_id		= find(dist_indices==samples_order(1,id));
			sample_id	= samples_order(2,id)+1;
			
			[DD(dist_id,sample_id + (subj_offset)*nDistancePoints),...
			  MM(dist_id,sample_id + (subj_offset)*nDistancePoints),...
			  CC(dist_id,sample_id + (subj_offset)*nDistancePoints)] = analysis(Afname, Bfname);
		end
		subj_offset = subj_offset+1;
	else
		Bfname = [parent_folder '/recon_manual.fcsv'];
		[DD1(subj_id) ,~  ,NN1(subj_id)]= analysis(Afname, Bfname);
	end
 
end



figure, 
subplot(2,1,1), errorbar(dist_indices,mean(DD,2),std(DD,[],2)./sqrt(size(DD,2)));
	xlim([min(dist_indices) max(dist_indices)]);
	xlabel('Displacement (mm) ');
	ylabel('Erorr (mm) ');
	box off;
subplot(2,1,2), errorbar(dist_indices,mean(abs(MM),2),std(abs(MM),[],2)./sqrt(size(MM,2)));
	xlabel('Displacement (mm) ');
	ylabel('# missing contacts');
	xlim([min(dist_indices) max(dist_indices)]);
	box off;
%mean(DD1(DD1~=0))
%std(DD1(DD1~=0))
%sum(NN1)

end

function [DD, nContactsMissing, nContacts] = analysis(A,B)

	[ALabels, X,Y,Z] = textread(A,'%s%f%f%f%*d%*d','delimiter',',','commentstyle','shell');
	APoints = cat(2,X,Y,Z);
	[BLabels, X,Y,Z] = textread(B,'%s%f%f%f%*d%*d','delimiter',',','commentstyle','shell');
	BPoints = cat(2,X,Y,Z);
	
	% the lines above are necessary only
	%+ in the comparison with manually segmented data
	%+ since they are defined in centered geometrical space
%	BPoints = BPoints .* repmat([-1, -1, 1],[size(BPoints,1) 1]);
%	offset  = readTransform(B);
%	offset  = offset(1:3)';
%	BPoints = BPoints + repmat(offset,[size(BPoints,1) 1]);
%	BPoints = BPoints .* repmat([-1, -1, 1],[size(BPoints,1) 1]);
%

	% Check points order based on label ordering
	[f, ord] = ismember(BLabels, ALabels);
%	fid = fopen('test.dat','w');
%	AA = ALabels(ord(f==1));
%	AP = APoints(ord(f==1),:);
%	BB = BLabels(f==1);
%	BP = BPoints(f==1,:);

%	for ii = 1:numel(find(f))
%		fprintf(fid,'%s,%f,%f,%f,%s,%f,%f,%f\n',BB{ii},BP(ii,1),BP(ii,2),BP(ii,3),...
%				AA{ii},AP(ii,1),AP(ii,2),AP(ii,3));
%	end
%	fclose(fid);

	DD = mean( sqrt( sum( (BPoints(f==1,:) - APoints(ord(f==1),:)).^2,2)));
	nContactsMissing = numel(ALabels) - numel(f==1);
	nContacts = numel(ALabels);
%	nContacts = numel(BLabels);
	
end

function t = readTransform(B)
	[base_path, ~ ]	= fileparts(B);
	fname 			= fullfile(base_path,'r_oarm_seeg_cleaned.nii.gz');
	[~,~,ext] 		= fileparts(fname);

	if strcmp(ext,'.gz')
		fname = gunzip(fname);
	end

	ref					= load_untouch_header_only(fname{1});
	center	 			= floor(ref.dime.dim(2:4)./2.0);
	ref_sform			= [ref.hist.srow_x;ref.hist.srow_y;ref.hist.srow_z;0 0 0 1];
	clear ref;

	t 					= ref_sform * [center, 1]';

end
