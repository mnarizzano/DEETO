function w = lanwin(n)
% LANWIN Symmetric Lanczos window
%    LANWIN(N) returns a symmetric N point Lanczos window,
%    26.4 dB, NBW 1.3 bins, first zero at +/-1.6 bin.
%  Joe Henning - Jan 2014
if (n == 1)
   w = 1;
   return
end
 
if ~rem(n,2)
   % Even length window
   m = n/2;
   x = (0:m-1)'/(n-1);
   w = sinc(2*x - 1);
   w = [w; w(end:-1:1)];
else
   % Odd length window
   m = (n+1)/2;
   x = (0:m-1)'/(n-1);
   w = sinc(2*x - 1);
   w = [w; w(end-1:-1:1)];
end