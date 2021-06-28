----------------------------------------
-- ioc.lua                            --
-- desc   : io control                --
-- rev    : 1.0                       --
-- date   : 04/25/2021                --
-- author : tuan nguyen (pdxtigre)    --
-- email  : info@codesmiths.org       --
-- website: https://codesmiths.org    --
----------------------------------------

local ioc = {MOD_NAME="ioc"}

function ioc:init(cfg)
	log_debug("Initializing IO board..")
	if not cfg.deepSleep then
		for k,v in pairs(cfg.io.digital.outputs) do
			log_debug("Setting digital output "..v.pin)
			gpio.mode(v.pin, gpio.OUTPUT)
			gpio.write(v.pin, gpio.LOW)
		end
	end
	for k,v in pairs(cfg.io.digital.inputs) do
		log_debug("Setting digital input "..v.pin)
		gpio.mode(v.pin, gpio.INPUT)
	end
	log_debug("IO board initialization complete")
end

function ioc:pin_on(cfg, name)
	local dig = cfg.io.digital.outputs[name]
	local pin = dig.pin
	dig.state=1
	log_debug("Pin: "..tostring(pin).." HIGH")
	gpio.write(pin, gpio.HIGH)
end

function ioc:pin_off(cfg, name)
	local dig = cfg.io.digital.outputs[name]
	local pin = dig.pin
	dig.state=0
	log_debug("Pin: "..tostring(pin).." LOW")
	gpio.write(pin, gpio.LOW)
end

flashMod(ioc)