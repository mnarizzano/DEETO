function varargout = plotRobustnessResults(varargin)
% plotRobustnessResults

% Edited 2013-12-23 by Gabriele Arnulfo <gabriele.arnulfo@gmail.com>
method = 3;

subjects_dir = '/biomix/home/staff/gabri/data/DEETO-DATA/';
% pre allocate mem to speed up computation

subjs_idx = [1:9, 11,13,15,17,19,20,21,24,25,26,28,31,34,35,37,38,39,40,41,42];
nSubjects = numel(subjs_idx)

subj_offset= 1;

% for each subject in subjects dir
for subj_id = subjs_idx
	parent_folder = [subjects_dir 'subject' num2str(sprintf('%02d',subj_id))];

	% build path to the original recon.file
	Afname = [parent_folder '/recon_test.fcsv'];

	if method == 1

		recon_files   = dir([parent_folder '/data/recon_thr*.fcsv']);
		filenames	  = arrayfun(@(x)(x.name),recon_files,'UniformOutput',false);
		samples_order = regexp(filenames,'\d+_\d','match');
		samples_order = cellfun(@strrep,samples_order,repmat({'_'},21,1),repmat({'.'},21,1));
		samples_order = cellfun(@str2num, samples_order);
		
		dist_indices  = unique(samples_order);
		if (subj_id == 34)
			offset  = readTransform(Afname);
		else
			offset = [0;0;0];
		end

		for id = 1:numel(recon_files)
			Bfname = [parent_folder '/data/' recon_files(id).name];

			dist_id		= find(dist_indices==samples_order(id));

			[DD{dist_id,subj_offset},...
				MM{dist_id,subj_offset},...
				CC{dist_id,subj_offset}] = analysis(Afname, Bfname, offset);

			DDsub{dist_id,subj_offset} = mean(DD{dist_id,subj_offset});
		end

	elseif method == 3

		recon_files   = dir([parent_folder '/data/recon_test*.fcsv']);
		filenames	  = arrayfun(@(x)(x.name),recon_files,'UniformOutput',false);
		samples_order = regexp(filenames,'\d+','match');
		samples_order = reshape(cat(2,samples_order{:}),[2, numel(samples_order)]);
		samples_order = cellfun(@str2num, samples_order);

		dist_indices  = unique(samples_order(1,:));

		offset = [0,0,0]';

		for id = 1:numel(recon_files)
			% one for each recon_files_d*_c*.fcsv
			Bfname = [parent_folder '/data/' recon_files(id).name];

			dist_id		= find(dist_indices==samples_order(1,id));

			[DD{dist_id,subj_offset},...
				MM{dist_id,subj_offset},...
				CC{dist_id,subj_offset}] = analysis(Afname, Bfname, offset);

			DDsub{dist_id,subj_offset} = mean(DD{dist_id,subj_offset});
		end
	else

		Bfname = [parent_folder '/recon_manual.fcsv'];
		if ~(subj_id == 34)
			offset  = readTransform(Afname);
		else
			offset = [0;0;0];
		end

		[DD{1,subj_offset} ,~  ,MM{1,subj_offset}]= analysis(Afname, Bfname, offset);

	end

	subj_offset = subj_offset + 1;
 
end


for ii = 1:size(DD,1)
	DDcat{:,ii} = cat(1,DD{ii,:});
	MMcat{:,ii} = cat(1,MM{ii,:});
end
%DDsub = [DDsub{:}];

DDmean = cellfun(@mean,DDcat);
DDstd  = cellfun(@std,DDcat);
DDsz   = cellfun(@numel, DDcat);

MMmean = cellfun(@mean,MMcat);
MMstd  = cellfun(@std,MMcat);
MMsz   = cellfun(@numel,MMcat);


figure, 
subplot(2,1,1), errorbar(dist_indices,DDmean,DDstd./sqrt(DDsz));
	xlim([min(dist_indices) max(dist_indices)]);
	xlabel('Distance (mm)');
	ylabel('Erorr (mm) ');
	box off;

