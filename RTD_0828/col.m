function A = col(B)
% A = col(B)
% reshape a matrix into one column
A = reshape(B,prod(size(B)),1);
