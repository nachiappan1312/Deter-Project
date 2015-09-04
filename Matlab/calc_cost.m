function [J,SU] = calc_cost(x,u,Q,R)
% Calculate the cost function J given
% x - states of the system
% u - input of the system
% Q, R - LQR constraints
J = 0;
SU = 0;
S = 0;
U = 0;
for i = 1:length(x)
    S = S+ x(:,i)'*Q*x(:,i);
    U = U+u(:,i)'*R*u(:,i);
end
J = S+U;
SU = S/U;
end