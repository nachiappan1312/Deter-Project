A = diag([1 3 5 6]);
B = zeros(length(A),length(A));
for i = 1:length(A)/2
    B(i,:) = A(2*i-1,:);
end
for i = 1:length(A)/2
    B(i+2,:) = A(2*i,:);
end