function  dx = power_sys_read_file(t, x,server)
   global ip;
   global r;
   global ctr;
   inp_file = fopen('inp_file.txt');

% [t,x] = ode45(@(t,x) sys(t,x,server,inp_file),tspan,x0)
   format long
   dx = zeros(4,1);
   % Machine Parameters
    M1 = 4.7;M2 = 4.7;
    E1 = 1;E2 = 0.98;
    x12 = 0.01;
    k12 = E1*E2/x12;
    K =[-0.403068278527916   0.455718526403815   0.072750403407375   0.067255905604533;0.063999385331140   0.067255905604533   0.352416905715348   0.374150309862755];
   
   % u = -K*x;    

   s ='';
   temp_str ='';
   for i=1:length(x)
       temp_str = num2str(x(i));
       s = strcat(s,temp_str);
       if i ~= length(x)
           s = strcat(s,'//');
       end
   end
   
   fwrite(server,s)
   pause(0.005)
   u_str = fscanf(inp_file,'%s')
   if isempty(u_str)
       ctr = ctr +1;
       u_str = ip;
   else
       ip = u_str;
%    if isempty(u_str)
%        u_str = ip
%    else
%        ip = u_str
       
%    if isempty(u_str)
%        u_str = '0//0'
   u_cell_array = strsplit(u_str,'//');
   for i = 1:length(u_cell_array)
       temp_char = char(u_cell_array(i));
       u(i) = str2num(temp_char);
   end

  r = r+1;
  %Non Linear state space Model
  dx(1) = x(2);
  dx(2) = 1/M1*(u(1)-k12*sin(x(1)-x(3)));
  dx(3) = x(4); 
  dx(4) = 1/M2*(u(2)-k12*sin(x(3)-x(1))); 
  
  fclose(inp_file);
end