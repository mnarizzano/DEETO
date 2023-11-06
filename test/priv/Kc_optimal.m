function Kc_optimal_q = Kc_optimal(M1_q,n_elec_q,overlap_q,model,type)
% optimal Kc interpolation given inter-electrode distance (M1_q in mm), number of electrodes (n_elec_q) and
% presence of overlap (overlap_q). Optimal values are based on simulations.
% data for 16x16 is a weak estimation
% _q = query
% model =  '2D' / '3D'
% type = 'grid', 'strip', 'depth'
% A Blenkmann 2020

if strcmp(model,'3D') & strcmp(type,'grid') 
    
    M1 = [3 5 10];
    n_electrodes = [2*4 4*4 4*8 8*8 8*16 16*16];
    overlap_value = [0 1];
    
    %mesh grid representation
    [M1_grid,ne_grid,ov_grid] = meshgrid(M1,n_electrodes,overlap_value);
    
    
    % optimal values defined by simulations
    % Cols are M1 (3 5 10)
    % rows are n_electrodes (8 16 32 64 128 256)
    % Third dim ( no overlap , overlap)
    Kc_optimal_map = cat(3,[ 6 7  7;           %8  %no overlap
        6 7  9;          %16
        7 7  9;          %32
        8 8 10;          %64
        8 9 10;         %128
        8 9 10],...     %256
        [5 6 6;         %8 %overlap
        6 6 7;          %16
        7 7 8;          %32
        7 8 8;         %64
        8 9 9;         %128
        8 8 9]);       %256

    % example query points  
    % overlap_q=0;
    % n_elec_q=16;
    % M1_q=5;
    Kc_optimal_q = interp3(M1_grid,ne_grid,ov_grid,Kc_optimal_map,M1_q,n_elec_q,overlap_q,'makima'); %modified Akima cubic interpolation. The algorithm avoids excessive local undulations. 
    
    Kc_optimal_q =round( power(10,Kc_optimal_q),5); %round to 5 decimal points
    
    % figure
    % slice(M1_grid,ne_grid,ov_grid,Kc_optimal_map,[3 5 10],[],[0 1]);
    % shading interp; xlabel('M1'); ylabel('ne'); zlabel('ov');
    
elseif strcmp(model,'3D') & strcmp(type,'strip') 
    
    M1 =  [5 10];
    n_electrodes = [4 6 8];
    overlap_value = [0 1];
    
    %mesh grid representation
    [M1_grid,ne_grid,ov_grid] = meshgrid(M1,n_electrodes,overlap_value);
    
   
    % optimal values defined by simulations
    % Cols are M1 (5 10)
    % rows are n_electrodes (4 6 8)
    % Third dim ( no overlap , overlap)
    
    Kc_optimal_map = cat(3,[ 4 5;           %4  %no overlap
        6 7;          %6
        7 7],...     %8
        [4 6;         %4 %overlap
        6 7;         %6
        7 7]);       %8

    % example query points
    % overlap_q=0;
    % n_elec_q=6;
    % M1_q=5;
    Kc_optimal_q = interp3(M1_grid,ne_grid,ov_grid,Kc_optimal_map,M1_q,n_elec_q,overlap_q,'makima');
    
    Kc_optimal_q =round( power(10,Kc_optimal_q),5); %round to 5 decimal points
    
    % figure
    % slice(M1_grid,ne_grid,ov_grid,Kc_optimal_map,[3 5 10],[],[0 1]);
    % shading interp; xlabel('M1'); ylabel('ne'); zlabel('ov');
    
elseif (strcmp(model,'2D') | strcmp(model,'1D_fix'))  & strcmp(type,'depth') 
    
    M1 = [3 5 10];
    n_electrodes = [4 8 10 15 18];
    
    %mesh grid representation
    [M1_grid,ne_grid] = meshgrid(M1,n_electrodes);
    
    
    % optimal values defined by simulations
    % Cols are M1 (3 5 10)
%     % rows are n_electrodes (4 8 10 15 18)

    Kc_optimal_map = cat(3,[ 3 2 2; %4
        2 2 3;         %82
        2 2 3;         %10
        2 3 3;         %15 
        2 3 3]);       %18 
    
    % example query points
    % overlap_q=0;
    % n_elec_q=16;
    % M1_q=5;
    Kc_optimal_q = interp2(M1_grid,ne_grid,Kc_optimal_map,M1_q,n_elec_q,'makima');
    Kc_optimal_q = round(power(10,Kc_optimal_q),5); % round to 5 decimal points
    
    % figure
    % slice(M1_grid,ne_grid,ov_grid,Kc_optimal_map,[3 5 10],[],[0 1]);
    % shading interp; xlabel('M1'); ylabel('ne'); zlabel('ov');
end