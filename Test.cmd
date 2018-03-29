@echo off

echo LinkTime - test task
echo.

echo Restoring nuget packages
nuget restore LinkTime.sln
if errorlevel 1 goto error

echo Building solution (debug)
msbuild.exe /consoleloggerparameters:ErrorsOnly /maxcpucount /nologo ^
  /property:Configuration=Debug /property:Platform="Any CPU" ^
  /verbosity:quiet ^
  LinkTime.sln
if errorlevel 1 goto error

echo Running unit tests
.\Build\Packages\NUnit.ConsoleRunner.3.6.0\tools\nunit3-console.exe .\Build\Debug\LinkTime.Test.dll ^
--inprocess ^
--work=.\Build\Debug\ ^
--result=LinkTime.TestReport.xml
if errorlevel 1 goto error

echo Running code coverage analysis
.\Build\Packages\OpenCover.4.6.519\tools\OpenCover.Console.exe ^
  -register:user ^
  "-filter:+[*]* -[LinkTime.Test]*" ^
  -target:".\Build\Packages\NUnit.ConsoleRunner.3.6.0\tools\nunit3-console.exe" ^
  -targetargs:".\Build\Debug\LinkTime.Test.dll --inprocess --result=.\Build\Debug\LinkTime.TestReport.xml" ^
  -output:.\Build\Debug\LinkTime.Coverage.xml
if errorlevel 1 goto error

echo Generating coverage report
.\Build\Packages\ReportGenerator.2.5.8\tools\ReportGenerator.exe ^
  -reports:".\Build\Debug\LinkTime.Coverage.xml" ^
  -targetdir:".\Build\Debug\Coverage"
if errorlevel 1 goto error

:success
echo.
echo Test successful
exit /b 0

:error
echo.
echo Test failed
exit /b 1