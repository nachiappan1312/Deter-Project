function  dx = five_state_simulation(t, x)
%    global ip;
%    global r;
%    global ctr;
   %inp_file = fopen('inp_file.txt');
   load('vars.mat','A','B','K')

% [t,x] = ode45(@(t,x) sys(t,x,server,inp_file),tspan,x0)
   format long
   dx = zeros(4,1);
   u = -K*x;    %K is calculated from lqr in Five_state_system script

%    s ='';
%    temp_str ='';
%    for i=1:length(x)
%        temp_str = num2str(x(i));
%        s = strcat(s,temp_str);
%        if i ~= length(x)
%            s = strcat(s,'//');
%        end
%    end
   
%    fwrite(server,s)
%    pause(0.005)
%    u_str = fscanf(inp_file,'%s')
%    if isempty(u_str)
%        ctr = ctr +1;
%        u_str = ip;
%    else
%        ip = u_str;

%    u_cell_array = strsplit(u_str,'//');
%    for i = 1:length(u_cell_array)
%        temp_char = char(u_cell_array(i));
%        u(i) = str2num(temp_char);
%    end
% 
%   r = r+1;
  %Non Linear state space Model
  dx = A*x +B*u
  %fclose(inp_file);
end