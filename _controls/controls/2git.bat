set dota_folder=C:\Steam\steamapps\common\dota 2 beta
set addon_name=ballon

set game_folder=%dota_folder%\game\dota_addons\%addon_name%
set content_folder=%dota_folder%\content\dota_addons\%addon_name%
set git_folder=%~dp0/..
rd "%~dp0/game" /s /q
rd "%~dp0/content" /s /q
xcopy "%game_folder%" "%git_folder%/game" /y /e /i
xcopy "%content_folder%" "%git_folder%/content" /y /e /i