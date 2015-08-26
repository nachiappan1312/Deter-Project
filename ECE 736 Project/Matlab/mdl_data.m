clear all
close all
clc
M1 = 1;M2 = 1;M3 = 1;M4 = 2;M5 = 2;M6 = 2;
E1 = 1;E2 = 1;E3 = 1;E4 = 1;E5 = 1;E6 = 1;


x12=.01;x23=.01;x31=.01;
x45=0.05;x64=0.05;x56=0.05;
x26 = 0.05;

del10 = 0.1;del20 = 0.11;del30 = 0.105;del40 = 0.21;del50 = 0.205;del60 = 0.211;

% d1=0;%0.5;
% d2=0;%0.5;
% d3=0;%0.5;
% d4=0;%0.8;
% d5=0;%0.8;
% d6=0;%0.8;

d1=0.5;
d2=0.5;
d3=0.5;
d4=0.8;
d5=0.8;
d6=0.8;

K12 = E1*E2/x12;K21 = K12;
K13 = E1*E3/x31;K31 = K13;
K23 = E3*E2/x23;K32 = K23;
K45 = E4*E5/x45;K54 = K45;
K46 = E4*E6/x64;K64 = K46;
K56 = E5*E6/x56;K65 = K56;
K26 = E6*E2/x26;K62 = K26;