@..\initspool main_col_group
/***************************************************************************************************
Name: main_col_group.sql               Author: Brendan Furey                       Date: 29-Jan-2019

Driver script component in the timer_set_oracle module. This module facilitates code timing for
instrumentation and other purposes, with very small footprint in both code and resource usage.

    GitHub: https://github.com/BrenPatF/timer_set_oracle

There is an example main program showing how to use the Timer_Set package, and a unit test program,
which is driven by a Powershell script, as described in the README.

This file has the driver script for the example code calling the Timer_Set methods.
***************************************************************************************************/
DECLARE
  l_timer_set   PLS_INTEGER := Timer_Set.Construct('Col Group');

  PROCEDURE Print_Results(p_name VARCHAR2, p_res_arr chr_int_arr) IS
    l_len_lis   L1_num_arr := L1_num_arr(30, -5);
  BEGIN

    Utils.W(p_line_lis => Utils.Heading(p_name));
    Utils.W(p_line_lis => Utils.Col_Headers(p_value_lis => chr_int_arr(chr_int_rec('Team', 30), 
                                                                       chr_int_rec('Apps', -5)
    )));
    FOR i IN 1..p_res_arr.COUNT LOOP
      Utils.W(p_line => Utils.List_To_Line(
                          p_value_lis => chr_int_arr(chr_int_rec(p_res_arr(i).chr_value, 30), 
                                                     chr_int_rec(p_res_arr(i).int_value, -5)
    )));
    END LOOP;

  END Print_Results;

BEGIN

  Col_Group.Load_File(p_file   => 'fantasy_premier_league_player_stats.csv', 
                      p_delim  => ',', 
                      p_colnum => 7);
  Timer_Set.Increment_Time(l_timer_set, 'Load File');
  Print_Results('As Is', Col_Group.List_Asis);
  Timer_Set.Increment_Time(l_timer_set, 'List_Asis');
  Print_Results('Sorted by Key', Col_Group.Sort_By_Key);
  Timer_Set.Increment_Time(l_timer_set, 'Sort_By_Key');
  Print_Results('Sorted by Value, Key', Col_Group.Sort_By_Value);
  Timer_Set.Increment_Time(l_timer_set, 'Sort_By_Value');
  Utils.W(p_line_lis => Timer_Set.Format_Results(l_timer_set));
END;
/

@..\endspool