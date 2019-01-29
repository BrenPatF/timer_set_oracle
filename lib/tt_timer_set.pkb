CREATE OR REPLACE PACKAGE BODY TT_Timer_Set AS
/***************************************************************************************************
Name: tt_timer_set.pkb                 Author: Brendan Furey                       Date: 29-Jan-2019

Package body component in the Oracle timer_set_oracle module. This module facilitates code timing
for instrumentation and other purposes, with very small footprint in both code and resource usage.

GitHub: https://github.com/BrenPatF/timer_set_oracle

See 'Code Timing and Object Orientation and Zombies' for the original idea implemented in Oracle 
   PL/SQL, Perl and Java
   http://www.scribd.com/doc/43588788/Code-Timing-and-Object-Orientation-and-Zombies
   Brendan Furey, November 2010

There is an example main program and package showing how to use the Timer_Set package, and a unit 
test program.
====================================================================================================
|  Main/Test .sql  |  Package       |  Notes                                                       |
|===================================================================================================
|  main_col_group  |  Col_Group     |  Example showing how to use the Timer_Set package            |
----------------------------------------------------------------------------------------------------
|  r_tests         | *TT_Timer_Set* |  Unit testing the Timer_Set package                          |
|                  |  Utils_TT      |                                                              |
====================================================================================================

This file has the unit test TT_Timer_Set package body (lib schema). Note that the test package is
called by the unit test utility package Utils_TT, which reads the unit test details from a table,
tt_units, populated by the install scripts.

The test program follows 'The Math Function Unit Testing design pattern':

GitHub: https://github.com/BrenPatF/trapit_nodejs_tester

Note that the unit test program generates an output timerset_out.json file that is processed by a
separate nodejs program, npm package trapit. This can be installed via npm (npm and nodejs
required):

$ npm install trapit

The output json file contains arrays of expected and actual records by group and scenario, in the
format expected by the Javascript program. The Javascript program produces listings of the results
in html and/or text format, and a sample set of listings is included in the folder test.

See also the app schema main_col_group script which gives a simple example use-case for the
Timer_Set package.

***************************************************************************************************/

