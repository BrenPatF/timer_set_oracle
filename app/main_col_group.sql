@..\InitSpool main_col_group
/***************************************************************************************************
Name: main_col_group.sql               Author: Brendan Furey                       Date: 29-Jan-2019

Driver script component in the Oracle timer_set_oracle module. This module facilitates code timing
for instrumentation and other purposes, with very small footprint in both code and resource usage.

See 'Code Timing and Object Orientation and Zombies' for the original idea implemented in Oracle 
   PL/SQL, Perl and Java
   http://www.scribd.com/doc/43588788/Code-Timing-and-Object-Orientation-and-Zombies
   Brendan Furey, November 2010

There is an example main program and package showing how to use the Timer_Set package, and a unit 
test program.
====================================================================================================
|  Main/Test .sql  |  Package       |  Notes                                                       |
|===================================================================================================
| *main_col_group* |  Col_Group     |  Simple file-reading and group-counting module, with code    |
|                  |                |  timing. Example showing how to use the Timer_Set package    |
----------------------------------------------------------------------------------------------------
|  r_tests         |  TT_Timer_Set  |  Unit testing the Timer_Set package                          |
|                  |  Utils_TT      |                                                              |
====================================================================================================

This file has the driver script for the example Col_Group package body (app schema). The package 
reads delimited lines from file, and counts values in a given column, with methods to return the
counts in various orderings. 

It is used here as a simple example of how to use the code timing package. After the initial call to
the Construct method (line 37), there is a single call to Increment_Time after each section to be
timed (line 56 etc.), with a call to Format_Results at the end (line 63).

***************************************************************************************************/
DECLARE
  CSV_FILE      CONSTANT VARCHAR2(60) := 'fantasy_premier_league_player_stats.csv';
  DELIM         CONSTANT VARCHAR2(60) := ',';
  COLNUM        CONSTANT VARCHAR2(60) := '7';
  l_timer_set   PLS_INTEGER := Timer_Set.Construct('Col Group');

  PROCEDURE Print_Results(p_name VARCHAR2, p_res_arr chr_int_arr) IS
    l_len_lis   L1_num_arr := L1_num_arr(30, -5);
  BEGIN

    Utils.Write_Log(Utils.Heading(p_name));
    Utils.Write_Log(Utils.Col_Headers(L1_chr_arr('Team', 'Apps'), 
                                      l_len_lis));
    FOR i IN 1..p_res_arr.COUNT LOOP
      Utils.Write_Log(Utils.List_To_Line(L1_chr_arr(p_res_arr(i).chr_field, p_res_arr(i).int_field), 
                                         l_len_lis));
    END LOOP;

  END Print_Results;

BEGIN

  Col_Group.AIP_Load_File(p_file => CSV_FILE, p_delim => DELIM, p_colnum => COLNUM);
  Timer_Set.Increment_Time(l_timer_set, 'Load File');
  Print_Results('As Is', Col_Group.AIP_List_Asis);
  Timer_Set.Increment_Time(l_timer_set, 'List_Asis');
  Print_Results('Sorted by Key', Col_Group.AIP_Sort_By_Key);
  Timer_Set.Increment_Time(l_timer_set, 'Sort_By_Key');
  Print_Results('Sorted by Value, Key', Col_Group.AIP_Sort_By_Value);
  Timer_Set.Increment_Time(l_timer_set, 'Sort_By_Value');
  Utils.Write_Log(Timer_Set.Format_Results(l_timer_set));
END;
/

@..\EndSpool