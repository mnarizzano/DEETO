function varargout = plotRobustnessResults(varargin)
% plotRobustnessResults

% Edited 2013-12-23 by Gabriele Arnulfo <gabriele.arnulfo@gmail.com>

subjects_dir = '/biomix/home/staff/gabri/Dropbox/DEETO-DATA/';
% pre allocate mem to speed up computation

nCentersPerDistance = 5;
nDistancePoints = 4;
nSubjects = 1;

x = zeros(1,nDistancePoints);
DD= zeros(nDistancePoints,nSubjects*nCentersPerDistance);

% for each subject in subjects dir
for subj_id = 1:2
	% read the original recon.file
	parent_folder = [subjects_dir 'subject' num2str(sprintf('%02d',subj_id))];

	Afname = [parent_folder '/recon_test.fcsv'];
	recon_files   = dir([parent_folder '/data/recon_test*.fcsv']);
	filenames	  = arrayfun(@(x)(x.name),recon_files,'UniformOutput',false);
	samples_order = regexp(filenames,'\d+','match');
	samples_order = reshape(cat(2,samples_order{:}),[2, numel(samples_order)]);
	samples_order = cellfun(@str2num, samples_order);

	dist_indices  = unique(samples_order(1,:));

	for id = 1:numel(recon_files)
		% read all the recon_test.file 
		% one for each recon_files_d*_c*.fcsv
		Bfname = [parent_folder '/data/' recon_files(id).name];

		dist_id		= find(dist_indices==samples_order(1,id));
		sample_id	= samples_order(2,id)+1;
		
		[DD(dist_id,sample_id + (subj_id-1)*nDistancePoints),...
		  MM(dist_id,sample_id + (subj_id-1)*nDistancePoints)] = analysis(Afname, Bfname);
	end
 
end

figure, 
subplot(2,1,1), errorbar(dist_indices,mean(DD,2),std(DD,[],2));
	xlim([min(dist_indices) max(dist_indices)]);
	xlabel('Displacement (mm) ');
	ylabel('Erorr (mm) ');
	box off;
subplot(2,1,2), errorbar(dist_indices,mean(abs(MM),2),std(abs(MM),[],2));
	xlabel('Displacement (mm) ');
	ylabel('# missing contacts');
	xlim([min(dist_indices) max(dist_indices)]);
	box off;



end

function [DD, nContactsMissing] = analysis(A,B)

	[ALabels, X,Y,Z] = textread(A,'%s%f%f%f%*d%*d','delimiter',',','commentstyle','shell');
	APoints = cat(2,X,Y,Z);
	[BLabels, X,Y,Z] = textread(B,'%s%f%f%f%*d%*d','delimiter',',','commentstyle','shell');
	BPoints = cat(2,X,Y,Z);

	% Check points order based on label ordering
	[f, ord] = ismember(BLabels, ALabels);

	DD = mean( sqrt( sum( (BPoints(f==1,:) - APoints(ord(f==1),:)).^2,2)));
	nContactsMissing = numel(ALabels) - numel(f==1);
	
end
