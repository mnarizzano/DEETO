function createVTK(filename, vertices, faces)
%createVTK Write a 3D mesh to a VTK file.
%   createVTK(FILENAME, VERTICES, FACES) writes the 3D mesh defined by
%   the vertices and faces matrices to a VTK file specified by FILENAME.

% Open the output file for writing
fid = fopen(filename, 'w');

% Write the VTK header
fprintf(fid, '# vtk DataFile Version 2.0\n');
fprintf(fid, 'Mesh data\n');
fprintf(fid, 'ASCII\n');
fprintf(fid, 'DATASET POLYDATA\n');

% Write the vertices
fprintf(fid, 'POINTS %d float\n', size(vertices, 1));
fprintf(fid, '%f %f %f\n', vertices');

% Write the faces
fprintf(fid, 'POLYGONS %d %d\n', size(faces, 1), size(faces, 1) * 4);
fprintf(fid, '3 %d %d %d\n', faces' - 1);

% Close the output file
fclose(fid);
end