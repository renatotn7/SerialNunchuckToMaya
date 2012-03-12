import sys
import time
import threading
import maya.mel as mel
import maya.utils as utils
import maya.cmds as cmds
import string

######################
#	classes
######################

class TimerObj(threading.Thread):
	def __init__(self, runTime, command):
		self.runTime = runTime
		self.command = command
		threading.Thread.__init__(self)
	def run(self):
		time.sleep(self.runTime)
		utils.executeDeferred(mel.eval, prepMelCommand(self.command))

######################
#	functions
######################
def prepMelCommand(commandString):
	return cmds.encodeString(commandString).replace("\\\"","\"")

def startTimerObj(runTime, command):
	newTimerObj = TimerObj(runTime, command)
	newTimerObj.start()
	
	

if __name__=='__main__':
    for x in range(0,100):
        startTimerObj((0.5*x)+0.1, "print(\"Times Up!\n\");");


	


	#executa a cada 0.6 segundos
