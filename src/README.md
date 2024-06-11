
## Scripts

If scripts doesn't run, try `chmod 777 <script>` to add executing permission.

### Isolating CPU

	Run `sudo ./isolate_cpu`.
	Then reboot.

### Recompiling guide for GPSd and LinuxPTP

GPSD:

Ref: https://gpsd.io/building.html

Before building GPSd from source we need to purge apt-installed GPSd from RPi because multiple versions of gpsd can not co-exist on the same system.

```
sudo apt purge gpsd
# WARNING: "purge" removes both package and config files. Back up before you purge!
```

Then install the required packages if necessary:

```
sudo apt-get install scons libncurses5-dev python-dev pps-tools
sudo apt-get install git-core
```

```
./recompile_gpsd.sh
```


To undo this change:
```
make uninstall
```


Linux PTP:

```
./recompile_linuxptp.sh
```

To undo this change (didn't test, not from official guide):
```
scons uninstall
```


### Pinning processes

	```
	./run_on_isolated_cpu.sh <cpu core (1,2,or 3)> <any executable>
	```
    To verify that it's running on an isolated CPU:
	By defaults we set `CPU 3` to the isolated CPU
	```
	top
	```
	Now press `f`, use arrow key to navigate and find `P = Last Used CPU (SMP)`.

	Press right arrow key to highlight it. Now you should be able to move it with up/down arrow key.

	Move it up between `TIME+` and `COMMAND`, press left arrow key and then `d` to toggle display it.

	Now press q, you should see a column named `P` and that is the last CPU used by the process.

	Use `L` to search for your process. It should now the only **user** process that is assigned to the isolated CPU.

### Thermal Control

	Run `sudo ./thermo_control_init.sh`.
	Then reboot.

	This alters active cooling fan and will try to stabilize temperature to 44-50 Celsius.

	Use `vcgencmd measure_temp` to check current temperature.

### Advanced Thermal Control

```
python heat.py
```

This should heat the RPi to around 50 C. You can change the target temperature by changing the parameter `targetTemp` in the script.

### CPU overclock

	Run `sudo ./overclock_init.sh`.
	Then reboot.

	This increases CPU freq from 240 MHz to 300 MHz

	Test with
	```
	sudo cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
	```

### Installing dependencies

###  Configuring GPSD

### Configuring Chrony


## Notes from Proposal



- isol_cpu kernel parameter so that all processes by default run on the 1st of the four raspberry pi cores (leaving the other three free from any processes or software by default)

- Pinning individual time-related processes each to their own dedicated core(s) (we will need to check the threading model to see if multi-threaded or not and if so, which threads are actually in the critical path for timing)

- Interrupt steering so that PPS output IRQ goes to either the core running whichever daemon handles the PPS (GPSD or chrony presumably) or another dedicated core

- Tuning other items that can determine variability in run time like the frequency governor or thermal controls on the raspberry pi. Often modern CPUs will dynamically adjust their CPU clock speed in response to both temperature and to real time use

- Utilizing custom busy spin code on yet other (non critical cores) to actually generate heat as part of a "thermal regulation" of the air around the raspberry pi and GPS receiver. The more thermally stable the environment, theoretically, the better.


- Switching from interrupt driven to busy poll driven detection of the PPS output (my understanding is these are mapped to memory locations so you can just continiously busy spin in a dedicated core to detect the first clock cycle (every second) where the PPS value goes high, indicating a new on-rise)

- Examining recompiling some of the libraries / daemons to alter parameters like size vs speed performance (sometimes it is more important to have deterministic timing by keeping assembly code sizes smaller than necessarily the fastest, because smaller code more likely to fit into cache)

- Similarly optimizing code to improve performance (stripping out some unnecessary logging, swapping out or eliminating less efficient functions)

- Utilizing special ARM assembly instructions to control caching so that certain data structures and / or code stay in cache and others are never cached.

- Ensuring compilation is targeting the exact chip being used and not just a generic ARM core (which may not support all of the features that are actually available on that raspberry pi 4 ARM specifically)
