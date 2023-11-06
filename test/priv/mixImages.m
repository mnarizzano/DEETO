function  imgW=mixImages(T1im,CTim,mixValue,opt)
% Mix the content of CT and T1, according to mixValue
% using the colors for each image present in colorT1 and colorCT
% observation window is povided by opt.win

% T1im: 3D volume image
% CTim: 3D volume image (same size as T1). Use [] if unavailable
% mixValue: Mixture between T1 and CT
% opt.colorT1 [r g b]
% opt.colorCT [r g b]
% opt.win: [min max] visualizaition window for T1 and CT
% opt.edgeCT: 1/0 adds an edge detection of the CT in the defined color channel
% opt.edgeCTchannels = index to channel 1=red 2=green 3=blue 
%                      (Ex: =[1] only red channel, =[2 3] green and blue )
% opt.percentileThres  = [0 to 100] defines the percentile for binarizing CT 

% A Blenkmann 2017

% April 2020
% imgW is normalized to [0 255] interval values (8 bits resolution per
% color channel)

% use like this:
% opt.colorT1=handles.colors.colorT1; %from defaultGuiVariables
% opt.colorCT=handles.colors.colorCT; %from defaultGuiVariables
% opt.win= [get(handles.MinWinslider,'Value') get(handles.MaxWinslider,'Value')];
% mixValue=get(handles.TAC_MRIslider,'Value');
% T1im=single(handles.T1.img);
% handles.imgW=mixImages(T1im,[],mixValue,opt);
% if ~isempty(handles.TAC)
%     % sum weighted images
%     CTim=single(handles.TAC.img);
%     handles.imgW=mixImages(T1im,CTim,mixValue,opt);
% end


%% prepare images

% normalize T1
T1im=T1im-min(T1im(:));
T1im=T1im/max(T1im(:));
% observation window
T1im=T1im-opt.win(1);
T1im=T1im/opt.win(2);
T1im(T1im>1)=1;
T1im(T1im<0)=0; 

%colors channles - make each ch 8 bits resolution only
T1r=uint8(T1im*opt.colorT1(1)*255); %red channel
T1g=uint8(T1im*opt.colorT1(2)*255); %green channel
T1b=uint8(T1im*opt.colorT1(3)*255); %blue channel
% T1r=(T1im*opt.colorT1(1)); %red channel
% T1g=(T1im*opt.colorT1(2)); %green channel
% T1b=(T1im*opt.colorT1(3)); %blue channel

%mix colors
T1=cat(4,T1r,T1g,T1b); %4D mat - time/mem consuming

if ~isempty(CTim)
    % normalize CT
    CTim=CTim-min(CTim(:));
    CTim=CTim/max(CTim(:));
    % observation window
    CTim=CTim-opt.win(1);
    CTim=CTim/opt.win(2);
    CTim(CTim>1)=1;
    CTim(CTim<0)=0;

    %colors 8 bit resolution per ch
    CTr = uint8(CTim*opt.colorCT(1)*255); %red channel
    CTg = uint8(CTim*opt.colorCT(2)*255); %green channel
    CTb = uint8(CTim*opt.colorCT(3)*255); %blue channel
%     CTr = (CTim*opt.colorCT(1)); %red channel
%     CTg = (CTim*opt.colorCT(2)); %green channel
%     CTb = (CTim*opt.colorCT(3)); %blue channel
    
    if opt.edgeCT
        %Edge detection filter
        %define kernel
        h(:,:,1) = -[1 1 1;  1  1  1;  1 1 1];
        h(:,:,2) = -[1 1 1;  1 -26 1;  1 1 1];
        h(:,:,3) = -[1 1 1;  1  1  1;  1 1 1];
        
        % Segment image using kernel
        CTedge = imfilter(CTim,h);
        % binarize CTedge
        tresholdCTedge=prctile(CTedge(:),opt.percentileThres);
        
        CTedge(CTedge(:)<tresholdCTedge)=0;
        CTedge(CTedge(:)>tresholdCTedge)=1;
        CTedge=uint8(CTedge*255);
%         CTedge=(CTedge);
    end
    %mix colors
    CT=cat(4,CTr,CTg,CTb); %4D mat - time/mem consuming
end

%% proced to mix

if isempty(CTim) % only T1
    imgW=T1;
else %mix images
    if sum(opt.colorT1 & opt.colorCT) % overlaping color channels -linear mix
        imgW=mixValue*CT + (1-mixValue)*T1; %slider - 4D mat - time/mem consuming
    else % independent channels (100% of both images at middle point) - non linear
        if mixValue>.5
            imgW=CT +(2-2*mixValue)*T1;
        else
            imgW=2*mixValue*CT +T1;
        end
    end
    
   if opt.edgeCT
       for i=opt.edgeCTchannels
        imgW(:,:,:,i)=max(imgW(:,:,:,i),CTedge); %for each channel
       end
   end
end