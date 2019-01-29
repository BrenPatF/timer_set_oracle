@..\InitSpool install_app
/***************************************************************************************************
Name: install_app.sql                  Author: Brendan Furey                       Date: 29-Jan-2019

Installation script for app schema in the Oracle timer_set_oracle module. 

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
|  install_lib.sql     |  Creates common objects, including Timer_Set package, in lib schema       |
----------------------------------------------------------------------------------------------------
|  install_lib_tt.sql  |  Creates unit test objects that require a minimum Oracle database version |
|                      |  of 12.2 in lib schema                                                    |
----------------------------------------------------------------------------------------------------
| *install_app.sql*    |  Creates objects for the Col_Group example in app schema                  |
====================================================================================================

This file has the install script for the app schema.

Objects created, with NO synonyms or grants - only accessible within app schema:

    Types          Description
    ============== =================================================================================
    chr_int_rec    Simple (string, integer) tuple type
    chr_int_arr    Array of chr_int_rec

    External Table
    ==============
    lines_et       Used to read in csv records from lines.csv placed in INPUT_DIR folder

    Packages
    ==============
    Col_Group      Package called by main_col_group as a simple example of how to use the code 
                   timing package

***************************************************************************************************/

PROMPT External table creation
PROMPT =======================
PROMPT Create lines_et
CREATE TABLE lines_et (
        line            VARCHAR2(400)
)
ORGANIZATION EXTERNAL ( 
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY input_dir
    ACCESS PARAMETERS (
            RECORDS DELIMITED BY NEWLINE
            FIELDS (
                line POSITION (1:4000) CHAR(4000)
            )
    )
    LOCATION ('lines.csv')
)
    REJECT LIMIT UNLIMITED
/
PROMPT Types creation
PROMPT ==============
CREATE OR REPLACE TYPE chr_int_rec AS 
    OBJECT (chr_field           VARCHAR2(4000), 
            int_field           INTEGER)
/
CREATE OR REPLACE TYPE chr_int_arr AS TABLE OF chr_int_rec
/
PROMPT Packages creation
PROMPT =================

PROMPT Create package Col_Group
@Col_Group.pks
@Col_Group.pkb
@..\EndSpool