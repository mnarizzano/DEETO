function cuboidsInd = makeCouboidsInd(rows,cols)
% compute indices to vertices that form cuboids in a 3D grid model
% A Blenkmann 2019
k=1;
for j=1:rows-1
    for i=1:cols-1
        n = i + (j-1)*cols; %electrode number
        cuboidsInd(k,:) = [[n,n+1,n+cols, n+cols+1] , rows*cols + [n,n+1,n+cols, n+cols+1] ];
        k=k+1;
    end
end


%% plot
% % make ideal grid
% [xx,yy,zz]=meshgrid(0:rows-1,0:cols-1,0:1);
% y=xx(:); x=yy(:); z=zz(:);
% pos=[x,y,z];
%  
% % for n=1:length(pos)
% %     scatter3(pos(n,1),pos(n,2),pos(n,3)); hold on;
% %     xlim([0 8]); ylim([0 8])
% %     pause;    
% % end
% 
% figure;
% for n=1:size(cuboidsInd,1)
%     scatter3(pos(cuboidsInd(n,:),1), pos(cuboidsInd(n,:),2), pos(cuboidsInd(n,:),3))
%     xlim([0 8]); ylim([0 8])
%     pause     
% end
