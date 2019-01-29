@..\InitSpool install_lib
/***************************************************************************************************
Name: install_lib.sql                  Author: Brendan Furey                       Date: 29-Jan-2019

Installation script for lib schema in the Oracle timer_set_oracle module, excluding the unit test 
objects that require a minimum Oracle database version of 12.2. 

This module facilitates code timing for instrumentation and other purposes, with very small 
footprint in both code and resource usage.

GitHub: https://github.com/BrenPatF/timer_set_oracle

See 'Code Timing and Object Orientation and Zombies' for the original idea implemented in Oracle 
   PL/SQL, Perl and Java
   http://www.scribd.com/doc/43588788/Code-Timing-and-Object-Orientation-and-Zombies
   Brendan Furey, November 2010

There are install scripts for sys, lib and app schemas. However the base code alone can be installed
via install_lib.sql in an existing schema without executing the other scripts.
====================================================================================================
|  Script              |  Notes                                                                    |
|===================================================================================================
|  install_sys.sql     |  sys script creates lib and app schemas; input_dir directory; grants      |
----------------------------------------------------------------------------------------------------
| *install_lib.sql*    |  Creates common objects, including Timer_Set package, in lib schema       |
----------------------------------------------------------------------------------------------------
|  install_lib_tt.sql  |  Creates unit test objects that require a minimum Oracle database version |
|                      |  of 12.2 in lib schema                                                    |
----------------------------------------------------------------------------------------------------
|  install_app.sql     |  Creates objects for the Col_Group example in the app schema              |
====================================================================================================

This file has the install script for the lib schema, excluding the unit test objects that require a
minimum Oracle database version of 12.2. This script should work in prior versions of Oracle,
including v10 and v11 (although it has not been tested on them).

Objects created, with public synonyms and grants to public:

    Types         Description
    ==========    ==================================================================================
    L1_chr_arr    Generic array of strings
    L1_num_arr    Generic array of NUMBER

    Packages
    ==========
    Utils         General utility functions
    Timer_Set     Code timing package

***************************************************************************************************/

PROMPT Common type creation
PROMPT ====================

PROMPT Create type L1_chr_arr
CREATE OR REPLACE TYPE L1_chr_arr IS VARRAY(32767) OF VARCHAR2(32767)
/
CREATE OR REPLACE PUBLIC SYNONYM L1_chr_arr FOR L1_chr_arr
/
GRANT EXECUTE ON L1_chr_arr TO PUBLIC
/
PROMPT Create type L1_num_arr
CREATE OR REPLACE TYPE L1_num_arr IS VARRAY(32767) OF NUMBER
/
CREATE OR REPLACE PUBLIC SYNONYM L1_num_arr FOR L1_num_arr
/
GRANT EXECUTE ON L1_num_arr TO PUBLIC
/
PROMPT Packages creation
PROMPT =================

PROMPT Create package Utils
@utils.pks
@utils.pkb
GRANT EXECUTE ON Utils TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM Utils FOR Utils
/
PROMPT Create package Timer_Set
@timer_set.pks
@timer_set.pkb
GRANT EXECUTE ON Timer_Set TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM Timer_Set FOR Timer_Set
/
@..\EndSpool