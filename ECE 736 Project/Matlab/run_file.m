close all;
clc;
[a,b,c,d] = linmod('Proj_Model');
sys = ss(a,b,c,d)
figure;
impulse(sys); 
figure;
step(sys)