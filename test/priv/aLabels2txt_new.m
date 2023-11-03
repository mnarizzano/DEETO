function aLabels2txt_new(electrodes,filename,type)
% print aLabels structure to a txt file in tab separeted format

% type : 'Localized' / 'Projected-SCE' 
%
% columns:
% Ch label, X, Y, Z, aLabels (as many columns as present), projections.aLabels (identified by a (p) at the begining),
% A Blenkmann 13 March 2015

arrays=length(electrodes); %get number of arrays

fid=fopen([filename],'w+'); %sobreescribo si habia algo
fprintf(fid,['Ch label\t X\t Y\t Z\t  aLabels\n']);


for n=1:arrays
        switch type
            case 'Localized'
                aLabels=electrodes{n}.aLabels;
                [~,cols]=size(aLabels);
                
                for k=1:numel(aLabels)
                    aLabels{k}=[aLabels{k} ' ']; % add a space at the end of each cell
                end
                
                for i=1:electrodes{n}.nElectrodes
                    chStr=electrodes{n}.ch_label{i};
                    chStr(~isstrprop(chStr,'alphanum')) = '';
                    
                    %ch labels and coordinates
                    fprintf(fid,'%s\t %.1f\t %.1f\t %.1f\t',chStr,electrodes{n}.x(i),electrodes{n}.y(i),electrodes{n}.z(i));
                    for j=1:cols %for each column
                        fprintf(fid,'%s\t',aLabels{i,j});
                    end
                    fprintf(fid,'\n'); %new line
                end

            case 'Projected-SCE' 
                % for now, export first projection (SCE)
                p=1;                
                aLabels=electrodes{n}.projection{p}.aLabels;
                [~,cols]=size(aLabels);
                
                for k=1:numel(aLabels)
                    aLabels{k}=[aLabels{k} ' ']; % add a space at the end of each cell
                end
                
                for i=1:electrodes{n}.nElectrodes
                    chStr=electrodes{n}.ch_label{i};
                    chStr(~isstrprop(chStr,'alphanum')) = '';
                    
                    %ch labels and coordinates
                    fprintf(fid,'%s\t %.1f\t %.1f\t %.1f\t',chStr,electrodes{n}.projection{p}.x(i),electrodes{n}.projection{p}.y(i),electrodes{n}.projection{p}.z(i));
                    for j=1:cols %for each column
                        fprintf(fid,'%s\t',aLabels{i,j});
                    end
                    fprintf(fid,'\n'); %new line
                end
        end
    
    clear ch_labels
    fprintf(fid,'\n'); %new line at the end of each array
    
end
fclose(fid);

disp([filename ' saved OK'] )
