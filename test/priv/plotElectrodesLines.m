function c=plotElectrodesLines(X,rows,columns,color)
% plot lines (as small cylinders) between neighbor electrodes
% X : electrodes coordinates (electrodes x 3)
% color : [r g b] format
% c : handle to line surfaces
% Note:  can be time consuming to plot many

% TODO: consider updating plots instead of cleaning and making new objects
% cosinder just ploting normal lines instead of cylinders

% A Blenkmann 2016

% consider using this code instead
% r = triu(adjMat)>0;
% for i=1:length(r)
%     for j=1:length(r)
%         if r(i,j)
%             s = pos(i,:); e = pos(j,:); l = [s ; e];
%             line(l(:,1),l(:,2),l(:,3));
%         end
%     end
% end


if min(rows,columns)~=1 % if is a grid
    ind=reshape(1:size(X,1),columns,rows)';
    %horizontal
    indH1=ind(:,1:end-1);
    indH2=ind(:,2:end);
    s=X(indH1,:);
    e=X(indH2,:);
    
    %[c1,~,~]=Cyl(X(indH1,:),X(indH2,:),.3,6,color,1,0);
    for i=1:size(s,1)
        l=[s(i,:);e(i,:)];
        c1(i)=line(l(:,1),l(:,2),l(:,3),'Color',color,'LineWidth',2);
    end
    %vertical
    indV1=ind(1:end-1,:);
    indV2=ind(2:end,:);
    s=X(indV1,:);
    e=X(indV2,:);
    %[c2,~,~]=Cyl(X(indV1,:),X(indV2,:),.3,6,color,1,0);
    for i=1:size(s,1)
        l=[s(i,:);e(i,:)];        
        c2(i)=line(l(:,1),l(:,2),l(:,3),'Color',color,'LineWidth',2);    
    end
    c=[c1 c2];
    
else %depth or strip
    s=X(1:end-1,:);
    e=X(2:end,:);
    %[c,~,~]=Cyl(X(1:end-1,:),X(2:end,:),.3,6,color,1,0);
    for i=1:size(s,1)
        l=[s(i,:);e(i,:)];        
        c(i)=line(l(:,1),l(:,2),l(:,3),'Color',color,'LineWidth',2);
    end
end

