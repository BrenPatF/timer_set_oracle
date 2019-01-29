CREATE OR REPLACE PACKAGE Utils AUTHID CURRENT_USER AS
/***************************************************************************************************
Name: utils.pks                        Author: Brendan Furey                       Date: 29-Jan-2019

Package spec component in the Oracle timer_set_oracle module. This module facilitates code timing
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

This file has the general utility functions package spec.

***************************************************************************************************/

c_list_end_marker       CONSTANT VARCHAR2(30) := 'LIST_END_MARKER';
c_session_id_if_TT               VARCHAR2(30);
g_list_delimiter                 VARCHAR2(30) := '|';

FUNCTION Get_Seconds(p_interval INTERVAL DAY TO SECOND) RETURN NUMBER;
FUNCTION List_To_Line (p_val_lis    L1_chr_arr, -- token list
                       p_len_lis    L1_num_arr) -- length list
                       RETURN       VARCHAR2;
FUNCTION Col_Headers(p_val_lis L1_chr_arr, p_len_lis L1_num_arr) RETURN L1_chr_arr;
FUNCTION Heading(p_head VARCHAR2) RETURN L1_chr_arr;
PROCEDURE Raise_Error(p_message VARCHAR2);
PROCEDURE Write_Other_Error(p_package     VARCHAR2 := NULL,
                            p_proc        VARCHAR2 := NULL, 
                            p_group_text  VARCHAR2 := NULL);
PROCEDURE Write_Log(p_line VARCHAR2);
PROCEDURE Write_Log(p_line_lis L1_chr_arr);
FUNCTION List_Delim (p_field_lis  L1_chr_arr, 
                     p_delim      VARCHAR2 := g_list_delimiter) 
                     RETURN       VARCHAR2;
FUNCTION List_Delim(p_field1  VARCHAR2,
                    p_field2  VARCHAR2 := c_list_end_marker, p_field3  VARCHAR2 := c_list_end_marker,
                    p_field4  VARCHAR2 := c_list_end_marker, p_field5  VARCHAR2 := c_list_end_marker,
                    p_field6  VARCHAR2 := c_list_end_marker, p_field7  VARCHAR2 := c_list_end_marker,
                    p_field8  VARCHAR2 := c_list_end_marker, p_field9  VARCHAR2 := c_list_end_marker,
                    p_field10 VARCHAR2 := c_list_end_marker, p_field11 VARCHAR2 := c_list_end_marker,
                    p_field12 VARCHAR2 := c_list_end_marker, p_field13 VARCHAR2 := c_list_end_marker,
                    p_field14 VARCHAR2 := c_list_end_marker, p_field15 VARCHAR2 := c_list_end_marker)
                    RETURN    VARCHAR2;
FUNCTION Csv_To_Lis(p_csv VARCHAR2) RETURN L1_chr_arr;

END Utils;
/
SHOW ERROR