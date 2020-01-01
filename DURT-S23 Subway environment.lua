S.lines = {
	S23 = {
		termini = {
			N = "Bbh",
			S = "Rdw"
		},
		stations = {
			Rdw = {
				name = "Redwood",
				doors = "L",
				next_station = {
					N = "Thc",
					S = false
				},
			},
			Thc = {
				name = "Tanh Cliffs",
				doors = "L",
				next_station = {
					N = "Noi",
					S = "Rdw"
				},
			},
			Noi = {
				name = "No Idea",
				doors = "L",
				next_station = {
					N = "Lzf",
					S = "Thc"
				},
			},
			Lzf = {
				name = "Laza's Field",
				doors = "L",
				next_station = {
					N = "Bbh",
					S = "Noi"
				},
			},
			Bbh = {
				name = "Bamboo Hills",
				doors = "L",
				next_station = {
					N = false,
					S = "Lzf"
				},
			}
		},
		monitoring = {
			N = {},
			S = {}
		}
	},
	S21 = {
	
	}
}

---------------------------------------------------------------------
--defining the functions

F.arrive = function(stn_code,dir,line)
	S.lines[line].monitoring[dir][stn_code] = atc_id
    atc_send("B0 W O"..S.lines[line].stations[stn_code].doors)
    atc_set_text_inside("Arrived at:\n"..S.lines[line].stations[stn_code].name.."\n \nNext Station:\n"..S.lines[line].stations[S.lines[line].stations[stn_code].next_station[dir]].name)
end

F.depart = function(stn_code,dir,line)
	if can_set_route(stn_code.."_exit_"..dir,"To "..S.lines[line].stations[stn_code].next_station[dir]) then
		set_route(stn_code.."_exit_"..dir,"To "..S.lines[line].stations[stn_code].next_station[dir])
		atc_set_text_inside("Next Stop:\n"..S.lines[line].stations[S.lines[line].stations[stn_code].next_station[dir]].name)
		atc_send("OC SM")
		S.lines[line].monitoring[dir][stn_code] = nil
	else
		-- Wait another 5s before trying again
		atc_set_text_inside("Waiting to depart...")
		interrupt(5, "depart")
	end
end

F.set_desto = function(dir, line)
    atc_set_text_outside("LINE " .. line .."\n---> " .. S.lines[line].stations[S.lines[line].termini[dir]].name)
end

---------------------------------------------------------------------
--LuaATC track functions

F.station = function(stn_code,dir,line)
	if event.train then
		F.arrive(stn_code,dir,line)
		interrupt(10,"depart")
	elseif event.int and event.msg=="depart" then
		F.depart(stn_code,dir,line)
	end
end

 
F.terminus = function(stn_code, newdir, line)
    if event.train then
		S.lines[line].monitoring[newdir][stn_code] = atc_id
		
		atc_send("B0 W R O"..S.lines[line].stations[stn_code].doors)
		atc_set_text_inside("Arrived at:\n"..S.lines[line].stations[stn_code].name.."\n \nNext Station:\n"..S.lines[line].stations[S.lines[line].stations[stn_code].next_station[newdir]].name)

        atc_set_text_outside("LINE " .. line .."\n---> " .. S.lines[line].stations[S.lines[line].termini[newdir]].name)
        interrupt(10, "depart")
    end
    if event.int and event.msg == "depart" then
        F.depart(stn_code, newdir,line)
    end
end