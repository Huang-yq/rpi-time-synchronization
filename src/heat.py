import threading
import time

from gpiozero import CPUTemperature

lock = threading.Lock()
cpu = CPUTemperature()
cpuTemp = cpu.temperature

# A separate thread to get CPU temperature
def GetCpuTemp():
  global cpuTemp
  while(1):
    lock.acquire()
    cpuTemp = cpu.temperature
    print(cpuTemp)
    lock.release()
    time.sleep(1)

# Busy spin code to generate heat
def generateLoad():
  a = 12312445678
  a = a * a
  a += 1

# Busy spin thread
def BusySpin():
  # Target temperature = 50 C
  targetTemp = 50
  # PI control with 1 sec duty cycle
  totalT = 1.0
  kp = 1
  ki = 0.1
  cError = 0
  while(1):
    lock.acquire()
    error = targetTemp - cpuTemp
    lock.release()
    # PI control
    cError += error * ki
    if error > 0:
      error = error * kp + cError
      dutycycle = min(error / 10, 1.0)
      # duty cycle
      t = time.time()
      while(time.time() < t + dutycycle * totalT):
        generateLoad()
      time.sleep(totalT - dutycycle * totalT)
    else:
      time.sleep(totalT)

if __name__ == "__main__":
  t1 = threading.Thread(target=GetCpuTemp)
  t2 = threading.Thread(target=BusySpin)

  t1.start()
  t2.start()

