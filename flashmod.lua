flash = {MOD_NAME = "flash"}

function flash.flashMod(tbl)
	if type(tbl) == "string" then tbl = {MOD_NAME=tbl} end 
	for k,v in pairs(tbl) do
		if type(v) == "function" then
			local f = string.format("%s_%s.lc", tbl.MOD_NAME, k)
			log_debug("Serializing flash module function "..f)
			file.open(f, "w+")
			file.write(string.dump(v))
			file.close()
			tbl[k] = nil
		end
	end
	return setmetatable(tbl, {
		__index = function(t, k)
			return assert(loadfile(string.format("%s_%s.lc",t.MOD_NAME,k)))
		end
	})
end

if (dev_cfg ~= nil and dev_cfg.flashMod) or (dev_cfg == nil) then flash.flashMod(flash) end
flash = nil
module = nil
package = nil
newproxy = nil
require = nil
collectgarbage()

function flashMod(tbl) return loadfile("flash_flashMod.lc")(tbl) end
