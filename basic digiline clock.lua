local clock_speed = 3
local lever = "d"
if event.type=="interrupt" then
    if not pin[lever] then return end
    digiline_send("clock","pulse")
    interrupt(clock_speed)
    return
end
if event.type=="on" then interrupt(1) return end