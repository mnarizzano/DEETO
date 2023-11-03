% function [hayInter,q]=interseccionVecTri(A,B,C,p,direccionCorrecta)
%
% A B y C vectores q definen los vertices del triangulo
% p vector que quiero saber si pasa por el triangulo
% hayInter == true si hay interseccion
% q factor de escala para hallar el punto
% de interseccion P=q*p
%
% A. Blenkmann 2011

function [hayInter,q]=interseccionVecTri(A,B,C,p,direccionCorrecta)

if nargin<5
    direccionCorrecta=1;
end
    
CA=A-C; CB=B-C; AB=B-A;
% armo el sistema
%me paro en C
M=[CA CB -p];
    
%si el vector es paralelo al plano lo descarto
if rank(M)<3
    hayInter=false; q=0;
    return;
end

% solucion. P=q3*p pasa por el plano del triangulo. 

Q=M\-C;
q=Q(3);

% si q3<0 el vector tiene el sentido inverso
if q<0 && direccionCorrecta
    disp('cruce eliminado por direccion incorrecta')
    hayInter=false; q=0;
    return; 
end

% es el punto en el plano que quiero saber si pertenece al triangulo
P=q*p;

PA=A-P; PB=B-P; PC=C-P;

areaABC=norm(cross(CA,CB));

areaTriP= norm(cross(PB,PC)) +norm(cross(PC,PA)) +norm(cross(PA,PB));

%las areas son iguales si P esta dentro del triangulo
% disp(abs(areaABC - areaTriP))
%agrego 100eps para evitar errores numericos
if abs(areaABC - areaTriP) < 100*eps 
    hayInter=true;
else
    hayInter=false; q=0;
end
