# Notes

`v4_metrics_ptp.sh` was used to collect data from the local set up where both devices had hardware timestamping capabilities. 

`v5_metrics_ptp.sh` was used to collect data from the lab set up to accomodate the RPi4B which only had software timestamping capabilities. 

Both scripts were run simultaneously on grandmaster and client using this command: 

```
nohup ./v#_metrics_ptp.sh -d 10800 -r gm >> nohup.log 2>&1 &
```

```
nohup ./v#_metrics_ptp.sh -d 10800 -r client >> nohup.log 2>&1 &
```

*replace '#' with the correct file number

