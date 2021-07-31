set dota_folder=C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta
set addon_name=balloon

set game_folder=%dota_folder%\game\dota_addons\%addon_name%
set content_folder=%dota_folder%\content\dota_addons\%addon_name%
set git_folder=%~dp0/../..
rd "%game_folder%" /s /q
rd "%content_folder%" /s /q
xcopy "%git_folder%/game" "%game_folder%" /y /e /i
xcopy "%git_folder%/content" "%content_folder%" /y /e /i