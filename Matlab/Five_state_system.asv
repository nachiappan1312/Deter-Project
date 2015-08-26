% Sample system with 5 states%

% poles of the system are  -0.1,-0.2,-0.3,-0.4,-0.5
clc;
clear all;
s = tf('s');
T = 1/((s+0.1)*(s+0.2)*(s+0.3)*(s+0.4)*(s+0.5));
[num,den] = tfdata(T,'v');
[A,B,C,D] = tf2ss(num,den);
B = eye(5);
Sys = ss(A,B,C,D);

Q = eye(5);
R = 100*eye(5);
[K,S,E] = lqr(A,B,Q,R);
save('vars.mat','A','B','K')
tspan = [1:1:100];
%x0 = [0;1];
x0 = [0;0.526;0;0;0  ];
%x0 = zeros(4,1);
[t,x] = ode45(@(t,x) five_state_simulation(t,x),tspan,x0);
plot(t,x)



