    @echo off

SetLocal EnableDelayedExpansion

if [%1]==[] goto USAGE

set _TargetFile=%1
::Strip any quotes

::Get Current code page
for /f "tokens=*" %%x in ('chcp') do for %%y in (%%~x) do set currentCodePage=%%y

::Get the name of the project and the target directory
for %%f in (%_TargetFile%) do ( set _TargetName=%%~nf)
for %%g in (%_TargetFile%) do ( set _TargetPath=%%~pg)

CALL :TRIM %_TargetName% _TargetName
CALL :TRIM %_Targetpath% _Targetpath


::change current code page to UTF-8
chcp 65001 > NUL

::The outputfile
set output=%_TargetName%.targets

::Substitutions for the output
set TargetName=%_TargetName%
set TargetFile=%_TargetFile:"=%

::Write the template out
pushd %_Targetpath%
call :TEMPLATE > "%OUTPUT%"
popd

::change the codepage back
chcp %currentCodePage% > NUL

GOTO :EOF

:TEMPLATE
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<Project
echo          ToolsVersion="4.0"
echo          xmlns="http://schemas.microsoft.com/developer/msbuild/2003"^>
echo. 
echo     ^<^^!-- List Dependencies here --^>
echo     ^<PropertyGroup^>
echo         ^<%TargetName%DependsOn Condition=" '$(ExplicitTargetsOnly)' ^!= 'true' " ^>
echo         ^</%TargetName%DependsOn^>
echo     ^</PropertyGroup^>
echo.     
echo     ^<^^!-- Hook in to top level targets here --^>
echo     ^<ItemGroup^>
echo         ^<CleanAllDependsOn Include="Clean%TargetName%" /^>
echo         ^<BuildAllDependsOn Include="%TargetName%"/^>
echo     ^</ItemGroup^>
echo.
echo     ^<^^!-- Projects to Build --^>
echo     ^<ItemGroup^>
echo         ^<%TargetName%ProjectsToBuild Include="%TargetFile%"^>
echo            ^<Properties^>Configuration=$(Configuration);Platform=$(Platform)^</Properties^>
echo         ^</%TargetName%ProjectsToBuild^>
echo     ^</ItemGroup^>
echo. 
echo     ^<^^!-- Build Targets --^>
echo     ^<Target Name="%TargetName%"  DependsOnTargets="$(%TargetName%DependsOn)"^>
echo         ^<MSBuild Projects="@(%TargetName%ProjectsToBuild)" /^>
echo     ^</Target^>
echo. 
echo     ^<Target Name="Clean%TargetName%"^>
echo         ^<MSBuild Projects="@(%TargetName%ProjectsToBuild)" Targets="Clean" /^>
echo     ^</Target^>
echo ^</Project^> 
GOTO :EOF

:TRIM
SET %2=%1
GOTO :EOF

:USAGE
echo Creates a template .targets file for a project.
echo.
echo Usage: CreateTarget ".\Path to\My\Code\ProjectFile.vbproj"
echo.
echo This should be called from the project root (Where Build.proj is) and relative paths 
echo used to indicate the project file.
echo. 
echo The output will use the relative path to include the project in the build and will use
echo the file base name as the target project name.
echo.
echo The usage example will output a target to .\Path to\My\Code\ProjectFile.targets

:EOF 
exit /B 0

