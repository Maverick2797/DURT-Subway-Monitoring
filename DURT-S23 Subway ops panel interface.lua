if event.punch or (event.channel=="clock" and event.msg=="pulse")then
local line = "S23"
local info = S.lines[line].monitoring
digiline_send("status_update",info)
end