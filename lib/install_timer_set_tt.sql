@..\initspool install_timer_set_tt
/***************************************************************************************************
Name: install_timer_set_tt.sql         Author: Brendan Furey                       Date: 29-Jan-2019

Installation script for the unit test components in the timer_set_oracle module. It requires a
minimum Oracle database version of 12.2.

This module facilitates code timing for instrumentation and other purposes, with very small 
footprint in both code and resource usage.

	  GitHub: https://github.com/BrenPatF/timer_set_oracle

Pre-requisite: Installation of the oracle_plsql_utils module:

    GitHub: https://github.com/BrenPatF/oracle_plsql_utils

There are two install scripts, of which the second is optional: 
- install_timer_set.sql:    base code; requires base install of oracle_plsql_utils
- install_timer_set_tt.sql: unit test code; requires unit test install section of oracle_plsql_utils

The lib schema refers to the schema in which oracle_plsql_utils was installed
====================================================================================================
|  Script                      |  Notes                                                            |
|==================================================================================================|
|  install_timer_set.sql       |  Creates base components, including Timer_Set package, in lib     |
|                              |  schema                                                           |
|------------------------------|-------------------------------------------------------------------|
| *install_timer_set_tt.sql*   |  Creates unit test components that require a minimum Oracle       |
|                              |  database version of 12.2 in lib schema                           |
|------------------------------|-------------------------------------------------------------------|
|  grant_timer_set_to_app.sql  |  Grants privileges on Timer_Set components from lib to app schema |
|------------------------------|-------------------------------------------------------------------|
|  c_timer_set_syns.sql        |  Creates synonyms for Timer_Set components in app schema to lib   |
|                              |  schema                                                           |
====================================================================================================

This file has the install script for the unit test components in the lib schema. It requires a
minimum Oracle database version of 12.2, owing to the use of v12.2 PL/SQL JSON features.

Components created, with NO synonyms or grants - only accessible within lib schema:

    Packages      Description
    ============  ==================================================================================
    TT_Timer_Set  Unit test package for Timer_Set

    Metadata      Description
    ============  ==================================================================================
    tt_units      Record for package, procedure ('TT_TIMER_SET', 'Test_API'). The input JSON file
                  must first be placed in the OS folder pointed to by INPUT_DIR directory

***************************************************************************************************/
PROMPT Create package TT_Timer_Set
@tt_timer_set.pks
@tt_timer_set.pkb

PROMPT Add the tt_units record, reading in JSON file from INPUT_DIR
DEFINE LIB=lib
BEGIN

  Trapit.Add_Ttu ('TT_TIMER_SET', 'Purely_Wrap_Timer_Set', '&LIB', 'Y', 'tt_timer_set.purely_wrap_timer_set_inp.json');

END;
/
@..\endspool
exit