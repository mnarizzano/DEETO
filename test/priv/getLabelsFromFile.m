function [labels,PathName]=getLabelsFromFile(PathName)
% load labels from different file formats.
% implemented now .txt list

labels={};

[labelsFile,PathName,filterindex]=uigetfile({
    '*.txt', 'Text files (Tab delimited) (*.txt)'; ...         % 1
    '*.mat', 'MATLAB files (labels Cell array) (*.mat)'; ...   % 2
    '*.set', 'EEGLAB set files (*.set)';...                    % 3
    '*.mat', 'Fieltrip hdr files (*.mat)';...                  % 4 
    '*.edf', 'edf files (*.edf)'},...                          % 5 
    'Load labels from file',PathName);


if labelsFile~=0
    
    switch filterindex
        case 1 %load channels in a txt file
            labels = importTxtLabels([PathName labelsFile]);
        case 2 %MATLAB labels cell array
            s=load([PathName labelsFile]);
            labels=s.labels;        
            
        case 3 %EEGLAB
            s=load('-mat',[PathName labelsFile]);
            labels={s.EEG.chanlocs.labels};

        case 4 %Fieldtrip
            s=load('-mat',[PathName labelsFile]);
            labels=s.hdr.label;

        case 5
            header=readEdfHeader([PathName labelsFile]);
            labels=cellstr(header.channelname);
        otherwise
            disp('File format not supported');
    end
    
end

