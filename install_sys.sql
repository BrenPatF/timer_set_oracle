@InitSpool install_sys
/***************************************************************************************************
Name: install_lib.sql                  Author: Brendan Furey                       Date: 29-Jan-2019

Installation script run from sys schema in the Oracle timer_set_oracle module. Creates lib and app
schemas, a directory input_dir, and does some grants.

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
| *install_sys.sql*    |  sys script creates lib and app schemas; input_dir directory; grants      |
----------------------------------------------------------------------------------------------------
|  install_lib.sql     |  Creates common objects, including Timer_Set package, in lib schema       |
----------------------------------------------------------------------------------------------------
|  install_lib_tt.sql  |  Creates unit test objects that require a minimum Oracle database version |
|                      |  of 12.2 in lib schema                                                    |
----------------------------------------------------------------------------------------------------
|  install_app.sql     |  Creates objects for the Col_Group example in the app schema              |
====================================================================================================

This file has the install script run from the sys schema.

Objects created:

    Users             Description
    ================  ==============================================================================
    lib    		      Schema where the base and unit test code is installed
    app               Schema where the example calling code is installed

    Directory
    ================
    input_dir         Points to OS folder where example csv file and unit test JSON files are placed

    Grants to Public
    ================
    input_dir         The directory created
    UTL_File          Sys package used by example code
    DBMS_Lock         Sys package used by unit test code

***************************************************************************************************/
DEFINE LIB_USER=lib
DEFINE APP_USER=app

@C_User &LIB_USER
@C_User &APP_USER

PROMPT Directory input_dir
CREATE OR REPLACE DIRECTORY input_dir AS 'C:\input'
/
GRANT ALL ON DIRECTORY input_dir TO PUBLIC
/
GRANT EXECUTE ON UTL_File TO PUBLIC
/
GRANT EXECUTE ON DBMS_Lock TO PUBLIC
/
@EndSpool