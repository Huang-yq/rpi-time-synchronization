**Data with 2335 file name** --> First baseline Data

**Data with 0945 file name** --> Second baseline Data

**Data with 1855 file name** --> Data with isolcpus on the client

**Data with 2348 file name** --> Data with isolcpus and cpu Affinity Assigned Grandmaster: (1 - GPSD, 2 - Chrony, 3 - PTP) Client: (2 - PTP, 3 - PHC)

**Data with 1555 file name** --> We did cpu affinity like before in trial 4, all IRQ possible were steered to CPU 0, while eth0 were steered to core to cpu 1.

**Data with 2011 file name** --> We did all the IRQ steering like in trial 5, but this time we used CPU affinity to pin Chrony to core 1,GPSD to CPU core 2, PTP4l to core 3 (Client CPU affinity stayed the same), and we added Idle CPU Busy Spin to generate heat for thermal stability.