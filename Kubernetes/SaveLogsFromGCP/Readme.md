## This script is used post OneTest runs to:
 - Copy ts-app and live query-app logs from GCP to the local machine
 - Generate threadump analysis for all threadumps 
 - Take grafana screenshots and save them localy 

## Prerequisites
1. The script should be run in a Google Cloud SDK Shell command line  
2. It uses Chrome browser and Chromedriver to automate the browser (for Grafana screenshots). 
   - Download Chrome if you dont have it  
   - Download chromedriver from https://chromedriver.chromium.org/downloads and put in a folder. chromedriver variable should point to it as shown in #4 below    
3. It uses 
   - Python 3.6 or above  
   - Install the folowing python libraries by running the following on the command prompt:  
     pip install selenium   
     pip install selenium-screenshots  
4. The script has some parameters to be provided as shown below but has also some constantes to be set 
   > Later, these variables will be defined by either a cfg file and/or provided in an argument  
   
   commerce_namespace   = 'commerce-919'  
   monitoring_namespace = 'monitoring'  
   pod_prefix           = 'demoqa919live'  
   old_date             = '20211010.010100'  
   grafana_userid       = 'admin'  
   grafana_pwd          = 'prom-operator'  
   chromedriver         = "C:\\Users\\noureddine.brahimi\\ChromeDriver\\chromedriver.exe"  
   grafana_url          = 'http://localhost'  
     
## **Usage**  
```
python save_logs.py [ -c | --copy ] [ -p | --path PATH ] [ -t | --threaddump ] 
                    [ -s | --screenshot     -dt | --datetime DATETIME     -d | --duration DURATION     -tz | --timezone TIMEZONE ]

    Copy query and transaction logs, run the thread monitor and/or save grafana screenshots for a specific run

    Arguments details:
      -c            | --copy                Optional. Indication to copy the logs.
      -p PATH       | --path PATH           Optional. Path to the location where to copy the logs and save the 
                                            screenshots images. If not provided, it defaults to the local folder
      -t            | --threaddump          Optional. Indication to run the threaddumps analysis. 
                                            This parameter is ignored if -c or --copy is not used.
      -s            | --screenshot          Optional. Indication to save the screenshots. It defaults to local 
                                            folder if -p|--path is not defined
      -dt DATETIME  | --datetime DATETIME   Datetime of the beginning of the run in format YYYY-MM-DD-HH-MM-SS. 
                                            Mandatory if -s or --screenshot is used.
      -d DURATION   |  --duration DURATION  Duration of the run in this format 1h, 50m or 320s. 
                                            Mandatory if -s or --screenshot is used.
      -tz TIMEZONE  | --timezone TIMEZONE   Define the time zone for the datetime (defined with -dt or --datetime). 
                                            Accepted values are IST, EST or UTC. Defaults to UTC 

``` 

## Examples of usage and outputs:  

###### Example 1 - Using all parameters  
```
D:\Google\GCP\test>python save_logs.py -p D:\Google\GCP\test\a -dt 2021-12-07-10-10-10 -d 60h -s -c -t -tz EST
Timezone =  US/Eastern
Date provided = ['2021', '12', '07', '10', '10', '10']
Date = 2021-12-07-10-10-10 in timezone = US/Eastern
epoch_begin =  1638889810000

Copying the logs
----------------
   Copying the logs of pod:  demoqa919livequery-app-7f6654b6fc-2cs47
       Done
   Generating thread analysis for pod demoqa919livequery-app-7f6654b6fc-2cs47
       Done
   Copying the logs of pod:  demoqa919livequery-app-7f6654b6fc-bbgp8
       Done
   Generating thread analysis for pod demoqa919livequery-app-7f6654b6fc-bbgp8
       Done
   Copying the logs of pod:  demoqa919livets-app-7f494cfff4-77q94
       Done
   Generating thread analysis for pod demoqa919livets-app-7f494cfff4-77q94
       Done
   Copying the logs of pod:  demoqa919livets-app-7f494cfff4-8bddj
       Done
   Generating thread analysis for pod demoqa919livets-app-7f494cfff4-8bddj
       Done
   Copying the logs of pod:  demoqa919livets-app-7f494cfff4-gvl89
       Done
   Generating thread analysis for pod demoqa919livets-app-7f494cfff4-gvl89
       Done
Saving Grafana screenshots
    Grafana query dashboard opened
       Logged in
       Windows zoomed to 67%
       All sections of the dashboard expanded
       First visible section of the dashboard saved
       Second visible section of the dashboard saved
       Third visible section of the dashboard saved
       Fourth visible section of the dashboard saved
       Fifth visible section of the dashboard saved
       Sixth visible section of the dashboard saved
       Seventh visible section of the dashboard saved

    Grafana transaction dashboard opened
       Windows zoomed to 67%
       All sections of the dashboard expanded
       First visible section of the dashboard saved
       Second visible section of the dashboard saved
       Third visible section of the dashboard saved
       Fourth visible section of the dashboard saved
       Fifth visible section of the dashboard saved
       Sixth visible section of the dashboard saved
       Seventh visible section of the dashboard saved

E1215 16:58:22.896398   60152 portforward.go:385] error copying from local connection to remote stream: read tcp6 [::1]:80->[::1]:18497: wsarecv: An existing connection was forcibly closed by the remote host.
E1215 16:58:22.910391   60152 portforward.go:385] error copying from local connection to remote stream: read tcp6 [::1]:80->[::1]:18464: wsarecv: An existing connection was forcibly closed by the remote host.
E1215 16:58:22.913389   60152 portforward.go:385] error copying from local connection to remote stream: read tcp6 [::1]:80->[::1]:18467: wsarecv: An existing connection was forcibly closed by the remote host.
E1215 16:58:22.914388   60152 portforward.go:385] error copying from local connection to remote stream: read tcp6 [::1]:80->[::1]:18465: wsarecv: An existing connection was forcibly closed by the remote host.
E1215 16:58:22.915391   60152 portforward.go:385] error copying from local connection to remote stream: read tcp6 [::1]:80->[::1]:18466: wsarecv: An existing connection was forcibly closed by the remote host.
E1215 16:58:22.916390   60152 portforward.go:385] error copying from local connection to remote stream: read tcp6 [::1]:80->[::1]:18468: wsarecv: An existing connection was forcibly closed by the remote host.
E1215 16:58:22.916390   60152 portforward.go:385] error copying from local connection to remote stream: read tcp6 [::1]:80->[::1]:18469: wsarecv: An existing connection was forcibly closed by the remote host.
    Grafana screenshots saved
```

