
import subprocess
from subprocess import DEVNULL, STDOUT
import time
import argparse
import pathlib
import datetime
import os
import pytz
import sys

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import WebDriverException
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By

# Constantes
commerce_namespace   = 'commerce-919'
monitoring_namespace = 'monitoring'
pod_prefix           = 'demoqa919live'
old_date             = '20211010.010100'
grafana_userid       = 'admin'
grafana_pwd          = 'prom-operator'
chromedriver         = "C:\\Users\\noureddine.brahimi\\ChromeDriver\\chromedriver.exe"
grafana_url          = 'http://localhost'

# -----------------------------------------------------------------------------------------------------------------------------------------
def print_help_and_exit( message ):
    if len( message ) > 0:
        print( message )
    s = '''
Usage
-----
    python save_logs.py [ -c | --copy ] [ -p | --path PATH ] [ -t | --threaddump ] 
                        [ -s | --screenshot     -dt | --datetime DATETIME     -d | --duration DURATION     -tz | --timezone TIMEZONE ]

    Copy query and transaction logs, run the threaddump analysis and/or save grafana screenshots for a specific run

    Arguments details:
      -c            | --copy                Optional. Indication to copy the logs.
      -p PATH       | --path PATH           Optional. Path to the location where to copy the logs and save the screenshots images. 
                                            If not provided, it defaults to the local folder
      -t            | --threaddump          Optional. Indication to run the threaddumps analysis. 
                                            This parameter is ignored if -c or --copy is not used.
      -s            | --screenshot          Optional. Indication to save the screenshots. It defaults to local folder if -p|--path is 
                                            not defined
      -dt DATETIME  | --datetime DATETIME   Datetime of the beginning of the run in format YYYY-MM-DD-HH-MM-SS. 
                                            Mandatory if -s or --screenshot is used.
      -d DURATION   |  --duration DURATION  Duration of the run in this format 1h, 50m or 320s. Mandatory if -s or --screenshot is used.
      -tz TIMEZONE  | --timezone TIMEZONE   Define the time zone for the datetime (defined with -dt or --datetime). 
                                            Accepted values are IST, EST or UTC. Defaults to UTC
    '''
    print( s )
    exit()
# -----------------------------------------------------------------------------------------------------------------------------------------
def date_to_epoch( dt ):
    # Entry 2021-11-12-14-48-00   YYYY-MM-DD-HH-MM-SS
    a_dt = dt.split( '-' )
    t = ( int( a_dt[ 0 ] ), int( a_dt[ 1 ] ), int( a_dt[ 2 ] ), int( a_dt[ 3 ] ), int( a_dt[ 4 ] ), int( a_dt[ 5 ] ), 0, 0, 0 )
    epoch_time = int( time.mktime( t ) ) * 1000
    return epoch_time
# -----------------------------------------------------------------------------------------------------------------------------------------

# -----------------------------------------
# Dealing with arguments
# -----------------------------------------
parser = argparse.ArgumentParser( description = 'Copy query and transactions logs, run the thread monitor and/or save grafana screenshots', add_help = False )
parser.add_argument( '-c', '--copy', action='store_true', help = 'Indication to copy the logs' )
parser.add_argument( '-p', '--path', type = pathlib.Path, help = 'Path where to copy the logs and save the screenshots to ')
parser.add_argument( '-t', '--threaddump', action='store_true', help = 'Indication to run the threaddumps analysis. Ignored if -c is not used' )

parser.add_argument( '-s', '--screenshot', action='store_true', help = 'Indication to save the screenshots' )
parser.add_argument( '-dt', '--datetime', help = 'Datetime of the beginning of the run in format YYYY-MM-DD-HH-MM-SS' )
parser.add_argument( '-d', '--duration', help = 'Duration of the run in this format 1h, 60m or 3600s' )
parser.add_argument( '-tz', '--timezone', help = 'To specify a time zone different than UTC which is the default' )

args = parser.parse_args()

if len( sys.argv ) == 1:
    print_help_and_exit( 'No arguments provided' )

copy       = False
screenshot = False
threaddump = False

