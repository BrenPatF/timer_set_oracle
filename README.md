# Timer_Set
Oracle PL/SQL package that facilitates code timing for instrumentation and other purposes, with very small footprint in both code and resource usage. Construction and reporting require only a single line each, regardless of how many timers are included in a set.

## Usage (extract from main_col_group.sql)
```sql
DECLARE
  l_timer_set   PLS_INTEGER := Timer_Set.Construct('Col Group');

BEGIN

  Col_Group.AIP_Load_File(p_file => CSV_FILE, p_delim => DELIM, p_colnum => COLNUM);
  Timer_Set.Increment_Time(l_timer_set, 'Load File');
.
.
.
  Print_Results('Sorted by Value, Key', Col_Group.AIP_Sort_By_Value);
  Timer_Set.Increment_Time(l_timer_set, 'Sort_By_Value');
  Utils.Write_Log(Timer_Set.Format_Results(l_timer_set));
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
To run the example in a slqplus session from app subfolder (after installation):

SQL> @main_col_group

## API
### l_timer_set   PLS_INTEGER := Timer_Set.Construct('ts_name')
Constructs a new timer set with name `ts_name`, and integer handle `l_timer_set`.

### Timer_Set.Increment_Time(l_timer_set, timer_name)
Increments the timing statistics (elapsed, user and system CPU, and number of calls) for a timer `timer_name` within the timer set `l_timer_set` with the times passed since the previous call to Increment_Time, Init_Time or the constructor of the timer set instance. Resets the statistics for timer set `l_timer_set` to the current time, so that the next call to increment_time measures from this point for its increment.

### Timer_Set.Increment_Time(l_timer_set)
Resets the statistics for timer set `l_timer_set` to the current time, so that the next call to increment_time measures from this point for its increment. This is only used where there are gaps between sections to be timed.

### Timer_Set.Get_Timers(l_timer_set)
Returns the results for timer set `l_timer_set` in an array of records of type `Timer_Set.timer_stat_rec`, with fields:

* `name`: timer name
* `ela_secs`: elapsed time in seconds
* `cpu_secs`: CPU time in seconds
* `calls`: number of calls

After a record for each named timer, in order of creation, there are two calculated records:

* `Other`: differences between `Total` values and the sums of the named timers
* `Total`: totals calculated from the times at timer set construction

### Timer_Set.Format_Timers(l_timer_set, l_format_prms)
Returns the results for timer set `l_timer_set` in an array of formatted strings, including column headers and formatting lines, with fields as in Get_Timers, times in seconds, and per call values added, with l_format_prms record parameter of type `Timer_Set.format_prm_rec` and default `Timer_Set.FORMAT_PRMS_DEF`:

* `time_width`: width of time fields (excluding decimal places), default 8
* `time_dp`: decimal places to show for absolute time fields, default 2
* `time_ratio_dp`: decimal places to show for per call time fields, default 5
* `calls_width`: width of calls field, default 10

### TimerSet.Get_Self_Timer
Static method to time the Increment_Time method as a way of estimating the overhead in using the timer set. Constructs a timer set instance and calls Increment_Time on it within a loop until 0.1s has elapsed.

Returns a tuple, with fields:

* `ela`: elapsed time per call in ms
* `cpu`: CPU time per call in ms

### TimerSet.Format_Self_Timer(l_format_prms)
Static method to return the results from Get_Self_Timer in a formatted string, with parameter as Format_Timers (but any extra spaces are trimmed here).

### TimerSet.Format_Results(l_timer_set, l_format_prms)
Returns the results for timer set `l_timer_set` in a formatted string, with parameters as Format_Timers. It uses the array returned from Format_Timers and includes a header line with timer set construction and writing times, and a footer of the self-timing values.

## Installation
You can install just the base code in an existing schema, or alternatively, install base code plus an example of usage, and unit testing code, in two new schemas, `lib` and `app`.
### Install (base code only)
To install the base code only, comprising 4 object types and two packages, run the following script in a sqlplus session in the desired schema from the lib subfolder:

SQL> @install_lib

This creates the required objects along with public synonyms and grants for them. It does not include the example or the unit test code, the latter of which requires a minimum Oracle database version of 12.2.

### Install (base code plus example and unit test code)
The extended installation requires a minimum Oracle database version of 12.2, and processing the unit test output file requires a separate nodejs install from npm. You can review the results from the example code in the `app` subfolder, and the unit test formatted results in the `test_output` subfolder, without needing to do the extended installation [timer_set.html is the root page for the HTML version and timer_set.txt has the results in text format].
- install_sys.sql creates an Oracle directory, `input_dir`, pointing to 'c:\input'. Update this if necessary to a folder on the database server with read/write access for the Oracle OS user
- Copy the following files from the root folder to the `input_dir` folder:
	- fantasy_premier_league_player_stats.csv
	- tt_timer_set.json
- Run the install scripts from the specified folders in sqlplus sessions for the specified schemas

#### Root folder, sys schema
SQL> @install_sys

#### lib subfolder, lib schema
SQL> @install_lib

SQL> @install_lib_tt

#### app subfolder, app schema
SQL> @install_app

## Unit testing
The unit test program (if installed) may be run from the lib subfolder:

SQL> @r_tests

The program is data-driven from the input file tt_timer_set.json and produces an output file tt_timer_set.tt_main_out.json, that contains arrays of expected and actual records by group and scenario.

The output file can be processed by a Javascript program that has to be downloaded separately from the `npm` Javascript repository. The Javascript program produces listings of the results in html and/or text format, and a sample set of listings is included in the subfolder test_output. To install the Javascript program, `trapit`:

With [npm](https://npmjs.org/) installed, run

```
$ npm install trapit
```

The package is tested using the Math Function Unit Testing design pattern (`See also` below). In this approach, a 'pure' wrapper function is constructed that takes input parameters and returns a value, and is tested within a loop over scenario records read from a JSON file.

The wrapper function represents a generalised transactional use of the package in which multiple timer sets may be constructed, and then timings carried out and reported on at the end of the transaction. 

This kind of package would usually be thought hard to unit-test, with CPU and elapsed times being inherently non-deterministic. However, this is a good example of the power of the design pattern that I recently introduced: One of the inputs is a yes/no flag indicating whether to mock the system timing calls, or not. The timer set `Construct` method takes as an optional parameter an array containing a stream of mocked elapsed and  CPU times read from the input scenario data. 

In the non-mocked scenarios standard function calls are made to return elapsed and epochal CPU times, while in the mocked scenarios these are bypassed, and deterministic values read from the input array.

In this way we can test correctness of the timing aggregations, independence of timer sets etc. using the deterministic values; on the other hand, one of the key benefits of automated unit testing is to test the actual dependencies, and we do this in the non-mocked case by passing in 'sleep' times to the wrapper function and testing the outputs against ranges of values.

## Operating System/Oracle Versions
### Windows
Windows 10
### Oracle
- Tested on Oracle Database 12c 12.2.0.1.0 
- Base code (and example) should work on earlier versions at least as far back as v10 and v11

## See also
- [trapit - nodejs unit test processing package on GitHub](https://github.com/BrenPatF/trapit_nodejs_tester)
- [nodejs version of timer set package on GitHub](https://github.com/BrenPatF/timer-set-nodejs)
- [python version of timer set package on GitHub](https://github.com/BrenPatF/timerset_python)
- [Code Timing and Object Orientation and Zombies, Brendan Furey, November 2010](http://www.scribd.com/doc/43588788/Code-Timing-and-Object-Orientation-and-Zombies)
   
## License
MIT