TYPE hash_int_arr IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(100);
PROCEDURE tt_Main IS

  PROC_NM             CONSTANT VARCHAR2(30) := 'tt_Main';
  TIMER_SET_NM        CONSTANT VARCHAR2(61) := $$PLSQL_UNIT || '.' || PROC_NM;
  SECS_DAY_FACTOR     CONSTANT NUMBER := 1/24/3600;
  CON                 CONSTANT VARCHAR2(30) := 'CON';
  INC                 CONSTANT VARCHAR2(30) := 'INC';
  INI                 CONSTANT VARCHAR2(30) := 'INI';
  GET                 CONSTANT VARCHAR2(30) := 'GET';
  GETF                CONSTANT VARCHAR2(30) := 'GETF';
  SELF                CONSTANT VARCHAR2(30) := 'SELF';
  SELFF               CONSTANT VARCHAR2(30) := 'SELFF';
  RES                 CONSTANT VARCHAR2(30) := 'RES';

  l_act_3lis                   L3_chr_arr := L3_chr_arr();
  l_sces_4lis                  L4_chr_arr;
  l_timer_set                  VARCHAR2(100);

  /***************************************************************************************************

  Purely_Wrap_API: Design pattern has the API call wrapped in a 'pure' procedure, called once per 
                   scenario, with the output 'actuals' array including everything affected by the API,
                   whether as output parameters, or on database tables, etc. The inputs are also
                   extended from the API parameters to include any other effective inputs. Assertion 
                   takes place after all scenarios and is against the extended outputs, with extended
                   inputs also listed. The API call is timed

  ***************************************************************************************************/
  FUNCTION Purely_Wrap_API(p_inp_3lis       L3_chr_arr)      -- input list of lists (record, field)
                           RETURN           L2_chr_arr IS    -- output list of lists (group, record)
    l_anchor_timestamp    TIMESTAMP := TIMESTAMP '2019-01-01 00:00:00.000';
    l_act_2lis            L2_chr_arr := L2_chr_arr();
    l_events_2lis         L2_chr_arr := p_inp_3lis(1);
    l_event_lis           L1_chr_arr;
    l_time_points         Timer_Set.time_point_rec;
    l_mock_time_lis       Timer_Set.time_point_arr;
    
    l_scalars_lis         L1_chr_arr := p_inp_3lis(2)(1);
    l_mock_yn             VARCHAR2(100) := l_scalars_lis(1);
    l_format_prms         Timer_Set.format_prm_rec;

    l_timer_set_lis       hash_int_arr;
    l_timer_stat_lis      Timer_Set.timer_stat_arr;
    l_timer_stats         Timer_Set.timer_stat_rec;
    l_set_nm_1            VARCHAR2(100);
    l_set_offset          PLS_INTEGER;
    l_prms_null           BOOLEAN := TRUE;
    l_val                 PLS_INTEGER;
    l_set_nm              VARCHAR2(100);
    l_timer_nm            VARCHAR2(100);
    l_event_cd            VARCHAR2(100);
    l_self_lis            L1_num_arr;

  BEGIN
    FOR i IN 2..5 LOOP
      l_val := l_scalars_lis(i);
      IF l_val IS NOT NULL THEN 
        l_prms_null := FALSE;
        CASE i
          WHEN 2 THEN l_format_prms.time_width := l_val;
          WHEN 3 THEN l_format_prms.time_dp := l_val;
          WHEN 4 THEN l_format_prms.time_ratio_dp := l_val;
          WHEN 5 THEN l_format_prms.calls_width := l_val;
        END CASE;
      END IF;
    END LOOP;

    IF l_mock_yn = 'Y' THEN
      l_mock_time_lis := Timer_Set.time_point_arr();
      l_mock_time_lis.EXTEND(l_events_2lis.COUNT);
      FOR i IN 1..l_events_2lis.COUNT LOOP
        l_time_points.ela := l_anchor_timestamp + NumToDSInterval(l_events_2lis(i)(4), 'second');
        l_time_points.cpu := To_Number(l_events_2lis(i)(5));
        l_mock_time_lis(i) := l_time_points;
      END LOOP;

    END IF;
    l_act_2lis.EXTEND(8);
    FOR i IN 1..l_events_2lis.COUNT LOOP

      l_event_lis := l_events_2lis(i);
      IF l_mock_yn = 'N' THEN
        Utils_TT.Sleep(To_Number(l_event_lis(4)), 0.5);
      END IF;

      l_set_nm := l_event_lis(1);
      l_timer_nm := l_event_lis(2);
      l_event_cd := l_event_lis(3);
