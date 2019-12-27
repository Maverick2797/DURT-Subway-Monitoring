--set stn_code to the station's code, and ports as needed
local stn_code = ""
local nlight = "d"
local slight = "b"
if event.type=="digiline" and event.channel=="status_update" then
	if event.msg.N[stn_code] then port[nlight] = true else port[nlight] = false end
	if event.msg.S[stn_code] then port[slight] = true else port[slight] = false end
	return
end