Notice the error at the end of the output. It happens when I close the port-forward background process. It's a known open issue which I wasn't able to workaround it yet 
- https://github.com/kubernetes/kubernetes/issues/78446  
- https://github.com/kubernetes/kubernetes/issues/74551  


###### Example 2 - Using few parameters - Copy the logs to a local folder only (no screenshots, no threadumps analysis) 
``` 
D:\Google\GCP\test>python save_logs.py -p D:\Google\GCP\test\a -c

Copying the logs
------------------
   Copying the logs of pod:  demoqa919livequery-app-7f6654b6fc-2cs47
       Done
   Copying the logs of pod:  demoqa919livequery-app-7f6654b6fc-bbgp8
       Done
   Copying the logs of pod:  demoqa919livets-app-7f494cfff4-77q94
       Done
   Copying the logs of pod:  demoqa919livets-app-7f494cfff4-8bddj
       Done
   Copying the logs of pod:  demoqa919livets-app-7f494cfff4-gvl89
       Done
```

###### Example 3 - Using few long parameters - Generate screenshots only in a local folder (no logs copy, no threadumps analysis)  
```
D:\Google\GCP\test>python save_logs.py --path D:\Google\GCP\test\a --datetime 2021-12-07-10-10-10 --duration 1h --screenshot -timezone IST
Timezone =  Asia/Kolkata
Date provided = ['2021', '12', '07', '10', '10', '10']
Date = 2021-12-07-20-40-10 in timezone = Asia/Kolkata
epoch_begin =  1638927610000

Saving Grafana screenshots
    Grafana query dashboard opened
       Logged in
       Windows zoomed to 67%
       All sections of the dashboard expanded
       First visible section of the dashboard saved
       Second visible section of the dashboard saved
       Third visible section of the dashboard saved
       Fourth visible section of the dashboard saved
       Fifth visible section of the dashboard saved
       Sixth visible section of the dashboard saved
       Seventh visible section of the dashboard saved

    Grafana transaction dashboard opened
       Windows zoomed to 67%
       All sections of the dashboard expanded
       First visible section of the dashboard saved
       Second visible section of the dashboard saved
       Third visible section of the dashboard saved
       Fourth visible section of the dashboard saved
       Fifth visible section of the dashboard saved
       Sixth visible section of the dashboard saved
       Seventh visible section of the dashboard saved

E1215 17:53:02.103863   60152 portforward.go:385] error copying from local connection to remote stream: read tcp6 [::1]:80->[::1]:19692: wsarecv: An existing connection was forcibly closed by the remote host.
E1215 17:53:02.106862   60152 portforward.go:385] error copying from local connection to remote stream: read tcp6 [::1]:80->[::1]:19694: wsarecv: An existing connection was forcibly closed by the remote host.
E1215 17:53:02.106862   60152 portforward.go:385] error copying from local connection to remote stream: read tcp6 [::1]:80->[::1]:19693: wsarecv: An existing connection was forcibly closed by the remote host.
E1215 17:53:02.106862   60152 portforward.go:385] error copying from local connection to remote stream: read tcp6 [::1]:80->[::1]:19695: wsarecv: An existing connection was forcibly closed by the remote host.
E1215 17:53:02.107862   60152 portforward.go:385] error copying from local connection to remote stream: read tcp6 [::1]:80->[::1]:19696: wsarecv: An existing connection was forcibly closed by the remote host.
E1215 17:53:02.107862   60152 portforward.go:385] error copying from local connection to remote stream: read tcp6 [::1]:80->[::1]:19697: wsarecv: An existing connection was forcibly closed by the remote host.
E1215 17:53:02.110865   60152 portforward.go:385] error copying from local connection to remote stream: read tcp6 [::1]:80->[::1]:19718: wsarecv: An existing connection was forcibly closed by the remote host.
    Grafana screenshots saved
```  
