CREATE OR REPLACE PACKAGE TT_Timer_Set AS
/***************************************************************************************************
Name: tt_timer_set.pks                 Author: Brendan Furey                       Date: 29-Jan-2019

Package spec component in the Oracle timer_set_oracle module. This module facilitates code timing
for instrumentation and other purposes, with very small footprint in both code and resource usage.

    GitHub: https://github.com/BrenPatF/timer_set_oracle

There is an example main program and package showing how to use the Timer_Set package, and a unit 
test program. Unit testing is optional and depends on the module trapit_oracle_tester
====================================================================================================
|  Main/Test       |  Unit Module   |  Notes                                                       |
|==================================================================================================|
|  main_col_group  |  Col_Group     |  Simple file-reading and group-counting module, with logging |
|                  |                |  to file. Example of usage of Timer_Set package              |
|------------------|----------------|--------------------------------------------------------------|
|  r_tests         | *TT_Timer_Set* |  Unit testing the Timer_Set package. Trapit_Run is installed |
|                  |  Trapit_Run    |  aa part of a separate module, trapit_oracle_tester          |
====================================================================================================

This file has the TT_Timer_Set unit test package spec. Note that the test package is called by the
unit test utility package Trapit_Run, which reads the unit test details from a table, tt_units, 
populated by the install scripts.

The test program follows 'The Math Function Unit Testing design pattern':

    GitHub: https://github.com/BrenPatF/trapit_nodejs_tester

Note that the unit test program generates an output file,
tt_timer_set.purely_wrap_timer_set_out.json, that is processed by a separate nodejs program, npm
package trapit (see README for further details).

The output JSON file contains arrays of expected and actual records by group and scenario, in the
format expected by the nodejs program. This program produces listings of the results in HTML and/or
text format, and a sample set of listings is included in the folder test_data\test_output

***************************************************************************************************/

/***************************************************************************************************
Purely_Wrap_Timer_Set: Unit test wrapper function for the Timer_Set package

    Returns the 'actual' outputs, given the inputs for a scenario, with the signature expected for
    the Math Function Unit Testing design pattern, namely:

      Input parameter: 3-level list (type L3_chr_arr) with test inputs as group/record/field
      Return Value: 2-level list (type L2_chr_arr) with test outputs as group/record (with record as
                   delimited fields string)

***************************************************************************************************/
FUNCTION Purely_Wrap_Timer_Set(
            p_inp_3lis                     L3_chr_arr) -- input list of lists (group, record, field)
            RETURN                         L2_chr_arr; -- output list of lists (group, record)

END TT_Timer_Set;
/
