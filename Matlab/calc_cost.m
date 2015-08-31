function J = calc_cost(x,u,Q,R)
% Calculate the cost function J given
% x - states of the system
% u - input of the system
% Q, R - LQR constraints
J = 0;
for i = 1:length(x)
    J = J+ x(:,i)'*Q*x(:,i)+u(:,i)'*R*u(:,i);
end
end