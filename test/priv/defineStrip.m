function  pos=defineStrip(linFun,nElec,limits)

% define the position of electrodes given a 3rd order polynimial
% function. The electrodes are defined with even space in between limits
% Works in a 2D space

% y=linFun(x)  3er order interpolation
% linFun(x)=p1*x^3 + p2*x^2 + p3*x + p4
% nElec is the number of electrodes
% limits [xmin , xmax]
% pos(x,y) 
global debugging

N=1000; %number of points to split the curve


% arc Fun to integrate
arcFun = @(x) (sqrt( 1 + (3*linFun.p1*x.^2 + 2*linFun.p2*x + linFun.p3).^2 ));

% steps
steps=linspace(limits(1),limits(2),N);

% partial integration
partialS=zeros(1,N);
for i=1:N-1
    partialS(i) = integral(arcFun,steps(i),steps(i+1));
end

% cumulative integration
S=cumsum(partialS);


% define electrodes as a portion of the complete line integral
nSegments=nElec-1;

arcL=S(end); %total Lenght of the arc

% get the index of the partial lengths 
for i=1:nElec;   
    [~, index(i)]= min(abs (S -  (i - 1) * arcL / nSegments));
end

% compute output cordinates in 2D space
x=steps(index)';
y=linFun(x);
pos=[x,y];

if debugging
    figure;
    plot(linFun); hold on;
    scatter(pos(:,1),pos(:,2));
    axis image
end


