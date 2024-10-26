<#**************************************************************************************************
Name: Install-Timer_Set.ps1             Author: Brendan Furey                      Date: 13-Oct-2024

Install script for Oracle PL/SQL Timer_Set module

    GitHub: https://github.com/BrenPatF/timer_set_oracle

====================================================================================================
| Script (.ps1)           | Module (.psm1) | Notes                                                 |
|==================================================================================================|
| *Install-Timer_Set*     | OracleUtils    | Install script for Oracle PL/SQL Timer_Set module     |
|-------------------------|------------------------------------------------------------------------|
|  Test-Format-Timer_Set  | TrapitUtils    | Script to test and format results for Oracle PL/SQL   |
|                         |                | Timer_Set module                                      |
|-------------------------|----------------|-------------------------------------------------------|
|  Format-JSON-Timer_Set  | TrapitUtils    | Script to create template for unit test JSON input    |
|                         |                | file for Oracle PL/SQ Timer_Set module                |
====================================================================================================

**************************************************************************************************#>
Import-Module .\powershell_utils\OracleUtils\OracleUtils
$inputPath = 'c:/input'
$fileLis = @('./unit_test/tt_timer_set.purely_wrap_timer_set_inp.json',
             './fantasy_premier_league_player_stats.csv')

$sysSchema = 'sys'
$libSchema = 'lib'
$appSchema = 'app'

$installs = @(#@{folder = 'install_prereq';     script = 'drop_utils_users';     schema = $sysSchema; prmLis = @($libSchema, $appSchema)},
              @{folder = 'install_prereq';     script = 'install_sys';          schema = $sysSchema; prmLis = @($libSchema, $appSchema, $inputPath)},
              @{folder = 'install_prereq\lib'; script = 'install_lib_all';      schema = $libSchema; prmLis = @($appSchema)},
              @{folder = 'install_prereq\app'; script = 'install_app_all';      schema = $appSchema; prmLis = @($libSchema)},
              @{folder = 'lib';                script = 'install_timer_set';    schema = $libSchema; prmLis = @($appSchema)},
              @{folder = 'app';                script = 'c_timer_set_syns';     schema = $appSchema; prmLis = @($libSchema)},
              @{folder = 'lib';                script = 'install_timer_set_tt'; schema = $libSchema; prmLis = @()},
              @{folder = '.';                  script = 'l_objects';            schema = $sysSchema; prmLis = @($sysSchema)},
              @{folder = '.';                  script = 'l_objects';            schema = $libSchema; prmLis = @($libSchema)},
              @{folder = '.';                  script = 'l_objects';            schema = $appSchema; prmLis = @($appSchema)})
Install-OracleApp $inputPath $fileLis $installs