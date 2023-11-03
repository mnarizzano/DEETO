function pos=projection1D(G,p)
n=length(G);
%busco los mas cercanos
for i=1:n
    [m,idx]=min(sqrt(sum( (G-repmat(p(i,:),n,1)).^2, 2 )));
    pos(i,:)=G(idx,:);
end