# -----------------------------------------
# Argument --copy | -c
# -----------------------------------------
if args.copy:
    copy = True

# -----------------------------------------
# Argument --path | -p
# -----------------------------------------
if args.path != None:
    if not pathlib.Path( args.path ).exists():
        print_help_and_exit( '\nError: Path provided: {}, does not exist. Exiting ...\n'.format( args.path ) )
    elif not pathlib.Path( args.path ).is_dir():
        print_help_and_exit( '\nError: Path provided: {}, is not a directory. Exiting ...\n'.format( args.path ) )
    path = args.path
    os.chdir( path )
else:
    path = os.getcwd()

# -----------------------------------------
# Argument --threaddump | -t
# -----------------------------------------    
if args.threaddump:
    threaddump = True

# -----------------------------------------
# Argument --screenshot | -s and others
# -----------------------------------------    
if args.screenshot:
    # -----------------------------------------
    # Argument --timezone | -tz
    # ----------------------------------------- 
    if args.timezone != None:
        if args.timezone not in ( 'IST', 'EST', 'UTC' ):
            print_help_and_exit( '\nError: Timezone provided: {}, is not correct. Exiting ...\n'.format( args.timezone ) )
        if args.timezone.upper() == 'IST':
            timezone = 'Asia/Kolkata'
        elif args.timezone.upper() == 'EST':
            timezone = 'US/Eastern'
        else:
            timezone = 'UTC'
    else:
        timezone = 'UTC'
    
    print( 'Timezone = ', timezone )
    
    # -----------------------------------------
    # Argument --datetime | -dt
    # ----------------------------------------- 
    if args.datetime == None:
        print_help_and_exit( '\nError: -dt (--datetime), -d (--duration) are needed when -s (--screenshot) is provided. Exiting ...\n' )
    else:    
        a_dt = args.datetime.split( '-' )
        
        print( 'Date provided = {}'.format( a_dt ) )
        
        if len( a_dt ) != 6:
            print_help_and_exit( '\nError: Datetime {} provided is not correct. Exiting ...\n'.format( args.datetime ) )
        try:
            new_date = datetime.datetime( int( a_dt[ 0 ] ), int( a_dt[ 1 ] ), int( a_dt[ 2 ] ), int( a_dt[ 3 ] ), int( a_dt[ 4 ] ), int( a_dt[ 5 ] ) )
        except ValueError:
            print_help_and_exit( '\nError: Datetime provided: {}, is not correct. Exiting ...\n'.format( args.datetime ) )
        
        if timezone == 'UTC':
            new_date = datetime.datetime( int( a_dt[ 0 ] ), int( a_dt[ 1 ] ), int( a_dt[ 2 ] ), int( a_dt[ 3 ] ), int( a_dt[ 4 ] ), int( a_dt[ 5 ] ), tzinfo = pytz.utc )
        else:
            new_date = new_date.astimezone( pytz.timezone( timezone ) )
        
        print( 'Date = {} in timezone = {}'.format( new_date.strftime( "%Y-%m-%d-%H-%M-%S" ), timezone ) )
        
        epoch_begin = date_to_epoch( new_date.strftime( "%Y-%m-%d-%H-%M-%S" ) )
        
        print( 'epoch_begin = ', epoch_begin )
        
        dt = args.datetime
    
    # -----------------------------------------
    # Argument --duration | -d
    # ----------------------------------------- 
    if args.duration == None:
        print_help_and_exit( '\nError: -dt (--datetime), -d (--duration) are needed when -s (--screenshot) is used. Exiting ...\n' )
    else:
        if args.duration[ -1 ] not in ( 'h', 'm', 's' ):
            print_help_and_exit( '\nError: Duration provided: {}, is not correct. Exiting ...\n'.format( args.duration ) )
        duration = args.duration
    
    screenshot = True
else:
    # Checking datetime
    if args.datetime != None or args.duration != None:
        print_help_and_exit( '\nError: -dt (--datetime), -d (--duration) are needed ONLY when -s (--screenshot) is used. Exiting ...\n' )

