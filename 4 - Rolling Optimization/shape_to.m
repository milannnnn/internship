function [ X_new ] = shape_to( X, N )
%SHAPE_TO Reshapes a 2D matrix to a matching 3D matrix (defined in Julia)
%   
%   X     - original 2D matrix t x s
%   X_new - reshaped 3D matrix (t/N)x N x s
%   
%   N = T_EMS / T_intra
%   t = 1 day / T_intra
%   s = num. of scenarios

if nargin<2
    N = 10;
end

[t,s] = size(X);

X_new = zeros(t/N,N,s);

for k=1:s
    X_new(:,:,k) = reshape(X(:,k),N,t/N)';
end

end