subplot(2,1,2), errorbar(dist_indices,MMmean,MMstd./sqrt(MMsz./sqrt(MMsz)));
	xlabel('Distance (mm)');
	ylabel('% missing contacts');
	xlim([min(dist_indices) max(dist_indices)]);
	box off;


%figure,
%	subplot(2,1,1), plot(dist_indices,DDsub);
%	xlim([min(dist_indices) max(dist_indices)]);
%	xlabel('Distance');
%	ylabel('Erorr (mm) ');
%	box off;
%
%subplot(2,1,2), errorbar(dist_indices,MMmean,MMstd./sqrt(MMsz./sqrt(MMsz)));
%	xlabel('Threshold Value ');
%	ylabel('# missing contacts');
%	xlim([min(dist_indices) max(dist_indices)]);
%	box off;


%figure, 
%subplot(2,1,1), errorbar(dist_indices,mean(DD,2),std(DD,[],2)./sqrt(size(DD,2)));
%	xlim([min(dist_indices) max(dist_indices)]);
%	xlabel('Displacement (mm) ');
%	ylabel('Erorr (mm) ');
%	box off;
%subplot(2,1,2), errorbar(dist_indices,mean((abs(MM)./CC),2),std((abs(MM)./CC),[],2)./sqrt(size(MM,2)));
%	xlabel('Displacement (mm) ');
%	ylabel('# missing contacts');
%	xlim([min(dist_indices) max(dist_indices)]);
%	box off;
%mean(DD1(DD1~=0))
%std(DD1(DD1~=0))
%sum(NN1)

end

function [DD, nContactsMissing, totContactCount] = analysis(A,B, offset,totContactCount)

	[ALabels, X,Y,Z] = textread(A,'%s%f%f%f%*d%*d','delimiter',',','commentstyle','shell');
	APoints = cat(2,X,Y,Z);
	[BLabels, X,Y,Z] = textread(B,'%s%f%f%f%*d%*d','delimiter',',','commentstyle','shell');
	BPoints = cat(2,X,Y,Z);
	
	% the lines above are necessary only
	%+ in the comparison with manually segmented data
	%+ since they are defined in centered geometrical space
%	offset  = offset(1:3)';
%	offset(3)  =- offset(3);
%	BPoints = BPoints + repmat(offset,[size(BPoints,1) 1]);
%	BPoints = BPoints .* repmat([-1, -1, 1],[size(BPoints,1) 1]);
%	APoints = APoints .* repmat([-1, -1, 1],[size(APoints,1) 1]);


	% Check points order based on label ordering
	[f, ord] = ismember(BLabels, ALabels);
%	fid = fopen('test.dat','a');
%	AA = ALabels(ord(f==1));
%	AP = APoints(ord(f==1),:);
%	BB = BLabels(f==1);
%	BP = BPoints(f==1,:);
%
%	for ii = 1:numel(find(f))
%		fprintf(fid,'%s,%f,%f,%f,%s,%f,%f,%f\n',BB{ii},BP(ii,1),BP(ii,2),BP(ii,3),...
%				AA{ii},AP(ii,1),AP(ii,2),AP(ii,3));
%	end
%	fclose(fid);

	DD =sqrt( sum( (BPoints(f,:) - APoints(ord(f),:)).^2,2));
	DD = DD(:); % force column vector

	misses 			= (numel(ALabels) - numel(find(f)));
	hits			= 
	totContactCount = totContactCount + numel(ALabels);

	
end

function t = readTransform(B)
	[base_path, ~ ]	= fileparts(B);
	fname 			= fullfile(base_path,'r_oarm_seeg.nii.gz');
	[~,~,ext] 		= fileparts(fname);

	if strcmp(ext,'.gz')
		fname = gunzip(fname);
	else
		fname = {fname};
	end

	ref					= load_untouch_header_only(fname{1});
	center	 			= floor(ref.dime.dim(2:4)./2.0);
	ref_sform			= [ref.hist.srow_x;ref.hist.srow_y;ref.hist.srow_z;0 0 0 1];
	clear ref;

	t 					= ref_sform * [center, 1]';

end
