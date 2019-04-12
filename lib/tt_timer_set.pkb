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

TYPE hash_int_arr IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(100);

/***************************************************************************************************

Do_Get: Handle GET event, returning 

***************************************************************************************************/
FUNCTION Do_Get(
           p_set_id                      PLS_INTEGER)              -- timer set id
           RETURN                        L1_chr_arr IS             -- actuals list
  l_act_lis                    L1_chr_arr := L1_chr_arr();
  l_timer_stat_lis             Timer_Set.timer_stat_arr := Timer_Set.Get_Timers(p_set_id);
  l_timer_stats                Timer_Set.timer_stat_rec;
BEGIN

  l_act_lis.EXTEND(l_timer_stat_lis.COUNT);
  FOR j IN 1..l_timer_stat_lis.COUNT LOOP
    l_timer_stats := l_timer_stat_lis(j);
    l_act_lis(j) := Utils.List_Delim(l_timer_stats.name,
                                     l_timer_stats.ela_secs,
                                     l_timer_stats.cpu_secs,
                                     l_timer_stats.calls); 
  END LOOP;
  RETURN l_act_lis;

END Do_Get;

/***************************************************************************************************

Do_GetF: Handle GETF event, returning 

***************************************************************************************************/
FUNCTION Do_GetF(
           p_set_id                      PLS_INTEGER,              -- timer set id
           p_prms_null                   BOOLEAN,                  -- TRUE if parameters all null 
           p_format_prms                 Timer_Set.format_prm_rec) -- formatting parameters
           RETURN                        L1_chr_arr IS             -- actuals list
BEGIN
            
  RETURN 
    CASE 
      WHEN p_prms_null THEN Timer_Set.Format_Timers(p_set_id)
                       ELSE Timer_Set.Format_Timers(p_set_id, p_format_prms)
      END;

END Do_GetF;

/***************************************************************************************************

Do_SelfF: Handle SELFF event, returning 

***************************************************************************************************/
FUNCTION Do_SelfF(
           p_prms_null                   BOOLEAN,                  -- TRUE if parameters all null 
           p_format_prms                 Timer_Set.format_prm_rec) -- formatting parameters
           RETURN                        L1_chr_arr IS             -- actuals list
BEGIN
            
  RETURN L1_chr_arr(
    CASE 
      WHEN p_prms_null THEN Timer_Set.Format_Self_Timer
                       ELSE Timer_Set.Format_Self_Timer(p_format_prms)
      END
    );

END Do_SelfF;

/***************************************************************************************************

Do_Res: Handle RES event, returning 1-lis of results

***************************************************************************************************/
FUNCTION Do_Res(
           p_set_id                      PLS_INTEGER,              -- timer set id
           p_prms_null                   BOOLEAN,                  -- TRUE if parameters all null
           p_format_prms                 Timer_Set.format_prm_rec)
           RETURN                        L1_chr_arr IS
BEGIN
            
  RETURN 
    CASE 
      WHEN p_prms_null THEN Timer_Set.Format_Results(p_set_id)
                       ELSE Timer_Set.Format_Results(p_set_id, p_format_prms)
      END;

END Do_Res;

/***************************************************************************************************

Cleanup_Timer_Set: Remove timer sets created and null the mock data

***************************************************************************************************/
PROCEDURE Cleanup_Timer_Set(
           p_timer_set_lis               hash_int_arr) IS -- list of timer sets created
  l_set_nm                       VARCHAR2(100);
BEGIN

  Timer_Set.Null_Mock;
  l_set_nm := p_timer_set_lis.FIRST;
  WHILE l_set_nm IS NOT NULL LOOP
    Timer_Set.Remove_Timer_Set(p_timer_set_lis(l_set_nm));
    l_set_nm := p_timer_set_lis.NEXT(l_set_nm);
  END LOOP;

END Cleanup_Timer_Set;

/***************************************************************************************************

Get_Act_Lis: Return the list of actuals for a single actual-returning event

***************************************************************************************************/
FUNCTION Get_Act_Lis(
           p_event_cd                    VARCHAR2,                 -- event code
           p_set_id                      PLS_INTEGER,              -- timer set id
           p_prms_null                   BOOLEAN,                  -- TRUE if parameters all null
           p_format_prms                 Timer_Set.format_prm_rec) -- formatting parameters
           RETURN                        L1_chr_arr IS             -- actuals list

  l_set_nm                       VARCHAR2(100);
  l_self_lis                     L1_num_arr;
BEGIN

  CASE p_event_cd
    WHEN GET THEN
      RETURN Do_Get(p_set_id => p_set_id);

    WHEN GETF THEN
        RETURN Do_GetF(p_set_id      => p_set_id,
                       p_prms_null   => p_prms_null,
                       p_format_prms => p_format_prms);

    WHEN SELF THEN
      l_self_lis := Timer_Set.Get_Self_Timer;
      RETURN L1_chr_arr(Utils.List_Delim(l_self_lis(1), l_self_lis(2)));

    WHEN SELFF THEN
      RETURN Do_SelfF(p_prms_null   => p_prms_null,
                      p_format_prms => p_format_prms);

    WHEN RES THEN
      RETURN Do_Res(p_set_id      => p_set_id,
                    p_prms_null   => p_prms_null,
                    p_format_prms => p_format_prms);
  END CASE;

END Get_Act_Lis;

