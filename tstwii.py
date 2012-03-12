import maya.cmds as mc
import maya.mel as mm
import socket
import time
#HOST = '192.168.1.122' # The remote host

HOST = '127.0.0.1' # the local host
PORT = 5331 # The same port as used by the server
ADDR=(HOST,PORT)



def SendCommand():
    data=""
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect(ADDR)
    command = 'import maya.cmds as mc\n mc.polyCube()' # the commang from external editor to maya

    MyMessage = command
    client.send(MyMessage)
   # for x in range(0,120):
    for x in range(0,2):
        MSGLEN=1024
        msg = ''
        
        while msg.find("\n") ==-1:
                chunk = client.recv(1024)
                if chunk == '':
                    raise RuntimeError("socket connection broken")
                msg = msg + chunk
                
                
        data = msg
            
            
        posangx=data.find("angx");
        posouangx2=data.find(" ou",posangx+1);
        posangz=data.find("angz");
        posttx=data.find("ttx");
        if posangx!=-1 and posangz!=-1 and posouangx2!=-1:
            print "angx*******************"+data[posouangx2+9:posangz]
            print "angz*******************"+data[posangz+1:posttx]
            
            mm.eval("setAttr \"pPipe1.rotateY\""+data[posouangx2+9:posangz])
        #
        time.sleep(1) # wait 2.5 seconds
    client.close()
#  print 'The Result is %s'%data

