clc;clear all;
close all;

% Machine Parameters
M1 = 1;M2 = 1;M3 = 1;M4 = 2;M5 = 2;M6 = 2;
E1 = 1;E2 = 1;E3 = 1;E4 = 1;E5 = 1;E6 = 1;

%Transmission line parameters
x12=.01;x23=.01;x31=.01;
x45=0.05;x64=0.05;x56=0.05;
x26 = 0.05;


M = diag([M1,M2,M3,M4,M5,M6]);
x12=.01;x23=.01;x31=.01;
x45=0.05;x64=0.05;x56=0.05;
x26 = 0.05;
x = [0 0.01 0.01 0 0 0;0.01 0 0.01 0 0 0.05;0.01 0.01 0 0 0 0;0 0 0 0 0.05 0.05;0 0 0 0.05 0 0.05; 0 0.05 0 0.05 0.05 0];
del10 = 0.1;del20 = 0.11;del30 = 0.105;del40 = 0.21;del50 = 0.205;del60 = 0.211;
del = [0.1 0.11 0.105 0.21 0.205 0.211];

% d1=0.5;
% d2=0.5;
% d3=0.5;
% d4=0.8; 
% d5=0.8;
% d6=0.8;

d1=0;%0.5;
d2=0;%0.5;
d3=0;%0.5;
d4=0;%0.8;
d5=0;%0.8;
d6=0;%0.8;

D = diag([d1,d2,d3,d4,d5,d6])

T =[0 1 1 0 0 0; 1 0 1 0 0 1;1 1 0 0 0 0;0 0 0 0 1 1;0 0 0 1 0 1;0 1 0 1 1 0];
%Construct Laplacian
L = zeros(6,6);
for i = 1:6
    for j = 1:6
        if (T(i,j) ==1)
            if(i~=j)
              L(i,j) = cos(del(i)-del(j))/x(i,j);                   
            end
        else
           L(i,j) = 0;
        end
    end
end

for i = 1:6
    for j= 1:6
        if(i~=j)
            L(i,i) = L(i,i)-L(i,j);
        end
    end
end

% eigL = eig(L)
% eiginvML = eig(inv(M)*L)

Z = zeros(6,6)
I = eye(6,6)

%Construct system
A = [Z I; inv(M)*L inv(M)*D]
B = [zeros(6,1);[1;0;0;0;0;0]]
C = zeros(1,12)
C(1,9) = 1
D = 0

sys = ss(A,B,C,D)
sys_d = c2d(sys,0.1);
x0 = [del';zeros(6,1)];
Q = 100*eye(12,12);
R = 100;
K = dlqr(sys_d.a,sys_d.b,Q,R)
Acl = (sys_d.a-sys_d.b*K)
t = 0:0.1:100;
s = size(t)
u = zeros(s(2),1);
x = zeros(12,s(2)+1);
x(:,1) = x0;
Acl = sys_d.a-sys_d.b*K
for k = 1:s(2)
    
    x(:,k+1) = (Acl)*x(:,k);
end

figure;
plot(t,x(1:6,1:s(2)))
hold on;
figure;
plot(t,x(7:12,1:s(2)))
% lsim(sys_d,u,t,x0)
% lsiminfo(sys_d,u,t,x0)
% % 
% eig(A)
% impulse(sys)