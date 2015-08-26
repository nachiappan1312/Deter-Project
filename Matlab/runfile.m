clc;clear all;instrreset;
tic
global ip;
global r;
r =1;
ip = 0;
%ip = zeros(10000,2);
server = udp('152.14.125.203',9090,'LocalPort',9091);
%server = udp('10.138.37.223',9090,'LocalPort',9091);
%client = udp('192.168.0.12',9091,'LocalPort',9090);
fopen(server)
%fopen(client)
tspan = [1:1:100];
%x0 = [0;1];
x0 = [0;0.526;0;0];
%x0 = zeros(4,1);
[t,x] = ode45(@(t,x) power_sys(t,x,server),tspan,x0);
fwrite(server,'end')
delete(server);
toc
% J function

% for i = 1:length(x)
%     J(i) = x(i,:)*Q*x(i,:)' + ip(i,:)*R*ip(i,:)'
% end