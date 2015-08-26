from socket import *

sock = socket(AF_INET,SOCK_DGRAM)
addr = ('152.14.125.203',9091)
sock.bind(addr)
data = sock.recv(1024)
while data:
    inp_file = open('inp_file.txt','w')
    inp_file.write(data)
    inp_file.close()
    data = sock.recv(1024)
    
