CREATE OR REPLACE PACKAGE BODY Utils AS
/***************************************************************************************************
Name: utils.pkb                        Author: Brendan Furey                       Date: 29-Jan-2019

Package body component in the Oracle timer_set_oracle module. This module facilitates code timing
for instrumentation and other purposes, with very small footprint in both code and resource usage.

GitHub: https://github.com/BrenPatF/timer_set_oracle

See 'Code Timing and Object Orientation and Zombies' for the original idea implemented in Oracle 
   PL/SQL, Perl and Java
   http://www.scribd.com/doc/43588788/Code-Timing-and-Object-Orientation-and-Zombies
   Brendan Furey, November 2010

As well as the entry point Timer_Set package there is a helper package, Utils, of utility functions
====================================================================================================
|  Package    |  Notes                                                                             |
|===================================================================================================
|  Timer_Set  |  Code timing package                                                               |
----------------------------------------------------------------------------------------------------
| *Utils*     |  General utility functions                                                         |
====================================================================================================

This file has the general utility functions package body.

***************************************************************************************************/
c_lines                 CONSTANT VARCHAR2(1000) := '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';
c_equals                CONSTANT VARCHAR2(1000) := '=======================================================================================================================================================================================================';
c_fld_delim             CONSTANT VARCHAR2(30) := '  ';

/***************************************************************************************************

Get_Seconds: Simple function to get the seconds as a number from an interval

***************************************************************************************************/
FUNCTION Get_Seconds(p_interval INTERVAL DAY TO SECOND) -- time intervale
                        RETURN NUMBER IS                 -- time in seconds
BEGIN

  RETURN EXTRACT(SECOND FROM p_interval) + 60 * EXTRACT (MINUTE FROM p_interval) + 3600 * EXTRACT (HOUR FROM p_interval);

END Get_Seconds;

/***************************************************************************************************

Heading: Return a 2-element list of strings as a heading with double underlining

***************************************************************************************************/
FUNCTION Heading(p_head       VARCHAR2) -- heading string
                 RETURN       L1_chr_arr IS

  l_under       VARCHAR2(500) := Substr (c_equals, 1, Length(p_head));
  l_ret_lis     L1_chr_arr := L1_chr_arr();

BEGIN

  l_ret_lis.EXTEND(2);
--  l_ret_lis(1) := '.';
  l_ret_lis(1) := p_head;
  l_ret_lis(2) := l_under;
  RETURN l_ret_lis;

END Heading;

/***************************************************************************************************

List_To_Line: Return a list of strings as one line, saving for reprinting later if desired,
                 separating fields by a 2-space delimiter; second list is numbers for lengths, with
                 -ve/+ve sign denoting right/left-justify

***************************************************************************************************/
FUNCTION List_To_Line(p_val_lis   L1_chr_arr, -- values list
                      p_len_lis   L1_num_arr) -- lengths list, with minus sigm meaning right-justify
                      RETURN      VARCHAR2 IS -- line
  l_line        VARCHAR2(32767);
  l_fld         VARCHAR2(32767);
  l_val         VARCHAR2(32767);
BEGIN

  FOR i IN 1..p_val_lis.COUNT LOOP
    l_val := Nvl(p_val_lis(i), ' ');
    IF p_len_lis(i) < 0 THEN
      l_fld := LPad(l_val, -p_len_lis(i));
    ELSE
      l_fld := RPad(l_val, p_len_lis(i));
    END IF;
    IF i = 1 THEN
      l_line := l_fld;
    ELSE
      l_line := l_line || c_fld_delim || l_fld;
    END IF;

  END LOOP;
  RETURN l_line;

END List_To_Line;

/***************************************************************************************************

Col_Headers: Return a set of column headers, input as lists of values and length/justification's

***************************************************************************************************/
FUNCTION Col_Headers(p_val_lis    L1_chr_arr, -- values list
                     p_len_lis    L1_num_arr) -- lengths list, with minus sigm meaning right-justify
                     RETURN       L1_chr_arr IS
  l_line_lis    L1_chr_arr := L1_chr_arr();
  l_ret_lis     L1_chr_arr := L1_chr_arr();
BEGIN
  l_ret_lis.EXTEND(2);
  l_ret_lis(1) := List_To_Line(p_val_lis, p_len_lis);

  l_line_lis.EXTEND (p_val_lis.COUNT);
  FOR i IN 1..p_val_lis.COUNT LOOP

    l_line_lis(i) := c_lines;

  END LOOP;
  l_ret_lis(2) := List_To_Line(l_line_lis, p_len_lis);
  RETURN l_ret_lis;

END Col_Headers;

/***************************************************************************************************

Raise_Error: Centralise RAISE_APPLICATION_ERROR, using just one error number

***************************************************************************************************/
PROCEDURE Raise_Error(p_message VARCHAR2) IS
BEGIN

  RAISE_APPLICATION_ERROR(-20000, p_message);

END Raise_Error;

