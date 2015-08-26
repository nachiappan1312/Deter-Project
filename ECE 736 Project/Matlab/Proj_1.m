mdl_data % run the mdl first
Model = 'Proj_Model'
sim(Model) % Run the simulink model
[A,B,C,D] = linmod(Model);
sys = ss(A,B,C,D);
impulse(sys)
eig(A)