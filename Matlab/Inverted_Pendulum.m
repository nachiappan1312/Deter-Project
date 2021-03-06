clear all 
close all
clc

M = 0.5;
m = 0.2;
b = 0.1;
I = 0.006;
g = 9.8;
l = 0.3;

p = I*(M+m)+M*m*l^2; %denominator for the A and B matrices

A1 = [0      1              0           0;
     0 -(I+m*l^2)*b/p  (m^2*g*l^2)/p   0;
     0      0              0           1;
     0 -(m*l*b)/p       m*g*l*(M+m)/p  0];
B1 = [     0;
     (I+m*l^2)/p;
          0;
        m*l/p];
C = [1 0 0 0;
     0 0 1 0];
D = [0;
     0];

states = {'x' 'x_dot' 'phi' 'phi_dot'};
inputs = {'u'};
outputs = {'x'; 'phi'};

sys_ss = ss(A1,B1,C,D,'statename',states,'inputname',inputs,'outputname',outputs);

%% Discrete Time System
Ts = 5/100;

sys_d = c2d(sys_ss,Ts,'zoh')

A = sys_d.a; B = sys_d.b; C = sys_d.c; D = sys_d.d;

%Q = C'*C
Q= eye(4,4);
R = 1;
[K] = dlqr(A,B,Q,R);

Ac = [(A-B*K)]; Bc = [B]; Cc = [C]; Dc = [D];

states = {'x' 'x_dot' 'phi' 'phi_dot'};
inputs = {'r'};
outputs = {'x'; 'phi'};

sys_cl = ss(Ac,Bc,Cc,Dc,Ts,'statename',states,'inputname',inputs,'outputname',outputs);
x0 = [0.25;0;0.1;0];

time = 0:Ts:15;
s = size(time);

%r =0.2*ones(size(t));
r = zeros(size(time));
%[y,t,x]=lsim(sys_cl,r,t,x0);

% state space simulation
z =zeros(4,s(2)+1);
ud = zeros(1,s(2)+1);
zd(:,1) = x0;
for k = 1:s(2)
    ud(:,k) = -K*zd(:,k);
%     for j = 1:6
%         if u(j,k) >1
%             u(j,k) = 1;
%         end
%     end
    zd(:,k+1) = A*zd(:,k)+B*ud(:,k);
end

subplot(2,2,1);
plot(time,zd(1,1:s(2)),'r',time,zd(3,1:s(2)))
title('State Trajectory of Discrete Time system');

subplot(2,2,3);
plot(time,ud(:,1:s(2)))
title('Control Inputs of discrete time system');


% subplot(2,2,1);
% [AX,H1,H2] = plotyy(t,y(:,1),t,y(:,2),'plot');
% set(get(AX(1),'Ylabel'),'String','cart position (m)')
% set(get(AX(2),'Ylabel'),'String','pendulum angle (radians)')
% title('Impulse Response with Digital LQR Control')



%% Networked System%%


h = 0.001 %network propogation delay threshold


efun = @(t)expm(A1*t)*B1;
Ad = expm(A1*Ts);
Bd1 = integral(efun,0,h,'ArrayValued',true);
Bd2 = integral(efun,h,Ts,'ArrayValued',true);

Z1 = zeros(1,4); Z2 = zeros(1,1);
Af = [A Bd2 ; Z1 Z2]; 
Bf = [Bd1; eye(1,1)];
%DLQR Parameters
Q1 = eye(4,4); Q2 = zeros(4,1); Q3 = zeros(1,4); Q4 = zeros(1,1)

Q = [Q1 Q2;Q3 Q4];
R = eye(1,1);

[nK] = vpa(dlqr(Af,Bf,Q,R),2)


z =zeros(5,s(2)+1);
u = zeros(1,s(2)+1);
z0 = [x0;zeros(1,1)];
z(:,1) = z0;
for k = 1:s(2)
    u(:,k) = -nK*z(:,k);
%     for j = 1:6
%         if u(j,k) >1
%             u(j,k) = 1;
%         end
%     end
    z(:,k+1) = Af*z(:,k)+Bf*u(:,k);
end

subplot(2,2,2);
plot(time,z(1,1:s(2)),'r',time,z(3,1:s(2)),'g',time,zd(1,1:s(2)),'b-',time,zd(3,1:s(2)),'y-')
title('State Trajectory of Discrete Time system with Network delays');

subplot(2,2,4);
plot(time,u(:,1:s(2)),'b',time,ud(:,1:s(2)),'g-')
title('Control Inputs of networked system');





