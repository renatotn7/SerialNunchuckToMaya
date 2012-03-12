import sys
import threading
import maya.mel as mel
import maya.utils as utils
import maya.cmds as cmds
import string
import os
import maya.cmds as mc
import maya.mel as mm
import socket
import time

HOST = '127.0.0.1'
PORT = 5331
ADDR=(HOST,PORT)
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
lasttime=180
fator = 0.4
class TimerObj(threading.Thread):
	def __init__(self, runTime, command,client):
		self.runTime = runTime
		self.client = client
		threading.Thread.__init__(self)
	
	def run(self):
	    if (fator*lasttime+1) ==self.runTime:
	        time.sleep(fator*lasttime+1)
	        client.close()
	    print '1x'
	    print 'tempo:'
	    print self.runTime
	    time.sleep(self.runTime)
	    print ((self.runTime-1)/fator)
	    print 'b'
	    data=''
	    MSGLEN=1024
	    msg = ''
	    print 'a'
	    while msg.find("\n") ==-1:
	        chunk = self.client.recv(1024)
	        if chunk == '':
	                sys.exit()
	                raise RuntimeError("socket connection broken")
	        msg = msg + chunk
	    data = msg
	    posangx=data.find("angx");
	    posouangx2=data.find(" ou",posangx+1);
	    posangz=data.find("angz");
	    posouangz2=data.find(" ou",posangz+1);
	    posttx=data.find("ttx");
	    if posangx!=-1 and posangz!=-1 and posouangx2!=-1:
	        print "angx*******************"+str((float(data[posouangx2+9:posangz])+180)%360)
	        print "angz*******************"+str(((float(data[posouangz2+9:posttx])-90)*2)%360)
	        mel.eval("setAttr \"pPipe1.rotateY\""+str((float(data[posouangx2+9:posangz])+180)%360))
	        mel.eval("setAttr \"pPipe1.rotateZ\""+str(((float(data[posouangz2+9:posttx])-90)*2)%360))
######################
#	functions
######################
def prepMelCommand(commandString):
	return cmds.encodeString(commandString).replace("\\\"","\"")

def startTimerObj(runTime, command,client):
	newTimerObj = TimerObj(runTime, command,client)
	newTimerObj.start()
	
if __name__=='__main__':
    try:
        client.connect(ADDR)
        print "Success connecting to "
        print HOST + " on port: " + str(PORT)
        time.sleep(5)
        print 'ok1'
        chunk = client.recv(1)
        print 'ok2'
        if chunk == '':
              raise RuntimeError("socket connection broken")
        for x in range(0,lasttime):
            startTimerObj(fator*x+1, x,client)
    except:
        print "Cannot connect to "
        print HOST + " on port: " + str(PORT)