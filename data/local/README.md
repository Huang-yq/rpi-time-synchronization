## Data Dictionary

0.  0510_1719 - Baseline

1.  0510_2128 - isolcpu only   

2.  0511_0228 - CPU Affinity Assigned 
	       GM: (1 - GPSD, 2 - Chrony, 3 - PTP + PHC)
	       Cl: (2 - PTP, 3 - PHC)			

3.  0511_1120 - CPU Affinity + PPS IRQ Steering
               GM: (1 - GPSD, 2 - Chrony, 3 - PTP + PHC), PPS IRQ 184 to GPSD
               Cl: (2 - PTP, 3 - PHC)

4.  0511_1945 - CPU Affinity + PPS IRQ Steering + Normal Thermal Controls
	       GM: (1 - GPSD, 2 - Chrony, 3 - PTP + PHC), PPS IRQ 184 to GPSD, + Normal Thermal Controls
               Cl: (2 - PTP, 3 - PHC) + Normal Thermal Controls

5.  0511_2356 - CPU Affinity + PPS IRQ Steering to two cores + No Thermal Controls
	       GM: (1 - GPSD, 2 - Chrony, 3 - PTP + PHC), PPS IRQ 184 to GPSD, Chrony
	       Cl: (2 - PTP, 3 - PHC)

6.  0512_0831 - Round 2 - isolcpu only

7.  0512_1417 - CPU Affinity + All Possible IRQ Steering + PPS Core
               GM: (1 - PPS Steered, 2 - GPSD + Chrony, UART Steered, 3 - PTP + PHC, eth0 Steered)
               Cl: (1 - eth0 Steered, 2 - PTP, 3 - PHC) 
               All other possible IRQ steered to 0. 

8.  0512_1948 - Optimization 7 + P2P/L2

9.  0512_2344 - Optimization 8 + clockServo = Linreg

10. 0513_0825 - Optimization 9 + heat.py 

11. 0513_1605 - Optimization 7 + heat.py
