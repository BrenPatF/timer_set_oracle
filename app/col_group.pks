CREATE OR REPLACE PACKAGE Col_Group AS
/***************************************************************************************************
Name: col_group.pks                    Author: Brendan Furey                       Date: 29-Jan-2019

Package spec component in the Oracle timer_set_oracle module. This module facilitates code timing
for instrumentation and other purposes, with very small footprint in both code and resource usage.

See 'Code Timing and Object Orientation and Zombies' for the original idea implemented in Oracle 
   PL/SQL, Perl and Java
   http://www.scribd.com/doc/43588788/Code-Timing-and-Object-Orientation-and-Zombies
   Brendan Furey, November 2010

There is an example main program and package showing how to use the Timer_Set package, and a unit 
test program.
====================================================================================================
|  Main/Test       |  Package       |  Notes                                                       |
|===================================================================================================
|  main_col_group  | *Col_Group*    |  Simple file-reading and group-counting module, with code    |
|                  |                |  timing. Example showing how to use the Timer_Set package    |
----------------------------------------------------------------------------------------------------
|  r_tests         |  TT_Timer_Set  |  Unit testing the Timer_Set package                          |
|                  |  Utils_TT      |                                                              |
====================================================================================================

This file has the example Col_Group package spec (app schema). The package reads delimited lines 
from file, and counts values in a given column, with methods to return the counts in various 
orderings. It is used here as a simple example of how to use the code timing package.

***************************************************************************************************/

PROCEDURE AIP_Load_File (p_file VARCHAR2, p_delim VARCHAR2, p_colnum PLS_INTEGER);
FUNCTION AIP_List_Asis RETURN chr_int_arr;
FUNCTION AIP_Sort_By_Key RETURN chr_int_arr;
FUNCTION AIP_Sort_By_Value RETURN chr_int_arr;

END Col_Group;
/
SHO ERR



