@echo off&setlocal
set git_folder=C:\Steam\steamapps\common\dota 2 beta\game\dota_addons\baloon_flight
rd "%git_folder%\game" /s /q
rd "%git_folder%\content" /s /q
xcopy "%~dp0" "%git_folder%\game" /y /e /i
for %%I in ("%~dp0\.") do set addon_name=%%~nxI
xcopy "%~dp0../../../content/dota_addons/%addon_name%" "%git_folder%\content" /y /e /i