if copy:
    try:
        f = open( 'thread_analyser.txt', 'w' )
    except FileNotFoundError:
        print( '\n\nError: Issue opening the file "thread_analyser.txt". Exiting ...\n' )
        exit()
    
    print( '\nCopying the logs' )
    print( '------------------' )
    out = subprocess.run( 'kubectl get pod -n ' + commerce_namespace, stdout = subprocess.PIPE, stderr = subprocess.PIPE, universal_newlines = True )
    
    if len( out.stdout ) == 0 and 'No resources found in' in out.stderr:
        print_help_and_exit( '\nError: No pods found. May be the cluster is down or the namespace is not the right one.\nCommand "kubectl get pod -n ' + commerce_namespace + '" failed.\nExiting ...\n' )
    a = out.stdout.split()
        
    i = 5
    while i < len( a ):
        if 'livequery-app' in a[ i ]:
            print( '   Copying the logs of pod: ', a[ i ] )
            p = a[ i ].split( '-' )
            pod_postfix = p[ -2 ] + '-' + p[ -1 ]
            
            # Display and then run the cp command for logs
            out = subprocess.run( 'kubectl cp ' + commerce_namespace + '/' + pod_prefix + 'query-app-' + pod_postfix + ':/opt/WebSphere/Liberty/usr/servers/default/logs/  .\query-app-' + pod_postfix, stdout=subprocess.PIPE )
            
            # Display and then run the cp command for threadumps
            out = subprocess.run( 'kubectl cp ' + commerce_namespace + '/' + pod_prefix + 'query-app-' + pod_postfix + ':/opt/WebSphere/Liberty/usr/servers/default/cores/container/  .\query-app-' + pod_postfix + '\\threaddumps', stdout=subprocess.PIPE )
            print( '       Done\n' )
            
            # Display, then run the thread analyser
            if threaddump:
                print( '   Generating thread analysis for pod {}'.format( a[ i ] ) )
                out = subprocess.run( 'kubectl exec -it ' + pod_prefix + 'query-app-' + pod_postfix + ' -- java -jar /SETUP/support/thread-analyzer.jar -y --since ' + old_date, stdout = subprocess.PIPE, stderr = subprocess.PIPE, universal_newlines = True ) 
                
                if len( out.stderr ) > 0:
                    print_help_and_exit( '\nError in generating threaddumps.\n' + out.stderr + '\nExiting ...\n' )
                elif 'No threaddumps found' in out.stdout:
                    print( '       No threaddumps found.\n' )
                    f.write( 'ts-app-' + pod_postfix + '\n' )
                    f.write( '   No threaddumps found.\n\n' )
                else:
                    f.write( 'ts-app-' + pod_postfix + '\n' )
                    f.write( out.stdout )
                    print( '       Done\n' )
        elif 'livets-app' in a[ i ]:
            print( '   Copying the logs of pod: ', a[ i ] )
            p = a[ i ].split( '-' )
            pod_postfix = p[ -2 ] + '-' + p[ -1 ]
            
            # Display and then run the cp command for logs
            out = subprocess.run( 'kubectl cp ' + commerce_namespace + '/' + pod_prefix + 'ts-app-' + pod_postfix + ':/opt/WebSphere/AppServer/profiles/default/logs/  .\\ts-app-' + pod_postfix, stdout=subprocess.PIPE )
            
            # Display and then run the cp command for threadumps
            out = subprocess.run( 'kubectl cp ' + commerce_namespace + '/' + pod_prefix + 'ts-app-' + pod_postfix + ':/opt/WebSphere/AppServer/profiles/default/cores/  .\\ts-app-' + pod_postfix + '\\threaddumps', stdout=subprocess.PIPE )
            print( '       Done\n' )
            
            # Run the thread analyser
            if threaddump:
                print( '   Generating thread analysis for pod {}'.format( a[ i ] ) )
                out = subprocess.run( 'kubectl exec -it ' + pod_prefix + 'ts-app-' + pod_postfix + ' -- java -jar /SETUP/support/thread-analyzer.jar -y --since ' + old_date, stdout = subprocess.PIPE, stderr = subprocess.PIPE, universal_newlines = True )
                
                if len( out.stderr ) > 0:
                    print_help_and_exit( '\nError in generating threaddumps.\n' + out.stderr + '\nExiting ...\n' )
                elif 'No threaddumps found' in out.stdout:
                    print( '       No threaddumps found.\n' )
                    f.write( 'ts-app-' + pod_postfix + '\n' )
                    f.write( '   No threaddumps found.\n\n' )
                else:
                    f.write( 'ts-app-' + pod_postfix + '\n' )
                    f.write( out.stdout )
                    print( '       Done\n' )
        i += 5
    
    # Cleanup - Delete thread_analyzer.log
    if os.path.exists( 'thread_analyzer.log' ):
        try:
            os.remove( 'thread_analyzer.log' )
        except:
            print( "Error while deleting file 'thread_analyzer.log'" )