/***************************************************************************************************

Write_Other_Error: Write the SQL error and backtrace to log, called from WHEN OTHERS

***************************************************************************************************/
PROCEDURE Write_Other_Error (p_package          VARCHAR2 DEFAULT NULL,    -- package name
                             p_proc             VARCHAR2 DEFAULT NULL,    -- procedure name
                             p_group_text       VARCHAR2 DEFAULT NULL) IS -- group text
BEGIN

  Write_Log('Others error in ' || p_package || '(' || p_proc || '): ' || SQLERRM || ': ' || 
    DBMS_Utility.Format_Error_Backtrace);

END Write_Other_Error;
/***************************************************************************************************

List_Delim: Return a delimited string for an input set of from 1 to 15 strings

***************************************************************************************************/
FUNCTION List_Delim(
        p_field1 VARCHAR2,        -- input string, first is required, others passed as needed
        p_field2 VARCHAR2 DEFAULT c_list_end_marker, p_field3 VARCHAR2 DEFAULT c_list_end_marker,
        p_field4 VARCHAR2 DEFAULT c_list_end_marker, p_field5 VARCHAR2 DEFAULT c_list_end_marker,
        p_field6 VARCHAR2 DEFAULT c_list_end_marker, p_field7 VARCHAR2 DEFAULT c_list_end_marker,
        p_field8 VARCHAR2 DEFAULT c_list_end_marker, p_field9 VARCHAR2 DEFAULT c_list_end_marker,
        p_field10 VARCHAR2 DEFAULT c_list_end_marker, p_field11 VARCHAR2 DEFAULT c_list_end_marker,
        p_field12 VARCHAR2 DEFAULT c_list_end_marker, p_field13 VARCHAR2 DEFAULT c_list_end_marker,
        p_field14 VARCHAR2 DEFAULT c_list_end_marker, p_field15 VARCHAR2 DEFAULT c_list_end_marker)
        RETURN VARCHAR2 IS        -- delimited string

  l_list   L1_chr_arr := L1_chr_arr (p_field2, p_field3, p_field4, p_field5, p_field6, p_field7,
              p_field8, p_field9, p_field10, p_field11, p_field12, p_field13, p_field14, p_field15);
  l_str    VARCHAR2(4000) := p_field1;

BEGIN

  FOR i IN 1..l_list.COUNT LOOP

    IF l_list(i) = c_list_end_marker THEN
      EXIT;
    END IF;
    l_str := l_str || g_list_delimiter || l_list(i);

  END LOOP;
  RETURN l_str;

END List_Delim;

/***************************************************************************************************

List_Delim: Return a delimited string for an input list of strings

***************************************************************************************************/
FUNCTION List_Delim (p_field_lis        L1_chr_arr,                        -- list of strings
                     p_delim            VARCHAR2 DEFAULT g_list_delimiter) -- delimiter
                     RETURN VARCHAR2 IS                                    -- delimited string

  l_str         VARCHAR2(32767) := p_field_lis(1);

BEGIN

  FOR i IN 2..p_field_lis.COUNT LOOP

    l_str := l_str || p_delim || p_field_lis(i);

  END LOOP;
  RETURN l_str;

END List_Delim;
/***************************************************************************************************

Csv_To_Lis: Returns a list of tokens from a delimited string

***************************************************************************************************/
FUNCTION Csv_To_Lis(p_csv VARCHAR2)         -- delimited string
                    RETURN    L1_chr_arr IS -- list of tokens
  l_start_pos   PLS_INTEGER := 1;
  l_end_pos     PLS_INTEGER;
  l_arr_index   PLS_INTEGER := 1;
  l_arr         L1_chr_arr := L1_chr_arr();
  l_row         VARCHAR2(32767) := p_csv || g_list_delimiter;
BEGIN

  WHILE l_start_pos <= Length (l_row) LOOP

    l_end_pos := Instr (l_row, g_list_delimiter, 1, l_arr_index) - 1;
    IF l_end_pos < 0 THEN
      l_end_pos := Length (l_row);
    END IF;
    l_arr.EXTEND;
    l_arr (l_arr.COUNT) := Substr (l_row, l_start_pos, l_end_pos - l_start_pos + 1);
    l_start_pos := l_end_pos + 2;
    l_arr_index := l_arr_index + 1;
  END LOOP;

  RETURN l_arr;

END Csv_To_Lis;

/***************************************************************************************************

Write_Log: Overloaded procedure to write a line, or an array of lines, to output using DBMS_Output;
  to use a logging framework, replace the Put_Line calls with your custom logging calls

***************************************************************************************************/
PROCEDURE Write_Log(p_line VARCHAR2) IS -- line of text to write
BEGIN
  DBMS_Output.Put_line(p_line);
END Write_Log;

PROCEDURE Write_Log(p_line_lis L1_chr_arr) IS -- array of lines of text to write
BEGIN
  FOR i IN 1..p_line_lis.COUNT LOOP
    DBMS_Output.Put_line(p_line_lis(i));
  END LOOP;
END Write_Log;

END Utils;
/
SHOW ERROR
