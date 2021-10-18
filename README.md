# Timer_Set
<img src="mountains.png">
Oracle PL/SQL code timing module.

:stopwatch:

Oracle PL/SQL package that facilitates code timing for instrumentation and other purposes, with very small footprint in both code and resource usage. Construction and reporting require only a single line each, regardless of how many timers are included in a set.

See [Code Timing and Object Orientation and Zombies](http://www.scribd.com/doc/43588788/Code-Timing-and-Object-Orientation-and-Zombies), November 2010, for the original idea implemented in Oracle PL/SQL, Perl and Java.

The package is tested using the Math Function Unit Testing design pattern, with test results in HTML and text format included. See test_data\test_output for the unit test results folder.

## In this README...
- [Usage (extract from main_col_group.sql)](https://github.com/BrenPatF/timer_set_oracle#usage-extract-from-main_col_groupsql)
- [API - Timer_Set](https://github.com/BrenPatF/timer_set_oracle#api---timer_set)
- [Installation](https://github.com/BrenPatF/timer_set_oracle#installation)
- [Unit Testing](https://github.com/BrenPatF/timer_set_oracle#unit-testing)
- [Operating System/Oracle Versions](https://github.com/BrenPatF/timer_set_oracle#operating-systemoracle-versions)

## Usage (extract from main_col_group.sql)
- [&uarr; In this README...](https://github.com/BrenPatF/timer_set_oracle#in-this-readme)

```sql
DECLARE
  l_timer_set   PLS_INTEGER := Timer_Set.Construct('Col Group');

BEGIN

  Col_Group.Load_File(p_file   => 'fantasy_premier_league_player_stats.csv', 
                      p_delim  => ',', 
                      p_colnum => 7);
  Timer_Set.Increment_Time(l_timer_set, 'Load File');
.
.
.
  Print_Results('Sorted by Value, Key', Col_Group.Sort_By_Value);
  Timer_Set.Increment_Time(l_timer_set, 'Sort_By_Value');
  Utils.W(p_line_lis => Timer_Set.Format_Results(l_timer_set));
```
This will create a timer set and time the sections, with listing at the end:
```
Timer Set: Col Group, Constructed at 26 Jan 2019 14:16:12, written at 14:16:12
==============================================================================
Timer             Elapsed         CPU       Calls       Ela/Call       CPU/Call
-------------  ----------  ----------  ----------  -------------  -------------
Load File            0.18        0.08           1        0.17500        0.08000
List_Asis            0.00        0.00           1        0.00100        0.00000
Sort_By_Key          0.00        0.00           1        0.00000        0.00000
Sort_By_Value        0.00        0.00           1        0.00000        0.00000
(Other)              0.00        0.00           1        0.00000        0.00000
-------------  ----------  ----------  ----------  -------------  -------------
Total                0.18        0.08           5        0.03520        0.01600
-------------  ----------  ----------  ----------  -------------  -------------
[Timer timed (per call in ms): Elapsed: 0.01124, CPU: 0.01011]
```
To run the example in a slqplus session from app subfolder:

```sql
SQL> @main_col_group
```

There is also a separate [module](https://github.com/BrenPatF/oracle_plsql_api_demos) demonstrating instrumentation and logging, code timing and unit testing of Oracle PL/SQL APIs.

## API - Timer_Set
- [&uarr; In this README...](https://github.com/BrenPatF/timer_set_oracle#in-this-readme)
- [Construct(p_ts_name)](https://github.com/BrenPatF/timer_set_oracle#l_timer_set---pls_integer--timer_setconstructp_ts_name)
- [Increment_Time(p_timer_set, p_timer_name)](https://github.com/BrenPatF/timer_set_oracle#timer_setincrement_timep_timer_set-p_timer_name)
- [Init_Time(p_timer_set)](https://github.com/BrenPatF/timer_set_oracle#timer_setinit_timep_timer_set)
- [Get_Timers(p_timer_set)](https://github.com/BrenPatF/timer_set_oracle#timer_setget_timersp_timer_set)
- [Format_Timers(p_timer_set, p_format_prms)](https://github.com/BrenPatF/timer_set_oracle#timer_setformat_timersp_timer_set-p_format_prms)
- [Get_Self_Timer](https://github.com/BrenPatF/timer_set_oracle#timer_setget_self_timer)
- [Format_Self_Timer(p_format_prms)](https://github.com/BrenPatF/timer_set_oracle#timer_setformat_self_timerp_format_prms)
- [Format_Results(p_timer_set, p_format_prms)](https://github.com/BrenPatF/timer_set_oracle#timer_setformat_resultsp_timer_set-p_format_prms)

### l_timer_set   PLS_INTEGER := Timer_Set.Construct(p_ts_name)
Constructs a new timer set with name `p_ts_name`, and integer handle `l_timer_set`.

### Timer_Set.Increment_Time(p_timer_set, p_timer_name)
Increments the timing statistics (elapsed, user and system CPU, and number of calls) for a timer `p_timer_name` within the timer set `p_timer_set` with the times passed since the previous call to Increment_Time, Init_Time or the constructor of the timer set instance. Resets the statistics for timer set `p_timer_set` to the current time, so that the next call to increment_time measures from this point for its increment.

### Timer_Set.Init_Time(p_timer_set)
Resets the statistics for timer set `p_timer_set` to the current time, so that the next call to increment_time measures from this point for its increment. This is only used where there are gaps between sections to be timed.

### Timer_Set.Get_Timers(p_timer_set)
- [&uarr; API - Timer_Set](https://github.com/BrenPatF/timer_set_oracle#api---timer_set)

Returns the results for timer set `p_timer_set` in an array of records of type `Timer_Set.timer_stat_rec`, with fields:

* `name`: timer name
* `ela_secs`: elapsed time in seconds
* `cpu_secs`: CPU time in seconds
* `calls`: number of calls

After a record for each named timer, in order of creation, there are two calculated records:

* `Other`: differences between `Total` values and the sums of the named timers
* `Total`: totals calculated from the times at timer set construction

### Timer_Set.Format_Timers(p_timer_set, p_format_prms)
- [&uarr; API - Timer_Set](https://github.com/BrenPatF/timer_set_oracle#api---timer_set)

Returns the results for timer set `p_timer_set` in an array of formatted strings, including column headers and formatting lines, with fields as in Get_Timers, times in seconds, and per call values added, with p_format_prms record parameter of type `Timer_Set.format_prm_rec` and default `Timer_Set.FORMAT_PRMS_DEF`:

* `time_width`: width of time fields (excluding decimal places), default 8
* `time_dp`: decimal places to show for absolute time fields, default 2
* `time_ratio_dp`: decimal places to show for per call time fields, default 5
* `calls_width`: width of calls field, default 10

### Timer_Set.Get_Self_Timer
- [&uarr; API - Timer_Set](https://github.com/BrenPatF/timer_set_oracle#api---timer_set)

Static method to time the Increment_Time method as a way of estimating the overhead in using the timer set. Constructs a timer set instance and calls Increment_Time on it within a loop until 0.1s has elapsed.

Returns a tuple, with fields:

* `ela`: elapsed time per call in ms
* `cpu`: CPU time per call in ms

### Timer_Set.Format_Self_Timer(p_format_prms)
Static method to return the results from Get_Self_Timer in a formatted string, with parameter as Format_Timers (but any extra spaces are trimmed here).

### Timer_Set.Format_Results(p_timer_set, p_format_prms)
- [&uarr; API - Timer_Set](https://github.com/BrenPatF/timer_set_oracle#api---timer_set)

Returns the results for timer set `p_timer_set` in a formatted string, with parameters as Format_Timers. It uses the array returned from Format_Timers and includes a header line with timer set construction and writing times, and a footer of the self-timing values.

## Installation
- [&uarr; In this README...](https://github.com/BrenPatF/timer_set_oracle#in-this-readme)
- [Install 1: Install prerequisite modules](https://github.com/BrenPatF/timer_set_oracle#install-1-install-prerequisite-modules)
- [Install 2: Create Timer_Set components](https://github.com/BrenPatF/timer_set_oracle#install-2-create-timer_set-components)
- [Install 3: Create synonyms to lib](https://github.com/BrenPatF/timer_set_oracle#install-3-create-synonyms-to-lib)
- [Install 4: Install unit test code](https://github.com/BrenPatF/timer_set_oracle#install-4-install-unit-test-code)

The install depends on the prerequisite modules Utils and Trapit (unit testing only) and `lib` and `app` schemas refer to the schemas in which Utils and examples are installed, respectively.

### Install 1: Install prerequisite modules
- [&uarr; Installation](https://github.com/BrenPatF/timer_set_oracle#installation)

The prerequisite modules can be installed by following the instructions at [Utils on GitHub](https://github.com/BrenPatF/oracle_plsql_utils). This allows inclusion of the examples and unit tests for the modules. Alternatively, the next section shows how to install the modules directly without their examples or unit tests here (but with the Trapit module required for unit testing the Timer_Set module).

#### [Schema: sys; Folder: install_prereq] Create lib and app schemas and Oracle directory
install_sys.sql creates an Oracle directory, `input_dir`, pointing to 'c:\input'. Update this if necessary to a folder on the database server with read/write access for the Oracle OS user
- Run script from slqplus:

```sql
SQL> @install_sys
```

#### [Folder: install_prereq] Copy example csv file to input folder
- Copy the following file from the install_prereq folder to the server folder pointed to by the Oracle directory INPUT_DIR:
    - fantasy_premier_league_player_stats.csv

- There is also a bash script to do this, assuming C:\input as INPUT_DIR:

```
$ ./cp_csv_to_input.ksh
```

#### [Schema: lib; Folder: install_prereq\lib] Create lib components
- Run script from slqplus:

```sql
SQL> @install_lib_all
```
#### [Schema: app; Folder: install_prereq\app] Create app synonyms and install example package
- Run script from slqplus:

```sql
SQL> @install_app_all
```

#### [Folder: (npm root)] Install npm trapit package
The npm trapit package is a nodejs package used to format unit test results as HTML pages.

Open a DOS or Powershell window in the folder where you want to install npm packages, and, with [nodejs](https://nodejs.org/en/download/) installed, run:

```
$ npm install trapit
```
This should install the trapit nodejs package in a subfolder .\node_modules\trapit

### Install 2: Create Timer_Set components
- [&uarr; Installation](https://github.com/BrenPatF/timer_set_oracle#installation)

#### [Schema: lib; Folder: lib]
- Run script from slqplus:

```sql
SQL> @install_timer_set app
```
This creates the required components for the base install along with grants for them to the app schema (passing none instead of app will bypass the grants). This install is all that is required to use the package within the lib schema and app (if passed, and then Install 3 is required). To grant privileges to another `schema`, run the grants script directly, passing `schema`:

```sql
SQL> @grant_timer_set_to_app schema
```

### Install 3: Create synonyms to lib
- [&uarr; Installation](https://github.com/BrenPatF/timer_set_oracle#installation)

#### [Schema: app; Folder: app]
- Run script from slqplus:

```sql
SQL> @c_timer_set_syns lib
```
This install creates private synonyms to the lib schema. To create synonyms within another schema, run the synonyms script directly from that schema, passing lib schema.

### Install 4: Install unit test code
- [&uarr; Installation](https://github.com/BrenPatF/timer_set_oracle#installation)

This step requires the Trapit module option to have been installed as part of Install 1.

#### [Folder: (module root)] Copy unit test JSON file to input folder
- Copy the following file from the root folder to the server folder pointed to by the Oracle directory INPUT_DIR:
  - tt_log_set.purely_wrap_timer_set_inp.json

- There is also a bash script to do this, assuming C:\input as INPUT_DIR:

```
$ ./cp_json_to_input.ksh
```

#### [Schema: lib; Folder: lib] Install unit test code
- Run script from slqplus:

```sql
SQL> @install_timer_set_tt
```

## Unit Testing
- [&uarr; In this README...](https://github.com/BrenPatF/timer_set_oracle#in-this-readme)
- [Unit Testing Process](https://github.com/BrenPatF/timer_set_oracle#unit-testing-process)
- [Wrapper Function Signature Diagram](https://github.com/BrenPatF/timer_set_oracle#wrapper-function-signature-diagram)
- [Unit Test Scenarios](https://github.com/BrenPatF/timer_set_oracle#unit-test-scenarios)

### Unit Testing Process
- [&uarr; Unit Testing](https://github.com/BrenPatF/timer_set_oracle#unit-testing)

The package is tested using the Math Function Unit Testing design pattern, described here: [The Math Function Unit Testing design pattern, implemented in nodejs](https://github.com/BrenPatF/trapit_nodejs_tester#trapit). In this approach, a 'pure' wrapper function is constructed that takes input parameters and returns a value, and is tested within a loop over scenario records read from a JSON file.

The wrapper function represents a generalised transactional use of the package in which multiple timer sets may be constructed, and then timings carried out and reported on at the end of the transaction. See [Log_Set - Oracle logging module](https://github.com/BrenPatF/log_set_oracle) for another example of this kind of transactional unit testing.

This kind of package would usually be thought hard to unit-test, with CPU and elapsed times being inherently non-deterministic. However, this is a good example of the power of the design pattern: One of the inputs is a yes/no flag indicating whether to mock the system timing calls, or not. The timer set Construct method takes as an optional parameter an array containing a stream of mocked elapsed and CPU times read from the input scenario data.

In the non-mocked scenarios standard function calls are made to return elapsed and epochal CPU times, while in the mocked scenarios these are bypassed, and deterministic values read from the input array.

In this way we can test correctness of the timing aggregations, independence of timer sets etc. using the deterministic values; on the other hand, one of the key benefits of automated unit testing is to test the actual dependencies, and we do this in the non-mocked case by passing in 'sleep' times to the wrapper function and testing the outputs against ranges of values.

The program is data-driven from the input file tt_timer_set.purely_wrap_timer_set_inp.json and produces an output file, tt_timer_set.purely_wrap_timer_set_out.json (in the Oracle directory `INPUT_DIR`), that contains arrays of expected and actual records by group and scenario.

The unit test program may be run from the Oracle lib subfolder:

```
SQL> @r_tests
```

The output file is processed by a nodejs program that has to be installed separately from the `npm` nodejs repository, as described in the Trapit install in `Install 1` above. The nodejs program produces listings of the results in HTML and/or text format, and a sample set of listings is included in the subfolder test_output.

To run the processor, open a powershell window in the npm trapit package folder after placing the output JSON file, tt_timer_set.purely_wrap_timer_set_out.json, in a new (or existing) folder, oracle_plsql (say), within the trapit subfolder externals and run:

```
$ node externals\format-externals oracle_plsql
```
```

This creates, or updates, a subfolder, oracle-pl_sql-timer-set, with the formatted results output files. The three testing steps can easily be automated in Powershell (or Unix bash).

[An easy way to generate a starting point for the input JSON file is to use a powershell utility [Powershell Utilites module](https://github.com/BrenPatF/powershell_utils) to generate a template file with a single scenario with placeholder records from simple .csv files. See the script purely_wrap_timer_set.ps1 in the `test_data` subfolder for an example]

### Wrapper Function Signature Diagram
- [&uarr; Unit Testing](https://github.com/BrenPatF/timer_set_oracle#unit-testing)

<img src="test_data\timer_set_oracleJSD.png">

### Unit Test Scenarios
- [&uarr; Unit Testing](https://github.com/BrenPatF/timer_set_oracle#unit-testing)
- [Input Data Category Sets](https://github.com/BrenPatF/timer_set_oracle#input-data-category-sets)
- [Scenario Results](https://github.com/BrenPatF/timer_set_oracle#scenario-results)

The art of unit testing lies in choosing a set of scenarios that will produce a high degree of confidence in the functioning of the unit under test across the often very large range of possible inputs.

A useful approach to this can be to think in terms of categories of inputs, where we reduce large ranges to representative categories. In our case we might consider the following category sets, and create scenarios accordingly.

#### Input Data Category Sets
- [&uarr; Unit Test Scenarios](https://github.com/BrenPatF/timer_set_oracle#unit-test-scenarios)
- [Value Size](https://github.com/BrenPatF/timer_set_oracle#Value-Size)
- [Multiplicity (decimal places, timers, timings)](https://github.com/BrenPatF/timer_set_oracle#multiplicity--decimal-places--timers--timings-)
- [Concurrency](https://github.com/BrenPatF/timer_set_oracle#concurrency)
- [Parameter Defaults (each parameter)](https://github.com/BrenPatF/timer_set_oracle#parameter-defaults--each-parameter-)
- [Timings Mocked](https://github.com/BrenPatF/timer_set_oracle#timings-mocked)
- [Exceptions](https://github.com/BrenPatF/timer_set_oracle#exceptions)
- [API Calls](https://github.com/BrenPatF/timer_set_oracle#api-calls)

##### Value Size
- [&uarr; Input Data Category Sets](https://github.com/BrenPatF/timer_set_oracle#input-data-category-sets)

Check very small numbers or strings and very large ones do not cause value or display errors
- Small
- Large 

##### Multiplicity (decimal places, timers, timings)
- [&uarr; Input Data Category Sets](https://github.com/BrenPatF/timer_set_oracle#input-data-category-sets)

Check edge cases of zero decimal places and zero timers in a set, and also normal cases of multiple, and check that timers work with 1 and multiple calls
- 0
- 1
- Multiple

##### Concurrency
- [&uarr; Input Data Category Sets](https://github.com/BrenPatF/timer_set_oracle#input-data-category-sets)

Check that timer sets with overlapping durations do not interfere with each other
- Concurrent timer sets
- No concurrent timer sets 

##### Parameter Defaults (each parameter)
- [&uarr; Input Data Category Sets](https://github.com/BrenPatF/timer_set_oracle#input-data-category-sets)

Check that parameters default as expected, and also are overridden by values passed
- Defaulted
- Non-defaulted


##### Timings Mocked
- [&uarr; Input Data Category Sets](https://github.com/BrenPatF/timer_set_oracle#input-data-category-sets)

Check with mocked timings that the numeric aggregations work exactly, and also check with unmocked timings that the system timing APIs are called correctly
- Mocked
- Non-mocked

##### Exceptions
- [&uarr; Input Data Category Sets](https://github.com/BrenPatF/timer_set_oracle#input-data-category-sets)

Check that validations return exceptions correctly
- None
- Decimal places invalid

##### API Calls
- [&uarr; Input Data Category Sets](https://github.com/BrenPatF/timer_set_oracle#input-data-category-sets)

Check that all entry points work. Note that these are represented by different values for the event type wrapper function input parameter
- Construct
- Init_Time
- Increment_Time
- Get_Timers
- Format_Timers
- Get_Self_Timer  
- Format_Self_Timer
- Format_Results

#### Scenario Results
- [&uarr; Unit Test Scenarios](https://github.com/BrenPatF/timer_set_oracle#unit-test-scenarios)
- [Results Summary](https://github.com/BrenPatF/timer_set_oracle#results-summary)
- [Results for Scenario 1](https://github.com/BrenPatF/timer_set_oracle#results-for-scenario-1)

##### Results Summary
- [&uarr; Scenario Results](https://github.com/BrenPatF/timer_set_oracle#scenario-results)

The summary report in text format shows the scenarios tested:

      #    Scenario                                                                                                                                          Fails (of 9)  Status 
      ---  ------------------------------------------------------------------------------------------------------------------------------------------------  ------------  -------
      1    2 timer sets, ts-1: timer-1 called twice, timer-2 called in between; ts-2: timer-1 called twice, initTime called in between; all outputs; mocked  0             SUCCESS
      2    As scenario 1 but not mocked, and with SELFs                                                                                                      0             SUCCESS
      3    Large numbers, mocked                                                                                                                             0             SUCCESS
      4    Small numbers, mocked                                                                                                                             0             SUCCESS
      5    Non-default DP, mocked                                                                                                                            0             SUCCESS
      6    Zero DP, mocked                                                                                                                                   0             SUCCESS
      7    Error DP, mocked                                                                                                                                  0             SUCCESS
      8    Timer Set with no timers                                                                                                                          0             SUCCESS

##### Results for Scenario 1
- [&uarr; Scenario Results](https://github.com/BrenPatF/timer_set_oracle#scenario-results)

<pre>
SCENARIO 1: 2 timer sets, ts-1: timer-1 called twice, timer-2 called in between; ts-2: timer-1 called twice, initTime called in between; all outputs; mocked {
==============================================================================================================================================================

   INPUTS
   ======

      GROUP 1: Event Sequence {
      =========================

            #   Set Name  Timer Name  Event  Elapsed Time (s)  CPU Time (cs)
            --  --------  ----------  -----  ----------------  -------------
            1   Set 1                 CON    3.000             80           
            2   Set 1     Timer 1     INC    33.123            926          
            3   Set 2                 CON    33.123            926          
            4   Set 1     Timer 2     INC    63.246            1771         
            5   Set 1     Timer 1     INC    93.369            2617         
            6   Set 2     Timer 1     INC    123.492           3462         
            7   Set 2                 INI    153.615           4308         
            8   Set 2     Timer 1     INC    183.738           5154         
            9   Set 1                 GET    213.861           5999         
            10  Set 1                 GETF   213.861           5999         
            11  Set 1                 RES    213.861           5999         
            12  Set 2                 GET    213.861           5999         

      }
      =

      GROUP 2: Scalars {
      ==================

            #  Mock Flag  Time Width  Decimal Places (Totals)  Decimal Places (per call)  Calls Width
            -  ---------  ----------  -----------------------  -------------------------  -----------
            1  Y                                                                                     

      }
      =

   OUTPUTS
   =======

      GROUP 1: Set 1 {
      ================

            #  Timer Name  Elapsed Time  CPU Time  #Calls
            -  ----------  ------------  --------  ------
            1  Timer 1     60.246        16.92     2     
            2  Timer 2     30.123        8.45      1     
            3  (Other)     120.492       33.82     1     
            4  Total       210.861       59.19     4     

      } 0 failed of 4: SUCCESS
      ========================

      GROUP 2: Set 1 (formatted) {
      ============================

            #  Line                                                                     
            -  -------------------------------------------------------------------------
            1  Timer       Elapsed         CPU       Calls       Ela/Call       CPU/Call
            2  -------  ----------  ----------  ----------  -------------  -------------
            3  Timer 1       60.25       16.92           2       30.12300        8.46000
            4  Timer 2       30.12        8.45           1       30.12300        8.45000
            5  (Other)      120.49       33.82           1      120.49200       33.82000
            6  -------  ----------  ----------  ----------  -------------  -------------
            7  Total        210.86       59.19           4       52.71525       14.79750
            8  -------  ----------  ----------  ----------  -------------  -------------

      } 0 failed of 8: SUCCESS
      ========================

      GROUP 3: Set 2 {
      ================

            #  Timer Name  Elapsed Time  CPU Time  #Calls
            -  ----------  ------------  --------  ------
            1  Timer 1     120.492       33.82     2     
            2  (Other)     60.246        16.91     1     
            3  Total       180.738       50.73     3     

      } 0 failed of 3: SUCCESS
      ========================

      GROUP 4: Set 2 (formatted): Empty as expected: SUCCESS
      ======================================================

      GROUP 5: Self (unmocked): Empty as expected: SUCCESS
      ====================================================

      GROUP 6: Self (unmocked, formatted): Empty as expected: SUCCESS
      ===============================================================

      GROUP 7: Results {
      ==================

            #   Lines                                                                                                                 
            --  ----------------------------------------------------------------------------------------------------------------------
            1   LIKE /Timer Set: Set 1, Constructed at .*/: Timer Set: Set 1, Constructed at 01 Jan 2019 00:00:03, written at 07:57:39
            2   ==========================================================================                                            
            3   Timer       Elapsed         CPU       Calls       Ela/Call       CPU/Call                                             
            4   -------  ----------  ----------  ----------  -------------  -------------                                             
            5   Timer 1       60.25       16.92           2       30.12300        8.46000                                             
            6   Timer 2       30.12        8.45           1       30.12300        8.45000                                             
            7   (Other)      120.49       33.82           1      120.49200       33.82000                                             
            8   -------  ----------  ----------  ----------  -------------  -------------                                             
            9   Total        210.86       59.19           4       52.71525       14.79750                                             
            10  -------  ----------  ----------  ----------  -------------  -------------                                             
            11  LIKE /\[Timer timed.*\]/: [Timer timed (per call in ms): Elapsed: 0.02020, CPU: 0.02200]                              

      } 0 failed of 11: SUCCESS
      =========================

      GROUP 8: Exception: Empty as expected: SUCCESS
      ==============================================

      GROUP 9: Unhandled Exception: Empty as expected: SUCCESS
      ========================================================

} 0 failed of 9: SUCCESS
========================
</pre>

You can review the formatted unit test results here, [Unit Test Report: Oracle PL/SQL Timer Set](http://htmlpreview.github.io/?https://github.com/BrenPatF/timer_set_oracle/blob/master/test_data/test_output/oracle-pl_sql-timer-set/oracle-pl_sql-timer-set.html), and the files are available in the `test_data\test_output\oracle-pl_sql-timer-set` subfolder [oracle-pl_sql-timer-set.html is the root page for the HTML version and oracle-pl_sql-timer-set.txt has the results in text format].

## Operating System/Oracle Versions
- [&uarr; In this README...](https://github.com/BrenPatF/timer_set_oracle#in-this-readme)

### Windows
Windows 10, should be OS-independent

### Oracle
- Tested on Oracle Database Version 18.3.0.0.0
- Base code (and example) should work on earlier versions at least as far back as v10 and v11

## See also
- [Utils - Oracle PL/SQL general utilities module](https://github.com/BrenPatF/oracle_plsql_utils)
- [Trapit - Oracle PL/SQL unit testing module](https://github.com/BrenPatF/trapit_oracle_tester)
- [Log_Set - Oracle logging module](https://github.com/BrenPatF/log_set_oracle)
- [Trapit - nodejs unit test processing package](https://github.com/BrenPatF/trapit_nodejs_tester)
- [Oracle PL/SQL API Demos - demonstrating instrumentation and logging, code timing and unit testing of Oracle PL/SQL APIs](https://github.com/BrenPatF/oracle_plsql_api_demos)
- [Code Timing and Object Orientation and Zombies, Brendan Furey, November 2010](http://www.scribd.com/doc/43588788/Code-Timing-and-Object-Orientation-and-Zombies)
   
## License
MIT