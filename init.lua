----------------------------------------
-- init.lua                           --
-- desc   : lua bootstrap             --
-- rev    : 3.0                       --
-- date   : 05/02/2021                --
-- author : tuan nguyen (pdxtigre)    --
-- email  : info@codesmiths.org       --
-- website: https://codesmiths.org    --
----------------------------------------
dofile("config.lc")
timer=tmr.create()	
-- uart.setup(0,921600,8,0,1,1)
log_debug("dob: "..dev_cfg.dob..", rev: "..dev_cfg.rev..", app: "..dev_cfg.app..", heap: "..node.heap())
dofile("flashmod.lc")
log_debug("Flash mod enabled.."..node.heap())
if dev_cfg.start then
	log_debug("You have 3 seconds to abort startup.."..node.heap())
	timer:alarm(3000, tmr.ALARM_SINGLE, function() flashMod("main"):start() end)
end