@..\initspool r_tests
/***************************************************************************************************
Name: r_tests.sql                      Author: Brendan Furey                       Date: 29-Jan-2019

Driver script component in the Oracle timer_set_oracle module. This module facilitates code timing
for instrumentation and other purposes, with very small footprint in both code and resource usage.

	GitHub: https://github.com/BrenPatF/timer_set_oracle

There is an example main program and package showing how to use the Timer_Set package, and a unit 
test program. Unit testing is optional and depends on the module trapit_oracle_tester.
====================================================================================================
|  Main/Test .sql  |  Package       |  Notes                                                       |
|===================================================================================================
|  main_col_group  |  Col_Group     |  Example showing how to use the Timer_Set package. Col_Group |
|                  |                |  is a simple file-reading and group-counting package         |
|                  |                |  installed via the oracle_plsql_utils module                 |
----------------------------------------------------------------------------------------------------
| *r_tests*        |  TT_Timer_Set  |  Unit testing the Timer_Set package. Trapit is installed as  |
|                  |  Trapit        |  a separate module                                           |
====================================================================================================

This file has the driver script for the unit tests. Note that the test package is called by the unit
test utility package Trapit, which reads the unit test details from a table, tt_units, populated by
the install scripts. 

The test program follows 'The Math Function Unit Testing design pattern':

	GitHub: https://github.com/BrenPatF/trapit_nodejs_tester

Note that the unit test program generates an output file, tt_timer_set.test_api_out.json, that is 
processed by a separate nodejs program, npm package trapit (see README for further details).

The output JSON file contains arrays of expected and actual records by group and scenario, in the
format expected by the nodejs program. The nodejs program produces listings of the results in HTML
and/or text format, and a sample set of listings is included in the folder test_output.

***************************************************************************************************/
DEFINE LIB=lib
BEGIN

  Trapit_Run.Run_Tests('&LIB');

END;
/
@..\endspool