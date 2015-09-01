clc;clear all;
close all;
tic;
%Inputs
strat1 = 'Sep1_Strat1_Run1';
strat2 = 'Sep1_Strat2_Run1';
max_duration = 1; % duration of attack
duration = 1;
no_of_runs = 10; % 10 different time instants
res_file = 'Results_Sheet.csv';
%Result Folders

%Par_folder = input('Result Folder Name :','s');
%strat1 = input('Strategy_1 Result Folder : ', 's')
mkdir('Results',strat1);
Strat1_folder = strcat('Results\',strat1);
%strat2 = input('Strategy_2 Result Folder : ', 's')
mkdir('Results',strat2);
Strat2_folder = strcat('Results\',strat2);
%duration = input('Duration of Attack: ');
%no_of_runs = input('Number of Runs: ');

tot_no_of_runs = no_of_runs*max_duration;
% Output matrix to excel sheet%
Result_Matrix = zeros(tot_no_of_runs,5); % Entire Result Matrix

Output_Matrix = zeros(5,no_of_runs);   % n x 5 output matrix for each duration 
Output_Matrix(1,:) = 1:1:no_of_runs;   % col 1 - No of  runs 
Time_of_attack =  0.1:(0.8-0.1)/(no_of_runs-1):0.8;  %Time of attack is equally spread among 0.1 and 0.8
Output_Matrix(2,:) = Time_of_attack; % Col 2 - Time of attack
duration_of_attack = duration *ones(no_of_runs,1);  % Duration of attack - No of samples
Output_Matrix(3,:) = duration_of_attack; % Col 3 - Duration of attack
Strategy_1_J = zeros(no_of_runs,1); 
Output_Matrix(4,:) = Time_of_attack; % Col 4 - Strategy 1 quadratic cost
Strategy_2_J = zeros(no_of_runs,1); 
Output_Matrix(4,:) = Time_of_attack; % Col 5 - Strategy 2 quadratic cost

%Figure axis limit properties
ax_limits_1 = [0 12 -0.3 0.3];
ax_limits_2 = [0 12 -0.3 0.2];

% Machine Parameters
M1 = 1;M2 = 1;M3 = 1;M4 = 2;M5 = 2;M6 = 2;

M2 = 0.1; % Reduced Inertia
M = diag([M1,M2,M3,M4,M5,M6]);

E1 = 1;E2 = 1;E3 = 1;E4 = 1;E5 = 1;E6 = 1;

%Transmission line parameters
x12=.01;x23=.01;x31=.01;x45=0.05;x64=0.05;x56=0.05; x26 = 0.05;


x = [0 0.01 0.01 0 0 0;0.01 0 0.01 0 0 0.05;0.01 0.01 0 0 0 0;0 0 0 0 0.05 0.05;0 0 0 0.05 0 0.05; 0 0.05 0 0.05 0.05 0];

del10 = 0.1;del20 = 0.11;del30 = 0.105;del40 = 0.21;del50 = 0.205;del60 = 0.211;
del = [0.1 0.11 0.105 0.21 0.205 0.211];

%Damping factors

d1=0; d2=0; d3=0; d4=0; d5=0; d6=0;

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

% Dynamic simulation of the power system
for k = 1:s(2)
    u(:,k) = -dK*x(:,k);
    %Design the Discrete time state space
    x(:,k+1) = sys_d.a*x(:,k)+sys_d.b*u(:,k);
end
J = calc_cost(x,u,Q,R)
figure;
subplot(2,2,1);
plot(time,x(1:12,1:s(2)))
axis manual
axis(ax_limits_1);
title('States of Discrete-Time Power System');

subplot(2,2,3);
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
subplot(2,2,2);
plot(time,z(1:12,1:s(2)))
axis manual
axis(ax_limits_1);
title('State of Discrete Time Power system with Network delays');

subplot(2,2,4);
plot(time,u(:,1:s(2)))
axis manual
axis(ax_limits_2);
title('Control Inputs of networked system');

%Code to save the figures into the Result folder
print([Strat1_folder '\state_trajectory'],'-dpng','-r300');
close all

%% Network simulation with the attacks

%Attack on the inter area nodes, 2-6 link is attacked.
% states del2,w2,del6 and w6 should be zeros for the attack period%
% strategy 1: assuming zero value for the missing states %
%% Strategy 1 - Using zero value for all the missed states
% choose a random time instant %
for duration = 1:max_duration
    for j = 1:1:no_of_runs
        %rand_time_inst = ceil(vpa(rand(1,1),2)*s(2)/2);
        rand_time_inst = ceil(Time_of_attack(j)*s(2));
        for k = 1:s(2)
            if k > rand_time_inst && k < rand_time_inst+duration+1
                z([2 6 7 12],k) = 0;
            end
            u(:,k) = -K*z(:,k);
            z(:,k+1) = Af*z(:,k)+Bf*u(:,k);
        end

        sec_att_states = z;

        %% Plots of each state

        % Calcualate the Cost function J
        J = calc_cost(z,u,Q,R);
        Strategy_1_J(j) = J; 
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
        stitle = sprintf('Strategy 1 \nIndividual States of the System \n Data loss was at %.2f seconds\n Duration of Attack is %d. The Quadratic Cost J = %d.',double(vpa(time(rand_time_inst),3)),duration,J);
        suptitle(stitle);
        %Code to save the figures into the Result folder
        print([Strat1_folder '\fig' num2str(j)],'-dpng','-r300');
        close all
    end

    %% Strategy 2 - Using the sample from previous time instant
    % choose a random time instant %
    for j = 1:1:no_of_runs
        %rand_time_inst = ceil(vpa(rand(1,1),2)*s(2)/2);
        rand_time_inst = ceil(Time_of_attack(j)*s(2));
        for k = 1:s(2)
            if k > rand_time_inst && k < rand_time_inst+duration+1
                z([2 6 7 12],k) = z([2 6 7 12],k-1);
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
        %Calcuate the Quadratic cost
        J = calc_cost(z,u,Q,R);
        Strategy_2_J(j) = J;
        Time_of_attack(j) = vpa(time(rand_time_inst)); 


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
        stitle = sprintf('Strategy 2 \nIndividual States of the System \n Data loss was at %.2f seconds\n Duration of Attack is %d. The Quadratic Cost J = %d.',Time_of_attack(j),duration,J);
        suptitle(stitle);

        %Code to save the figures into the Result folder
        print([Strat2_folder '\fig' num2str(j)],'-dpng','-r300');
        close all
    end

    Output_Matrix(2,:) = Time_of_attack; % Col 2 - Time of attack
    Output_Matrix(3,:) = duration*ones(no_of_runs,1); % Col 2 - Time of attack
    Output_Matrix(4,:) = Strategy_1_J; % Col 4 - Strategy 1 quadratic cost
    Output_Matrix(5,:) = Strategy_2_J; % Col 5 - Strategy 2 quadratic cost
    Output_Matrix = Output_Matrix';
    if Result_Matrix == 0
        Result_Matrix = Output_Matrix;
    else
        Result_Matrix = [Result_Matrix;Output_Matrix];
    end
end
Header = {'Run','Time of Attack', 'Duration of Attack', 'Strategy 1 J', 'Strategy 2 J'};

fid = fopen(res_file,'w');
fprintf(fid,'%s,',Header{1,1:end-1});
fprintf(fid,'%s\n',Header{1,end-1});
fclose(fid);
dlmwrite(res_file,Output_Matrix,'-append');
toc;
