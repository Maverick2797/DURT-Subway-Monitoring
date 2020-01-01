local line = "S23"
if event.punch or (event.channel=="clock" and event.msg=="pulse")then
digiline_send("status_update",S.lines[line].monitoring)
end