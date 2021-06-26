call nodemcu-tool fsinfo
call nodemcu-tool upload config.lua main.lua mqtt_ioc.lua mqtt_core.lua mqtt_extra.lua ioc.lua --compile
call nodemcu-tool run config.lc
call nodemcu-tool run main.lc
call nodemcu-tool run mqtt_ioc.lc
call nodemcu-tool run mqtt_core.lc
call nodemcu-tool run mqtt_extra.lc
call nodemcu-tool run ioc.lc
call nodemcu-tool fsinfo