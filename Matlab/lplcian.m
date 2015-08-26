function A = lplcian(n)
% Generates sparse 2D discrete Laplacian matrix of dimension n^2.  
% Symmetric approximate minimum degree (symamd) ordering is used.
% This is the canonical example of a large, sparse matrix.
% This code works in both MATLAB and Octave.  If you have MATLAB,
% you can generate this matrix by a simpler code using delsq and numgrid.

r = zeros(1,n); % zero vector with n entries
r(1:2) = [2, -1];
T = toeplitz(r); % world famous Toeplitz matrix
E = speye(n); % nxn identity matrix, stored sparsely
A = kron(T,E) + kron(E,T); % Kronecker sum.
% A is the discrete Laplacian in the standard ordering.
p = symamd(A); % permutation for the symamd ordering
A = A(p,p); % discrete Laplacian in symamd ordering

% How to understand this code.  Take n = 5 or some other small 
% value.  Then execute the lines of the code one by one from
% the command line and see what they produce.  You can also 
% type 'help toeplitz', 'help kron', etc. (or go to MATLAB or
% Octave help to get information about these commands.)