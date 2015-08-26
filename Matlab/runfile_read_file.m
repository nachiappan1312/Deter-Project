clc;clear all;instrreset;
tic
global ip;
global r;
global ctr;
ctr=0;
r =1;
ip = '';
%ip = zeros(10000,2);
server = udp('152.14.125.203',9090,'LocalPort',9092);

fopen(server)
%fopen(client)
tspan = [1:1:100];
%x0 = [0;1];
x0 = [0;0.526;0;0];
%x0 = zeros(4,1);
[t,x] = ode45(@(t,x) power_sys_read_file(t,x,server),tspan,x0);
fwrite(server,'end')
delete(server);
ctr
toc
% J function

% for i = 1:length(x)
%     J(i) = x(i,:)*Q*x(i,:)' + ip(i,:)*R*ip(i,:)'
% end