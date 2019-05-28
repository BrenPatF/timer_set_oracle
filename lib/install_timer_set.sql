@..\initspool install_timer_set
/***************************************************************************************************
Name: install_timer_set.sql            Author: Brendan Furey                       Date: 29-Jan-2019

Installation script for the timer_set_oracle module, excluding the unit test components that require
a minimum Oracle database version of 12.2. 

This module facilitates code timing for instrumentation and other purposes, with very small 
footprint in both code and resource usage.

    GitHub: https://github.com/BrenPatF/timer_set_oracle

Pre-requisite: Installation of the oracle_plsql_utils module:

    GitHub: https://github.com/BrenPatF/oracle_plsql_utils

There are two install scripts, of which the second is optional: 
- install_timer_set.sql:    base code; requires base install of oracle_plsql_utils
- install_timer_set_tt.sql: unit test code; requires unit test install section of oracle_plsql_utils

The lib schema refers to the schema in which oracle_plsql_utils was installed.
====================================================================================================
|  Script                    |  Notes                                                              |
|===================================================================================================
| *install_timer_set.sql*    |  Creates base components, including Timer_Set package, in lib       |
|                            |  schema                                                             |
----------------------------------------------------------------------------------------------------
|  install_timer_set_tt.sql  |  Creates unit test components that require a minimum Oracle         |
|                            |  database version of 12.2 in lib schema                             |
====================================================================================================

This file has the install script for the lib schema, excluding the unit test components that require
a minimum Oracle database version of 12.2. This script should work in prior versions of Oracle,
including v10 and v11 (although it has not been tested on them).

Components created, with public synonyms and grants to public:

    Packages      Description
    ==========    ==================================================================================
    Timer_Set     Code timing package

***************************************************************************************************/

PROMPT Create package Timer_Set
@timer_set.pks
@timer_set.pkb
GRANT EXECUTE ON Timer_Set TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM Timer_Set FOR Timer_Set
/
@..\endspool