/***************************************************************************************************

Do_Event_List: Process the list of events, returning the actuals 2-list

***************************************************************************************************/
FUNCTION Do_Event_List(
           p_events_2lis                 L2_chr_arr,               -- events list of lists
           p_dont_mock                   BOOLEAN,                  -- TRUE if not mocking
           p_mock_time_lis               Timer_Set.time_point_arr, -- list of mock time points
           p_prms_null                   BOOLEAN,                  -- TRUE if parameters all null 
           p_format_prms                 Timer_Set.format_prm_rec) -- formatting parameters
           RETURN                        L2_chr_arr IS             -- output list of lists (group, record)

  CUSTOM_ERR_EX                  EXCEPTION;
  PRAGMA EXCEPTION_INIT(CUSTOM_ERR_EX, -20000);
  l_act_2lis                     L2_chr_arr := L2_chr_arr();
  l_event_lis                    L1_chr_arr;
  l_set_nm                       VARCHAR2(100);
  l_timer_nm                     VARCHAR2(100);
  l_event_cd                     VARCHAR2(100);
  l_set_nm_1                     VARCHAR2(100);
  l_set_offset                   PLS_INTEGER;
  l_set_id                       PLS_INTEGER;
  l_timer_set_lis                hash_int_arr;
BEGIN

  l_act_2lis.EXTEND(8);

  FOR i IN 1..p_events_2lis.COUNT LOOP

    l_event_lis := p_events_2lis(i);
    IF p_dont_mock THEN
      Utils_TT.Sleep(To_Number(l_event_lis(4)), 0.5);
    END IF;

    l_set_nm := l_event_lis(1);
    l_timer_nm := l_event_lis(2);
    l_event_cd := l_event_lis(3);
--
-- Assumes maximum of 2 sets, second set groups indexed 2 more than first for GET and  GETF only
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

    IF l_set_nm IS NOT NULL AND  l_timer_set_lis.EXISTS(l_set_nm) THEN
      l_set_id := l_timer_set_lis(l_set_nm);
    END IF;

    IF l_event_cd = CON THEN

        l_timer_set_lis(l_set_nm) := Timer_Set.Construct(l_set_nm, p_mock_time_lis);

    ELSIF l_event_cd = INC THEN

        Timer_Set.Increment_Time(l_set_id, l_timer_nm);

    ELSIF l_event_cd = INI THEN

        Timer_Set.Init_Time(l_set_id);

    ELSIF l_event_cd IN (GET, GETF, SELF, SELFF, RES) THEN

      BEGIN
        l_act_2lis(CASE l_event_cd 
                     WHEN GET   THEN 1 + 2 * l_set_offset
                     WHEN GETF  THEN 2 + 2 * l_set_offset
                     WHEN SELF  THEN 5
                     WHEN SELFF THEN 6
                     WHEN RES   THEN 7
                   END) := Get_Act_Lis(
                              p_event_cd    => l_event_cd,
                              p_set_id      => l_set_id,
                              p_prms_null   => p_prms_null,
                              p_format_prms => p_format_prms);

      EXCEPTION
        WHEN CUSTOM_ERR_EX THEN
          l_act_2lis(8) := L1_chr_arr(SQLERRM, DBMS_Utility.Format_Error_Backtrace);
      END;

    ELSE 
      Utils.Raise_Error('Error: ' || l_event_cd || ' event not found');
    END IF;

  END LOOP;

  Cleanup_Timer_Set(p_timer_set_lis => l_timer_set_lis);

  RETURN l_act_2lis;

END Do_Event_List;

/***************************************************************************************************

Purely_Wrap_API: Design pattern has the API call wrapped in a 'pure' procedure, called once per 
                 scenario, with the output 'actuals' array including everything affected by the API,
                 whether as output parameters, or on database tables, etc. The inputs are also
                 extended from the API parameters to include any other effective inputs. Assertion 
                 takes place after all scenarios and is against the extended outputs, with extended
                 inputs also listed. The API call is timed

***************************************************************************************************/
FUNCTION Purely_Wrap_API(
           p_inp_3lis                    L3_chr_arr)   -- input list of lists (record, field)
           RETURN                        L2_chr_arr IS -- output list of lists (group, record)
  l_anchor_timestamp    TIMESTAMP := TIMESTAMP '2019-01-01 00:00:00.000';
  l_act_2lis            L2_chr_arr := L2_chr_arr();
  l_events_2lis         L2_chr_arr := p_inp_3lis(1);
  l_event_lis           L1_chr_arr;
  l_time_points         Timer_Set.time_point_rec;
  l_mock_time_lis       Timer_Set.time_point_arr;
  
  l_scalars_lis         L1_chr_arr := p_inp_3lis(2)(1);
  l_mock_yn             VARCHAR2(100) := l_scalars_lis(1);
  l_format_prms         Timer_Set.format_prm_rec;

  l_prms_null           BOOLEAN := TRUE;
  l_val                 PLS_INTEGER;

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
  l_act_2lis :=  Do_Event_List(
                      p_events_2lis   => l_events_2lis,
                      p_dont_mock      => l_mock_yn = 'N',
                      p_mock_time_lis  => l_mock_time_lis,
                      p_prms_null     => l_prms_null,
                      p_format_prms    => l_format_prms);

  RETURN l_act_2lis;

END Purely_Wrap_API;

PROCEDURE tt_Main IS

  l_act_3lis                   L3_chr_arr := L3_chr_arr();
  l_sces_4lis                  L4_chr_arr;
  l_timer_set                  VARCHAR2(100);

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