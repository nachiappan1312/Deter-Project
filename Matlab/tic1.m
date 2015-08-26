% clear all;instrreset;
% server = udp('152.14.125.203',9090,'LocalPort',9091);
% fopen(server);
tic
fwrite(server,'end');
fscanf(server,'%s');
toc
% delete(server);
