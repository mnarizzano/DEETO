function [elec_loc_kmedoids,elec_loc_kmeans]=localizeArray(crd,weight,rows,columns,pos_electrodes,normalVecElec)
% test electrode localization method with simulated coordinates

% crd = CT artifact's voxel coordinates (Nx3)
% weight = intensity at each voxel (Nx1)
% rows and cols =  array dimensions (R x C = P)
% pos_electrodes = simulated coordinates (Px3)


%% path setup - change accordingly

if isunix
        baseDir='/net/lagringshotell/uio/lagringshotell/sv-psi/Nevro/Prosjekt/Alejandro/data/';
else
    baseDir='\\lagringshotell\sv-psi\Nevro\Prosjekt\Alejandro\data\';
    
end

%addpath(genpath([baseDir 'processing-codes-ieeg']))
%addpath(genpath([baseDir '/Images/electrodes/electrodes_gui/priv']))


%% load hull for ploting
load('simulation_points_MNI.mat','v_hull','f_hull');
mesh.vertices=v_hull;
mesh.faces = f_hull;


%% threshold data if too noisy or too many samples. Max 15000 samples

% threshold according to noise level (check paper for details)
T=.5;

crd(weight<T,:)=[];
weight(weight<T)=[];

%limit max number of samples (too many resources for kmedoids)
if length(weight)>15000
    [~,indW]=sort(weight,'descend');
    weight=weight(indW(1:15000));
    crd=crd(indW(1:15000),:);
end

T=min(weight);


%% localize CT artifact using kmeans and kmedoids clustering algorithms (as in iElectrodes today)
nClus=rows * columns;

%% Kmeans
[GS_kmeans,clusters_kmeans]=clustering (nClus,crd,weight); %this algorithm works better than the default Matlab kmeans

%% Kmedoids
[clusters_kmedoids] = kmedoids(crd,nClus,'Algorithm','pam', 'OnlinePhase','on');
    
GS_kmedoids=zeros(nClus,3); 
%get center of mass
for i=1:nClus
    weight=double(weight);
    ind=clusters_kmedoids==i;
    W=sum(weight(ind));
    GS_kmedoids(i,:)=sum(diag(weight(ind))* crd(ind,:),1)*(1/W);
end

%% match localization -> simulated coords
% reorder localized electrodes in the same was as the simulated electrodes

DD=eucDistMat(pos_electrodes,GS_kmeans);
mm=min(DD,[],2);
[~, scanOrder]=sort(mm);
loc_error_kmeans=zeros(1,nClus);
newOrder_kmeans=zeros(1,nClus);

%start from the closest electrode first
for j=scanOrder %1:nClus
    [loc_error_kmeans(j),newOrder_kmeans(j)]=min(DD(j,:),[],2);
    DD(:,newOrder_kmeans(j))=nan; % remove taken collumn
end

elec_loc_kmeans=GS_kmeans(newOrder_kmeans,:);

% for kmedoids
DD=eucDistMat(pos_electrodes,GS_kmedoids);
mm=min(DD,[],2);
[~, scanOrder]=sort(mm);
loc_error_kmedoids=zeros(1,nClus);
newOrder_kmedoids=zeros(1,nClus);

%start from the closest electrode first
for j=scanOrder %1:nClus
    [loc_error_kmedoids(j),newOrder_kmedoids(j)]=min(DD(j,:),[],2);
    DD(:,newOrder_kmedoids(j))=nan; % remove taken collumn
end

elec_loc_kmedoids=GS_kmedoids(newOrder_kmedoids,:);


%% plot

%compute angle for view
cmSurf = mean(v_hull);
cmGrid = mean(pos_electrodes);

f1=figure;
subplot(2,3,1)

s1=scatter3(crd(:,1),crd(:,2),crd(:,3),3,clusters_kmeans); hold on; axis image;
if norm(cmGrid-cmSurf) > norm(cmGrid-cmSurf-mean(normalVecElec))
    view(mean(normalVecElec));
else
    view(-mean(normalVecElec));
end

subplot(2,3,2)
s1=scatter3(crd(:,1),crd(:,2),crd(:,3),3,weight); hold on; axis image;
s2=scatter3(pos_electrodes(:,1),pos_electrodes(:,2),pos_electrodes(:,3),30,'k','filled');
s3=scatter3(elec_loc_kmeans(:,1),elec_loc_kmeans(:,2),elec_loc_kmeans(:,3),30,'r','filled');
% s3=scatter3(GS(:,1),GS(:,2),GS(:,3),30,'r','filled')
% mvis(v_hull,f_hull); hold on; caxis([0 1])

if norm(cmGrid-cmSurf) > norm(cmGrid-cmSurf-mean(normalVecElec))
    view(mean(normalVecElec));
else
    view(-mean(normalVecElec));
end

%camlight;
subplot(2,3,3)
histogram(loc_error_kmeans);
ylabel('count'); xlabel('loc error kmeans[mm]');


% kmedoids
subplot(2,3,4)

s1=scatter3(crd(:,1),crd(:,2),crd(:,3),3,clusters_kmedoids); hold on; axis image;
if norm(cmGrid-cmSurf) > norm(cmGrid-cmSurf-mean(normalVecElec))
    view(mean(normalVecElec));
else
    view(-mean(normalVecElec));
end

subplot(2,3,5)
s1=scatter3(crd(:,1),crd(:,2),crd(:,3),3,weight); hold on; axis image;
s2=scatter3(pos_electrodes(:,1),pos_electrodes(:,2),pos_electrodes(:,3),30,'k','filled');
s3=scatter3(elec_loc_kmedoids(:,1),elec_loc_kmedoids(:,2),elec_loc_kmedoids(:,3),30,'r','filled');
% s3=scatter3(GS(:,1),GS(:,2),GS(:,3),30,'r','filled')
% mvis(v_hull,f_hull); hold on; caxis([0 1])

if norm(cmGrid-cmSurf) > norm(cmGrid-cmSurf-mean(normalVecElec))
    view(mean(normalVecElec));
else
    view(-mean(normalVecElec));
end

%camlight;
subplot(2,3,6)
histogram(loc_error_kmedoids);
ylabel('count'); xlabel('loc error kmedoids [mm]');














