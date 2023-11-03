function [FV2]=refinepatch(FV)
% This function "refinepatch" refines a triangular mesh with 
% a spline interpolated 4-split method.
%
%   [FV2] = refinepatch(FV,options)
%
% inputs,
%   FV : Structure containing a Patch, with
%        FV.vertices the mesh vertices
%        FV.face the mesh faces (triangles), rows with each 3 vertex indices
% outputs,
%   FV2 : Structure Containing the refined patch
%
%
% Reference:
%  The spline interpolation of the face edges is done by the 
%  Opposite Edge Method, described in: "Construction of Smooth Curves 
%  and Surfaces from Polyhedral Models" by Leon A. Shirman 
%
% How it works:
%  The tangents (normals) and velocity on the edge points of all edges 
%  are calculated. Which are  later used for b-spline interpolation when 
%  splitting the edges.
%
%  A tangent on an 3D line or edge is under defined and can rotate along 
%  the line, thus an (virtual) opposite vertex is used to fix the tangent and
%  make it more like a surface normal.
%
%  B-spline interpolate a half way vertices between all existing vertices
%  using the velocity and tangent from the edgepoints. After splitting a
%  new facelist is constructed
%
% Speed:
%  Compile the c-functions for more speed with:
%   mex vertex_neighbours_double.c -v;
%   mex edge_tangents_double.c -v;
%
% Example:
%
% X=[-0.5000;  0.5000;  0.0000;  0.0000];
% Y=[-0.2887; -0.2887;  0.5774;  0.0000];
% Z=[ 0.0000;  0.0000;  0.0000;  0.8165];
% FV.vertices=[X Y Z];
%
% FV.faces=[2 3 4; 4 3 1; 1 2 4; 3 2 1];
%
% figure, set(gcf, 'Renderer', 'opengl'); axis equal;
% for i=1:4
%   patch(FV,'facecolor',[1 0 0]);
%   pause(2);
%   [FV]=refinepatch(FV);
% end
%
% Function is written by D.Kroon University of Twente (February 2010)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2009, Dirk-Jan Kroon
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.



% Get the neighbour vertices of each vertice from the face list.
Ne=vertex_neighbours(FV);

% Calculate the tangents (normals) and velocity of all edges. Which is
% later used for b-spline interpolation and split of the edges
%
% A tangent on an 3D line or edge is under defined and can rotate along 
% the line, thus an (virtual) opposite vertex is used to fix the tangent and
% make it more like a surface normal.
V=FV.vertices; F=FV.faces;
[ET_table,EV_table,ETV_index]=edge_tangents(V,Ne);

% B-spline interpolate a half way vertices between all existing vertices
% using the velocity and tangent from above
[V,HT_index, HT_values]=make_halfway_vertices(EV_table,ET_table,ETV_index,V,Ne);

% Make new facelist
Fnew=makenewfacelist(F,HT_index,HT_values);

FV2.vertices=V;
FV2.faces=Fnew;



