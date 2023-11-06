function aLabelsTargets2txt_new(targets,filename)
% print aLabels structure to a txt file in tab separeted format

% also print projections if they exist
%
% columns:
% Ch label, X, Y, Z, aLabels (as many columns as present), projections.aLabels (identified by a (p) at the begining),
% A Blenkmann 13 March 2015

arrays=length(targets); %get number of arrays

fid=fopen([filename],'w+'); %sobreescribo si habia algo


%% first only target in and target out
fprintf(fid,['ArrayName\t X1\t Y1\t Z1\t aLabels\t X2\t Y2\t Z2\t Azimuth\t Elevation\t FramePosition\t Alpha\t Beta\t \n']);


for n=1:arrays
    if targets(n).frameDown
        fDown='-Down';
    else
        fDown='-Up';
    end
    fprintf(fid,'%s\t %.1f\t %.1f\t %.1f\t %s\t',...
        targets(n).name, targets(n).targetIn.x, targets(n).targetIn.y,...
        targets(n).targetIn.z, targets(n).aLabels{1});
    
    fprintf(fid,' %.1f\t %.1f\t %.1f\t',...
        targets(n).targetOut.x, targets(n).targetOut.y, targets(n).targetOut.z);
    
    fprintf(fid,' %.1f\t %.1f\t',targets(n).azimut, targets(n).elevation);
    
    fprintf(fid,'%s\t %.1f\t %.1f\t',...
        [targets(n).framePosition fDown], targets(n).alpha, targets(n).beta);
    
    fprintf(fid,'\n'); %new line
end

fprintf(fid,'\n \n \n'); %3 new line

%% details of all electrodes targets
fprintf(fid,['Electrode\t X\t Y\t Z\t  aLabels\n']);

for n=1:arrays
    for i=1:targets(n).n
        chStr=[targets(n).name num2str(i)];
        
        fprintf(fid,'%s\t %.1f\t %.1f\t %.1f\t %s\t \n',...
            chStr, targets(n).coordinates(i,1), targets(n).coordinates(i,2),...
            targets(n).coordinates(i,3), targets(n).aLabels{i});
        
        
    end
    fprintf(fid,'\n'); %new line
    
end
fclose(fid)

disp([filename ' saved OK'] )
