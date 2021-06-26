-- 20536
-- ESP8266.Shadow Flash mod enabled..31416
print(tmr.now().." "..node.heap())
collectgarbage()
print(tmr.now().." "..node.heap())
for k,v in pairs(_G) do
	print(tostring(k).." --> "..tostring(v))
end
collectgarbage()
print(tmr.now().." "..node.heap())
