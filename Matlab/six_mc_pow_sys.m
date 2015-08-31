clc;clear all;
close all;

%Result Folders

%Par_folder = input('Result Folder Name :','s');
strat1 = input('Strategy_1 Result Folder : ', 's')
mkdir('Results',strat1);
Strat1_folder = strcat('Results\',strat1);
strat2 = input('Strategy_2 Result Folder : ', 's')
mkdir('Results',strat2);
Strat2_folder = strcat('Results\',strat2);

ax_limits_1 = [0 12 -0.3 0.3];
ax_limits_2 = [0 12 -0.3 0.2];

% Machine Parameters
M1 = 1;M2 = 1;M3 = 1;M4 = 2;M5 = 2;M6 = 2;
M = diag([M1,M2,M3,M4,M5,M6]);

E1 = 1;E2 = 1;E3 = 1;E4 = 1;E5 = 1;E6 = 1;

%Transmission line parameters
x12=.01;x23=.01;x31=.01;x45=0.05;x64=0.05;x56=0.05; x26 = 0.05;


x = [0 0.01 0.01 0 0 0;0.01 0 0.01 0 0 0.05;0.01 0.01 0 0 0 0;0 0 0 0 0.05 0.05;0 0 0 0.05 0 0.05; 0 0.05 0 0.05 0.05 0];

del10 = 0.1;del20 = 0.11;del30 = 0.105;del40 = 0.21;del50 = 0.205;del60 = 0.211;
del = [0.1 0.11 0.105 0.21 0.205 0.211];

%Damping factors

d1=0;%0.5;
d2=0;%0.5;
d3=0;%0.5;
d4=0;%0.8;
d5=0;%0.8;
d6=0;%0.8

D = diag([d1,d2,d3,d4,d5,d6]);

%Machine Connectivity
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

Z = zeros(6,6);
I = eye(6,6);

%Construct continous time state space 

A = [Z I; inv(M)*L inv(M)*D];
B = [Z;I];
C = zeros(1,12);
C(1,9) = 1;
D = 0;

sys = ss(A,B,C,D);

%% Discrete Time System
Ts = 0.01; %sampling time
sys_d = c2d(sys,Ts,'zoh');
Q = eye(12,12);
R = eye(6,6);
[dK,dS,dE] = dlqr(sys_d.a,sys_d.b,Q,R);

time = 0:0.01:12;
s = size(time);

x =zeros(12,s(2)+1);
u = zeros(6,s(2)+1);
x0 = [del';zeros(6,1)];
x(:,1) = x0;

for k = 1:s(2)
    u(:,k) = -dK*x(:,k);
%Design the Discrete time state space
x(:,k+1) = sys_d.a*x(:,k)+sys_d.b*u(:,k);
end
J = calc_cost(x,u,Q,R)
figure;
subplot(2,3,1);
plot(time,x(1:12,1:s(2)))
axis manual
axis(ax_limits_1);
title('State Trajectory of Discrete-Time Power System');

subplot(2,3,4);
plot(time,u(:,1:s(2)))
axis manual
axis(ax_limits_2);
title('Control Inputs of Machines');
 
orig_disc_states = x;
%% Networked System
h = 0; %network propogation delay threshold


efun = @(t)expm(A*t)*B;
Ad = expm(A*Ts);
Bd1 = integral(efun,0,h,'ArrayValued',true);
Bd2 = integral(efun,h,Ts,'ArrayValued',true);

Z1 = zeros(6,12); Z2 = zeros(6,6);
Af = [Ad Bd2 ; Z1 Z2]; 
Bf = [Bd1; eye(6,6)];
%DLQR Parameters
Q1 = eye(12,12); Q2 = zeros(12,6); Q3 = zeros(6,12); Q4 = eye(6,6);

Q = [Q1 Q2;Q3 Q4];
R = eye(6,6);

[K] = vpa(dlqr(Af,Bf,Q,R),2);


z =zeros(18,s(2)+1);
u = zeros(6,s(2)+1);
z0 = [del';zeros(6,1);zeros(6,1)];
z(:,1) = z0;


%% Without security attack and just the delay is present
for k = 1:s(2)
    u(:,k) = -K*z(:,k);
    z(:,k+1) = Af*z(:,k)+Bf*u(:,k);
end
orig_net_states = z;
subplot(2,3,2);
plot(time,z(1:12,1:s(2)))
axis manual
axis(ax_limits_1);
title('State Trajectory of Discrete Time Power system with Network delays');

subplot(2,3,5);
plot(time,u(:,1:s(2)))
axis manual
axis(ax_limits_2);
title('Control Inputs of networked system');

%% Network simulation with the attacks

%Attack on the inter area nodes, 2-6 link is attacked.
% states del2,w2,del6 and w6 should be zeros for the attack period%
% strategy 1: assuming zero value for the missing states %

% choose a random time instant %

for i = 1:1:no_of_runs
    rand_time_inst = ceil(vpa(rand(1,1),2)*s(2)/2);
    run = 0;
    for k = 1:s(2)
    if k > rand_time_inst && k < rand_time_inst+3
    z([2 6 7 12],k) = 0;
    run = run +1;
    end
    u(:,k) = -K*z(:,k);
    %     for j = 1:6
    %         if u(j,k) >1
    %             u(j,k) = 1;
    %         end
    %     end
    z(:,k+1) = Af*z(:,k)+Bf*u(:,k);
    end

    sec_att_states = z;

    % subplot(2,3,3);
    % plot(time,z(1:12,1:s(2)))
    % axis manual
    % axis(ax_limits_1);
    % title('State Trajectory of Discrete Time Power system with security attack');
    % 
    % subplot(2,3,6);
    % plot(time,u(:,1:s(2)))
    % axis manual
    % axis(ax_limits_2);
    % title('Control Inputs of networked system with securtiy attack');
    % 
    % hold on
    %% Plots of each state
    figure;
    for i = [1:1:12]
    subplot(3,4,i)
    plot(time,orig_disc_states(i,1:s(2)),'r',time,orig_net_states(i,1:s(2)),'g',time,sec_att_states(i,1:s(2)),'b');
    %legend(' Std Discrete System','Sys with ntwrk delays', 'Sys with security attack');
    axis manual
    axis(ax_limits_1);
    title_str = sprintf('state %d',i);
    title(title_str);
    end
    stitle = sprintf('Strategy 1 \nIndividual States of the System \n Data loss was at %.2f seconds',double(vpa(time(rand_time_inst),3)));
    suptitle(stitle);
end

%Code to save the figures into the Result folder
h = get(0,'children');

for i = 1:length(h)
    saveas(h(i),[Strat1_folder '\fig' num2str(i)],'jpeg');
end

close all;
% choose a random time instant %
for i = 1:1:no_of_runs
    rand_time_inst = ceil(vpa(rand(1,1),2)*s(2)/2);
    run = 0;
    for k = 1:s(2)
    if k > rand_time_inst && k < rand_time_inst+6
    z([2 6 7 12],k) = z([2 6 7 12],k-1);
    run = run +1;
    end
    u(:,k) = -K*z(:,k);
    %     for j = 1:6
    %         if u(j,k) >1
    %             u(j,k) = 1;
    %         end
    %     end
    z(:,k+1) = Af*z(:,k)+Bf*u(:,k);
    end

    sec_att_states = z;

    % subplot(2,3,3);
    % plot(time,z(1:12,1:s(2)))
    % axis manual
    % axis(ax_limits_1);
    % title('State Trajectory of Discrete Time Power system with security attack');
    % 
    % subplot(2,3,6);
    % plot(time,u(:,1:s(2)))
    % axis manual
    % axis(ax_limits_2);
    % title('Control Inputs of networked system with securtiy attack');
    % 
    % hold on
    %% Plots of each state
    figure;
    for i = [1:1:12]
    subplot(3,4,i)
    plot(time,orig_disc_states(i,1:s(2)),'r',time,orig_net_states(i,1:s(2)),'g',time,sec_att_states(i,1:s(2)),'b');
    %legend(' Std Discrete System','Sys with ntwrk delays', 'Sys with security attack');
    axis manual
    axis(ax_limits_1);
    title_str = sprintf('state %d',i);
    title(title_str);
    end
    stitle = sprintf('Strategy 2 \nIndividual States of the System \n Data loss was at %.2f seconds',double(vpa(time(rand_time_inst),3)));
    suptitle(stitle);
end

%Code to save the figures into the Result folder
h = get(0,'children');
for i = 1:length(h)
    saveas(h(i),[Strat2_folder '\fig' num2str(i)],'jpeg');
end