--
-- Assumes maximum of 2 sets, second set groups indexed 2 more than first for TIMER_SET and 
--  TIMER_SET_F only
-- We have no Set 2 groups for RES, as deemed unnecessary
--
      l_set_offset := 0;
      IF l_set_nm IS NOT NULL THEN
        IF l_set_nm_1 IS NULL THEN
          l_set_nm_1 := l_set_nm;
        ELSIF l_set_nm_1 != l_set_nm THEN
          l_set_offset := 1;
        END IF;
      END IF;

      CASE l_event_cd
        WHEN CON THEN
          l_timer_set_lis(l_set_nm) := Timer_Set.Construct(l_set_nm, l_mock_time_lis);
        WHEN INC THEN
          Timer_Set.Increment_Time(l_timer_set_lis(l_set_nm), l_timer_nm);
        WHEN INI THEN
          Timer_Set.Init_Time(l_timer_set_lis(l_set_nm));
        WHEN GET THEN
          l_timer_stat_lis := Timer_Set.Get_Timers(l_timer_set_lis(l_set_nm));
          l_act_2lis(1 + 2 * l_set_offset) := L1_chr_arr();
          l_act_2lis(1 + 2 * l_set_offset).EXTEND(l_timer_stat_lis.COUNT);
          FOR j IN 1..l_timer_stat_lis.COUNT LOOP
            l_timer_stats := l_timer_stat_lis(j);
            l_act_2lis(1 + 2 * l_set_offset)(j) := Utils.List_Delim(
                                                    l_timer_stats.name,
                                                    l_timer_stats.ela_secs,
                                                    l_timer_stats.cpu_secs,
                                                    l_timer_stats.calls); 
          END LOOP;
        WHEN GETF THEN
          BEGIN
            l_act_2lis(2 + 2 * l_set_offset) := 
              CASE 
                WHEN l_prms_null THEN Timer_Set.Format_Timers(l_timer_set_lis(l_set_nm))
                                 ELSE Timer_Set.Format_Timers(l_timer_set_lis(l_set_nm), l_format_prms)
                END;
          EXCEPTION
            WHEN OTHERS THEN
              l_act_2lis(8) := L1_chr_arr();
              l_act_2lis(8).EXTEND(2);
              l_act_2lis(8)(1) := SQLERRM;
              l_act_2lis(8)(2) := DBMS_Utility.Format_Error_Backtrace;
          END;
        WHEN SELF THEN
          l_self_lis := Timer_Set.Get_Self_Timer;
          l_act_2lis(5) := L1_chr_arr();
          l_act_2lis(5).EXTEND;
          l_act_2lis(5)(1) := Utils.List_Delim(l_self_lis(1), l_self_lis(2));
        WHEN SELFF THEN
          l_act_2lis(6) := L1_chr_arr();
          l_act_2lis(6).EXTEND;
          l_act_2lis(6)(1) := 
              CASE 
                WHEN l_prms_null THEN Timer_Set.Format_Self_Timer
                                 ELSE Timer_Set.Format_Self_Timer(l_format_prms)
                END;
        WHEN RES THEN
          l_act_2lis(7) := L1_chr_arr();
          l_act_2lis(7).EXTEND;
          l_act_2lis(7) := 
              CASE 
                WHEN l_prms_null THEN Timer_Set.Format_Results(l_timer_set_lis(l_set_nm))
                                 ELSE Timer_Set.Format_Results(l_timer_set_lis(l_set_nm), l_format_prms)
                END;
        ELSE 
          Utils.Raise_Error('Error: ' || l_event_cd || ' event not found');
      END CASE;
    END LOOP;
    Timer_Set.Null_Mock;
    l_set_nm := l_timer_set_lis.FIRST;
    WHILE l_set_nm IS NOT NULL LOOP
      Timer_Set.Remove_Timer_Set(l_timer_set_lis(l_set_nm));
      l_set_nm := l_timer_set_lis.NEXT(l_set_nm);
    END LOOP;
    RETURN l_act_2lis;
  END Purely_Wrap_API;

BEGIN
--
-- Every testing main section should be similar to this, with array setup, then loop over scenarios
-- making a 'pure' call to specific, local Purely_Wrap_API, with single assertion call outside
-- the loop
--
  l_timer_set := Utils_TT.Init(TIMER_SET_NM);
  l_sces_4lis := Utils_TT.Get_Inputs(p_package_nm    => $$PLSQL_UNIT,
                                     p_procedure_nm  => PROC_NM,
                                     p_timer_set     => l_timer_set);

  l_act_3lis.EXTEND(l_sces_4lis.COUNT);

  FOR i IN 1..l_sces_4lis.COUNT LOOP

    l_act_3lis(i) := Purely_Wrap_API(l_sces_4lis(i));

  END LOOP;
  Utils_TT.Set_Outputs(p_package_nm    => $$PLSQL_UNIT,
                       p_procedure_nm  => PROC_NM,
                       p_act_3lis      => l_act_3lis,
                       p_timer_set     => l_timer_set);

END tt_Main;

END TT_Timer_Set;
/
SHO ERR