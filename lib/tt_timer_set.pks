CREATE OR REPLACE PACKAGE TT_Timer_Set AS
/***************************************************************************************************
Name: tt_timer_set.pks                 Author: Brendan Furey                       Date: 29-Jan-2019

Package spec component in the Oracle timer_set_oracle module. This module facilitates code timing
for instrumentation and other purposes, with very small footprint in both code and resource usage.

GitHub: https://github.com/BrenPatF/timer_set_oracle

See 'Code Timing and Object Orientation and Zombies' for the original idea implemented in Oracle 
   PL/SQL, Perl and Java
   http://www.scribd.com/doc/43588788/Code-Timing-and-Object-Orientation-and-Zombies
   Brendan Furey, November 2010

There is an example main program and package showing how to use the Timer_Set package, and a unit 
test program.
====================================================================================================
|  Main/Test       |  Unit Module   |  Notes                                                       |
|===================================================================================================
|  main_col_group  |  Col_Group     |  Simple file-reading and group-counting module, with logging |
|                  |                |  to file. Example of usage of Timer_Set package              |
----------------------------------------------------------------------------------------------------
|  r_tests         | *TT_Timer_Set* |  Unit testing the Timer_Set package                          |
====================================================================================================

This file has the unit test TT_Timer_Set package spec (lib schema). Note that the test package is
called by the unit test utility package Utils_TT, which reads the unit test details from a table,
tt_units, populated by the install scripts. 

The test program follows 'The Math Function Unit Testing design pattern':

GitHub: https://github.com/BrenPatF/trapit_nodejs_tester

Note that the unit test program generates an output tt_timer_set.tt_main_out.json file that is processed by a
separate nodejs program, npm package trapit. This can be installed via npm (npm and nodejs 
required):

$ npm install trapit

The output json file contains arrays of expected and actual records by group and scenario, in the
format expected by the Javascript program. The Javascript program produces listings of the results
in html and/or text format, and a sample set of listings is included in the folder test.

See also the app schema main_col_group script which gives a simple example use-case for the
Timer_Set package.

***************************************************************************************************/

PROCEDURE Test_API;

END TT_Timer_Set;
/
