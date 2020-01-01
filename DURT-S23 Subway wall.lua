--set stn_code to the station's code, and ports as needed
local stn_code = ""
local nlight = "c"
local slight = "a"
if event.type=="digiline" and event.channel=="status_update" then
	if event.msg.N[stn_code] then port[nlight] = true else port[nlight] = false end
	if event.msg.S[stn_code] then port[slight] = true else port[slight] = false end
	return
end
------------------------------
--terminus variant
--set stn_code to the station's code, 
	--direction to the new direction after exiting the terminus,
	--and ports->lights as needed
local stn_code = ""
local direction = ""
local light = "a"
if event.type=="digiline" and event.channel=="status_update" then
	if event.msg[direction][stn_code] then port[light] = true else port[light] = false end
	return
end
