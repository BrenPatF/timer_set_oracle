# Timer_Set
Oracle PL/SQL code timing module.

Oracle PL/SQL package that facilitates code timing for instrumentation and other purposes, with very small footprint in both code and resource usage. Construction and reporting require only a single line each, regardless of how many timers are included in a set.

See [Code Timing and Object Orientation and Zombies](http://www.scribd.com/doc/43588788/Code-Timing-and-Object-Orientation-and-Zombies), November 2010, for the original idea implemented in Oracle PL/SQL, Perl and Java.

The package is tested using the Math Function Unit Testing design pattern, with test results in HTML and text format included. See test_output\timer_set.html for the unit test results root page.

## Usage (extract from main_col_group.sql)
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

### Timer_Set.Get_Self_Timer
Static method to time the Increment_Time method as a way of estimating the overhead in using the timer set. Constructs a timer set instance and calls Increment_Time on it within a loop until 0.1s has elapsed.

Returns a tuple, with fields:

* `ela`: elapsed time per call in ms
* `cpu`: CPU time per call in ms

### Timer_Set.Format_Self_Timer(l_format_prms)
Static method to return the results from Get_Self_Timer in a formatted string, with parameter as Format_Timers (but any extra spaces are trimmed here).

### Timer_Set.Format_Results(l_timer_set, l_format_prms)
Returns the results for timer set `l_timer_set` in a formatted string, with parameters as Format_Timers. It uses the array returned from Format_Timers and includes a header line with timer set construction and writing times, and a footer of the self-timing values.

## Installation
The install depends on the pre-requisite module Utils, and `lib` schema refers to the schema in which Utils is installed.

### Install 1: Install Utils module (if not present)
#### [Schema: lib; Folder: (Utils) lib]
- Download and install the Utils module:
[Utils on GitHub](https://github.com/BrenPatF/oracle_plsql_utils)

The base Utils install is required for the base Timer_Set install, while the unit test install and running the example require the corresponding Utils install sections.

### Install 2: Create Timer_Set components
#### [Schema: lib; Folder: lib]
- Run script from slqplus:
```
SQL> @install_timer_set
```
This creates the required components for the base install along with public synonyms and grants for them. This install is all that is required to use the package.

### Install 3: Install unit test code
#### [Schema: lib; Folder: lib]
- Copy the following file from the root folder to the server folder pointed to by the Oracle directory INPUT_DIR:
  - tt_timer_set.test_api_inp.json
- Run script from slqplus:
```
SQL> @install_timer_set_tt
```

## Unit testing
The unit test program (if installed) may be run from the lib subfolder:

SQL> @r_tests

The program is data-driven from the input file tt_timer_set.test_api_inp.json and produces an output file tt_timer_set.test_api_out.json, that contains arrays of expected and actual records by group and scenario.

The output file is processed by a nodejs program that has to be installed separately from the `npm` nodejs repository, as described in the Trapit install in `Install 1` above. The nodejs program produces listings of the results in HTML and/or text format, and a sample set of listings is included in the subfolder test_output. To run the processor (in Windows), open a DOS or Powershell window in the trapit package folder after placing the output JSON file, tt_timer_set.test_api_out.json, in the subfolder ./examples/externals and run:
```
$ node ./examples/externals/test-externals
```
The three testing steps can easily be automated in Powershell (or Unix bash).

The package is tested using the Math Function Unit Testing design pattern (`See also - Trapit` below). In this approach, a 'pure' wrapper function is constructed that takes input parameters and returns a value, and is tested within a loop over scenario records read from a JSON file.

The wrapper function represents a generalised transactional use of the package in which multiple timer sets may be constructed, and then timings carried out and reported on at the end of the transaction. 

This kind of package would usually be thought hard to unit-test, with CPU and elapsed times being inherently non-deterministic. However, this is a good example of the power of the design pattern that I recently introduced: One of the inputs is a yes/no flag indicating whether to mock the system timing calls, or not. The timer set `Construct` method takes as an optional parameter an array containing a stream of mocked elapsed and  CPU times read from the input scenario data. 

In the non-mocked scenarios standard function calls are made to return elapsed and epochal CPU times, while in the mocked scenarios these are bypassed, and deterministic values read from the input array.

In this way we can test correctness of the timing aggregations, independence of timer sets etc. using the deterministic values; on the other hand, one of the key benefits of automated unit testing is to test the actual dependencies, and we do this in the non-mocked case by passing in 'sleep' times to the wrapper function and testing the outputs against ranges of values.

You can review the  unit test formatted results obtained by the author in the `test_output` subfolder [timer_set.html is the root page for the HTML version and timer_set.txt has the results in text format].

## Operating System/Oracle Versions
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
- [Code Timing and Object Orientation and Zombies, Brendan Furey, November 2010](http://www.scribd.com/doc/43588788/Code-Timing-and-Object-Orientation-and-Zombies)
   
## License
MIT