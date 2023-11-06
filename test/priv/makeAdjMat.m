function adjMat=makeAdjMat(rows,columns,options)

% make adjacency matrix based on number of rows and columns
% options.model: '2D' (default) / '3D' / 'connections'
%
% 2D model
% adjMat = 0 no neig
%          1 first neig
%          2 diagonal
%          3 second neig

% example for an electrode in x in a 2D model
%   0   0   3   0   0
%   0   2   1   2   0
%   3   1   x   1   3
%   0   2   1   2   0
%   0   0   3   0   0
%   0   0   0   0   0

% 3D model includes interlayer (Up-Down) connections

% same layer
%   2   1   2
%   1   x   1
%   2   1   2

% intra layer
%   6   5   6
%   5   4   5
%   6   5   6

% no 2nd neig connections are present (3)
% interlayer z-axis (up-down) connections marked whith 4
% interlayer z-axis diagonal (x-y)orthogonal connections marked whith 5
% interlayer diagonal-diagonal connections marked with 6
%
%  connections Model
%
%  1 horizontal connection
%  2 vertical connection


% A Blenkmann 2016 2018 2019

if nargin < 3
    options.model = '2D'; % default
end

switch options.model
    case {'2D','1D_fix'}
        N=rows*columns;
        adjMat=zeros(N);
        
        if min(rows,columns)~=1 % if is a grid
            ind=reshape(1:N,columns,rows)';
            %horizontal
            indH1=ind(:,1:end-1);
            indH2=ind(:,2:end);
            adjMat(sub2ind([N,N],indH1(:),indH2(:)))=1;
            adjMat(sub2ind([N,N],indH2(:),indH1(:)))=1;
            
            %vertical
            indV1=ind(1:end-1,:);
            indV2=ind(2:end,:);
            
            adjMat(sub2ind([N,N],indV1(:),indV2(:)))=1;
            adjMat(sub2ind([N,N],indV2(:),indV1(:)))=1;
            
            %diagonal
            indD1=ind(1:end-1,1:end-1);
            indD2=ind(2:end,2:end);
            adjMat(sub2ind([N,N],indD1(:),indD2(:)))=2;
            adjMat(sub2ind([N,N],indD2(:),indD1(:)))=2;
            
            
            indD11=ind(2:end,1:end-1);
            indD22=ind(1:end-1,2:end);
            adjMat(sub2ind([N,N],indD11(:),indD22(:)))=2;
            adjMat(sub2ind([N,N],indD22(:),indD11(:)))=2;
            
            % horizontal second neighbour
            
            indH1=ind(:,1:end-2);
            indH2=ind(:,3:end);
            adjMat(sub2ind([N,N],indH1(:),indH2(:)))=3;
            adjMat(sub2ind([N,N],indH2(:),indH1(:)))=3;
            
            %vertical second neighbour
            indV1=ind(1:end-2,:);
            indV2=ind(3:end,:);
            
            adjMat(sub2ind([N,N],indV1(:),indV2(:)))=3;
            adjMat(sub2ind([N,N],indV2(:),indV1(:)))=3;
            
            
        else %depth or strip
            adjMat(sub2ind([N,N],1:N-1,2:N))=1;
            adjMat(sub2ind([N,N],2:N,1:N-1))=1;
            
            % second neighbour
            adjMat(sub2ind([N,N],1:N-2,3:N))=3;
            adjMat(sub2ind([N,N],3:N,1:N-2))=3;
        end
        
    case '3D'
        adjMat_layer=zeros(rows*columns,rows*columns);
        adjMat_interlayer=zeros(rows*columns,rows*columns);
        
        kernelSameLayer = [2 1 2; 1 0 1; 2 1 2];
        kernelInterLayer = [6 5 6; 5 4 5; 6 5 6];
        
        %same layer
        for i=2:rows+1
            for j=2:columns+1
                tempLayer=zeros(rows+2,columns+2);
                tempLayer(i-1:i+1,j-1:j+1)=kernelSameLayer;
                tempLayer(1,:)=[];
                tempLayer(end,:)=[];
                tempLayer(:,1)=[];
                tempLayer(:,end)=[];
                tempLayer=(tempLayer');
                adjMat_layer((j-1)+ (i-2)*columns,:)=tempLayer(:)';
            end
        end
        
        %inter layer
        for i=2:rows+1
            for j=2:columns+1
                tempLayer=zeros(rows+2,columns+2);
                tempLayer(i-1:i+1,j-1:j+1)=kernelInterLayer;
                tempLayer(1,:)=[];
                tempLayer(end,:)=[];
                tempLayer(:,1)=[];
                tempLayer(:,end)=[];
                tempLayer=(tempLayer');
                adjMat_interlayer((j-1)+ (i-2)*columns,:)=tempLayer(:)';
            end
        end
        adjMat = [adjMat_layer, adjMat_interlayer; adjMat_interlayer, adjMat_layer ];
        

    case 'connections'
        
        N=rows*columns;
        
        adjMat=zeros(N);
        
        if min(rows,columns)~=1 % if is a grid
            ind=reshape(1:N,columns,rows)';
            
            %horizontal
            indH1=ind(:,1:end-1);
            indH2=ind(:,2:end);
            adjMat(sub2ind([N,N],indH1(:),indH2(:)))=1;
            adjMat(sub2ind([N,N],indH2(:),indH1(:)))=1;
            
            %vertical
            indV1=ind(1:end-1,:);
            indV2=ind(2:end,:);
            
            adjMat(sub2ind([N,N],indV1(:),indV2(:)))=2;
            adjMat(sub2ind([N,N],indV2(:),indV1(:)))=2;
        else          % depth or strip  
            if columns > rows
                adjMat(sub2ind([N,N],1:N-1,2:N))=1;
                adjMat(sub2ind([N,N],2:N,1:N-1))=1;
            else
                adjMat(sub2ind([N,N],1:N-1,2:N))=2;
                adjMat(sub2ind([N,N],2:N,1:N-1))=2;
            end
        end
        
end

% old 3D code
% if strcmp(options.model, '3D')
%      = adjMat;
%     adjMat_layer(adjMat_layer == 3) = 0 ; % no 2nd neig needed
%     vd1 = ones((rows*columns)-1,1); vd1(columns:columns:end)=0;
%     vd2 = ones((rows*columns)-columns,1);
%     %vd4 = ones((rows*columns)-columns,1)
%     adjMat_interlayer = 4*eye(size(adjMat_layer))+ 5*(diag(vd1,1)+diag(vd1,-1)+diag(vd2,columns)+diag(vd2,-columns));
%     adjMat = [adjMat_layer, adjMat_interlayer; adjMat_interlayer, adjMat_layer ];
% end