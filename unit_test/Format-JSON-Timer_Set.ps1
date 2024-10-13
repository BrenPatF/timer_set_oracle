<#**************************************************************************************************
Name: Format-JSON-Timer_Set.ps1         Author: Brendan Furey                      Date: 13-Oct-2024

Script to test and format results for Oracle PL/SQL Timer_Set module

    GitHub: https://github.com/BrenPatF/timer_set_oracle

Unit testing follows the Math Function Unit Testing design pattern, as described in:

    The Math Function Unit Testing Design Pattern
    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

====================================================================================================
| Script (.ps1)           | Module (.psm1) | Notes                                                 |
|==================================================================================================|
|  Install-Timer_Set      | OracleUtils    | Install script for Oracle PL/SQL Timer_Set module     |
|-------------------------|------------------------------------------------------------------------|
|  Test-Format-Timer_Set  | TrapitUtils    | Script to test and format results for Oracle PL/SQL   |
|                         |                | Timer_Set module                                      |
|-------------------------|----------------|-------------------------------------------------------|
| *Format-JSON-Timer_Set* | TrapitUtils    | Script to create template for unit test JSON input    |
|                         |                | file for Oracle PL/SQ Timer_Set module                |
====================================================================================================

**************************************************************************************************#>
Import-Module ..\powershell_utils\TrapitUtils\TrapitUtils
Write-UT_Template 'purely_wrap_timer_set' '|'