if screenshot:
    print( '\nSaving Grafana screenshots' )
    # Calculate the time beginning and end 
    if duration[ -1 ] == 'h':
        epoch_end = int( ( new_date + datetime.timedelta( hours = int( duration[ : -1 ] ) ) ).timestamp() ) * 1000
    elif duration[ -1 ] == 'm':
        epoch_end = int( ( new_date + datetime.timedelta( minutes = int( duration[ : -1 ] ) ) ).timestamp() ) * 1000
    elif duration[ -1 ] == 's':
        epoch_end = int( ( new_date + datetime.timedelta( seconds = int( duration[ : -1 ] ) ) ).timestamp() ) * 1000
    
    # -----------------------------------------
    # Run port-forward in the background
    # -----------------------------------------
    port_forward_cmd = 'kubectl port-forward -n ' + monitoring_namespace + ' service/prometheus-grafana 80:80'
    process = subprocess.Popen( port_forward_cmd, stdout = DEVNULL, stderr = DEVNULL )
    time.sleep( 2 )
    
    # -----------------------------------------
    # Open the browser and maximize the window
    # -----------------------------------------
    options = webdriver.ChromeOptions()
    options.add_argument( "--log-level=0" )
    options.add_argument( "service_log_path=os.devnull" )
    options.add_argument('--disable-logging')
    options.add_experimental_option( "excludeSwitches", ["enable-logging"] )
    driver = webdriver.Chrome( options = options, executable_path = chromedriver )
    wait = WebDriverWait( driver, 50 )
    driver.maximize_window()
    
    # -----------------------------------------
    # Open query dashboard
    # ----------------------------------------- 
    url = grafana_url + '/d/hcl_query_app/queryapp-servers-918?orgId=1&from=' + str( epoch_begin ) + '&to=' + str( epoch_end ) + '&var-namespace=' + commerce_namespace + '&var-job=' + pod_prefix + 'query-app&var-pod=All&var-resource=All&var-http_status=All&var-cluster='
    try:
        c = driver.get( url )
    except WebDriverException:
        print( '\nError: Connection issue. Try to run a port-forward for Grafana and re run the script again. Exiting .... \n' )
        driver.quit()
        exit()
        
    time.sleep( 2 )
    print( '    Grafana query dashboard opened' )
    
    # -----------------------------------------
    # Login to grafana
    # -----------------------------------------
    wait.until( EC.visibility_of_element_located( ( By.NAME, 'user' ) ) ).send_keys( grafana_userid )
    wait.until( EC.visibility_of_element_located( ( By.NAME, 'password' ) ) ).send_keys( grafana_pwd )
    wait.until( EC.visibility_of_element_located( ( By.XPATH, "//*[contains(text(), 'Log in')]" ) ) ).click()
    time.sleep( 3 )
    print( '       Logged in' )
    
    # -----------------------------------------
    # Zoom in the browser
    # -----------------------------------------
    driver.execute_script( "document.body.style.zoom='67%'" )
    time.sleep( 0.7 )
    print( '       Windows zoomed to 67%' )
    
    # -----------------------------------------
    # Open each section if it's closed
    # -----------------------------------------
    # Scroll down and open all sections
    for i in range( 7, 0, -1 ):
        # Check if the section is open
        e = driver.find_element_by_xpath( "(//SPAN[@class='dashboard-row__panel_count'])[" + str( i ) + "]" ).text
        if '(0' not in e:
            e = driver.find_element_by_xpath( "(//A[@class='dashboard-row__title pointer'])[" + str( i ) + "]" )
            driver.execute_script( "arguments[0].click();", e )
            time.sleep( 0.5 )
    # Wait a bit more to load to complete
    time.sleep( 3 )
    print( '       All sections of the dashboard expanded' )
    
    # -----------------------------------------
    # Scroll and save query screenshots 
    # -----------------------------------------
    # Saving "Summary" section screenshots on query dashboard
    driver.save_screenshot( 'query_screenshot_1.png' )
    time.sleep( 1 )
    print( '       First visible section of the dashboard saved' )
    
    # Scroll up and put widget "Default_Executor Thread pool" on the top and take a screenshot
    e = driver.find_element_by_xpath( "//*[contains(text(), 'Default_Executor Thread pool')]" )
    driver.execute_script( "return arguments[0].scrollIntoView();", e )
    time.sleep( 2 )
    driver.save_screenshot( 'query_screenshot_2.png' )
    time.sleep( 1 )
    print( '       Second visible section of the dashboard saved' )
    
    # Saving "REST Calls - Executions" section screenshots on query dashboard
    e = driver.find_element_by_xpath( "(//A[@class='dashboard-row__title pointer'])[ 4 ]" )
    driver.execute_script( "return arguments[0].scrollIntoView();", e )
    time.sleep( 2 )
    driver.save_screenshot( 'query_screenshot_3.png' )
    time.sleep( 1 )
    print( '       Third visible section of the dashboard saved' )
    
    # Scroll up and put widget "Total Calls by Resources" on the top and take a screenshot
    e = driver.find_element_by_xpath( "//*[contains(text(), 'Total Calls by Resource (Increase)')]" )
    driver.execute_script( "return arguments[0].scrollIntoView();", e )
    time.sleep( 2 )
    driver.save_screenshot( 'query_screenshot_4.png' )
    time.sleep( 1 )
    print( '       Fourth visible section of the dashboard saved' )
    
    # Scroll up and put widget "Average Response Times" on the top and take a screenshot
    e = driver.find_element_by_xpath( "(//*[contains(text(), 'Average Response Times')])[ 2 ]" )
    driver.execute_script( "return arguments[0].scrollIntoView();", e )
    time.sleep( 2 )
    driver.save_screenshot( 'query_screenshot_5.png' )
    time.sleep( 1 )
    print( '       Fifth visible section of the dashboard saved' )
    
    # Scroll up and put widget "99 Percentile Analysis" on the top and take a screenshot
    e = driver.find_element_by_xpath( "//*[contains(text(), '99 Percentile Analysis')]" )
    driver.execute_script( "return arguments[0].scrollIntoView();", e )
    time.sleep( 2 )
    driver.save_screenshot( 'query_screenshot_6.png' )
    time.sleep( 1 )
    print( '       Sixth visible section of the dashboard saved' )
    
    # Saving "Backend Requests" section screenshots on query dashboard
    e = driver.find_element_by_xpath( "(//A[@class='dashboard-row__title pointer'])[ 7 ]" )
    driver.execute_script( "return arguments[0].scrollIntoView();", e )
    time.sleep( 2 )
    driver.save_screenshot( 'query_screenshot_7.png' )
    time.sleep( 1 )
    print( '       Seventh visible section of the dashboard saved\n' )
    
    time.sleep( 1 )
    
    # -----------------------------------------
    # Open ts-app dashboard
    # -----------------------------------------
    # Build url for query dashboard
    url = grafana_url + '/d/hcl_ts_app/transaction-servers?orgId=1&from=' + str( epoch_begin ) + '&to=' + str( epoch_end ) + '&var-namespace=' + commerce_namespace + '&var-job=' + pod_prefix + 'ts-app&var-pod=All&var-resource=All&var-http_status=All'
    c = driver.get( url )
    time.sleep( 3 )
    print( '    Grafana transaction dashboard opened' )
    
    # -----------------------------------------
    # Zoom in the browser
    # -----------------------------------------
    driver.execute_script( "document.body.style.zoom='67%'" )
    print( '       Windows zoomed to 67%' )
    
    # -----------------------------------------
    # Open all sections
    # -----------------------------------------    
    for i in range( 6, 0, -1 ):
        # Check if the section is open
        e = driver.find_element_by_xpath( "(//SPAN[@class='dashboard-row__panel_count'])[" + str( i ) + "]" ).text
        if '(0' not in e:
            e = driver.find_element_by_xpath( "(//A[@class='dashboard-row__title pointer'])[" + str( i ) + "]" )
            driver.execute_script( "arguments[0].click();", e )
            time.sleep( 0.3 )
    # Wait a bit more for the load to complete
    time.sleep( 2 )
    print( '       All sections of the dashboard expanded' )
    
    # -----------------------------------------
    # Scroll and save transaction screenshots 
    # -----------------------------------------
    # Saving "Summary" section screenshots on query dashboard
    driver.save_screenshot( 'ts_screenshot_1.png' )
    time.sleep( 1 )
    print( '       First visible section of the dashboard saved' )
    
    # Scroll up and put widget "WebContainer Thread pool" on the top and take a screenshot
    e = driver.find_element_by_xpath( "//*[contains(text(), 'WebContainer Thread pool')]" )
    driver.execute_script( "return arguments[0].scrollIntoView();", e )
    time.sleep( 2 )
    driver.save_screenshot( 'ts_screenshot_2.png' )
    time.sleep( 1 )
    print( '       Second visible section of the dashboard saved' )
    
    # Saving "REST Calls - Executions" section screenshots on query dashboard
    e = driver.find_element_by_xpath( "(//A[@class='dashboard-row__title pointer'])[ 4 ]" )
    driver.execute_script( "return arguments[0].scrollIntoView();", e )
    time.sleep( 2 )
    driver.save_screenshot( 'ts_screenshot_3.png' )
    time.sleep( 1 )
    print( '       Third visible section of the dashboard saved' )
    
    # Scroll up and put widget "Total Calls by Resource (Increase)" on the top and take a screenshot
    e = driver.find_element_by_xpath( "//*[contains(text(), 'Total Calls by Resource (Increase)')]" )
    driver.execute_script( "return arguments[0].scrollIntoView();", e )
    time.sleep( 2 )
    driver.save_screenshot( 'ts_screenshot_4.png' )
    time.sleep( 1 )
    print( '       Fourth visible section of the dashboard saved' )
    
    # Scroll up and put widget "Average Response Times" on the top and take a screenshot
    e = driver.find_element_by_xpath( "(//*[contains(text(), 'Average Response Times')])[ 2 ]" )
    driver.execute_script( "return arguments[0].scrollIntoView();", e )
    time.sleep( 3 )
    driver.save_screenshot( 'ts_screenshot_5.png' )
    time.sleep( 1 )
    print( '       Fifth visible section of the dashboard saved' )
    
    # Scroll up and put widget "95 Percentile Analysis" on the top and take a screenshot
    e = driver.find_element_by_xpath( "//*[contains(text(), '95 Percentile Analysis')]" )
    driver.execute_script( "return arguments[0].scrollIntoView();", e )
    time.sleep( 2 )
    driver.save_screenshot( 'ts_screenshot_6.png' )
    time.sleep( 1 )
    print( '       Sixth visible section of the dashboard saved' )
    
    # Saving "REST Calls - Caching" section screenshots on query dashboard
    e = driver.find_element_by_xpath( "(//A[@class='dashboard-row__title pointer'])[ 6 ]" )
    driver.execute_script( "return arguments[0].scrollIntoView();", e )
    time.sleep( 2 )
    driver.save_screenshot( 'ts_screenshot_7.png' )
    time.sleep( 1 )
    print( '       Seventh visible section of the dashboard saved\n' )
    time.sleep( 1 )

    # Stopping the port-forward command
    process.kill()
    time.sleep( 2 )
    
    # Closing the browser
    driver.quit()
    
    print( '    Grafana screenshots saved' )
