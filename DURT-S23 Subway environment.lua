S.termini = {
	N = "Bbh",
	S = "Rdw"
}
S.stations = {
	Rdw = {
		name = "Redwood",
		doors = "L",
		next_station = {
			N = "Thc",
			S = false
		},
	},
	Thc = {
		name = "Tahn Cliffs",
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
}
S.monitoring = {
	N = {},
	S = {}
}

---------------------------------------------------------------------
--defining the functions

F.arrive = function(stn_code,dir)
	S.monitoring[dir][stn_code] = atc_id
    atc_send("B0 W O"..S.stations[stn_code].doors)
    atc_set_text_inside("Arrived at:\n"..S.stations[stn_code].name.."\n \nNext Station:\n"..S.stations[S.stations[stn_code].next_station[dir]].name)
end

F.depart = function(stn_code,dir)
	if can_set_route(stn_code.."_exit_"..dir,"To "..S.stations[stn_code].next_station[dir]) then
		set_route(stn_code.."_exit_"..dir,"To "..S.stations[stn_code].next_station[dir])
		atc_set_text_inside("Next Stop:\n"..S.stations[S.stations[stn_code].next_station[dir]].name)
		atc_send("OC SM")
		S.monitoring[dir][stn_code] = nil
	else
		-- Wait another 5s before trying again
		atc_set_text_inside("Waiting to depart...")
		interrupt(5, "depart")
	end
end

F.set_desto = function(dir, line)
    atc_set_text_outside("LINE " .. line .."\n---> " .. S.stations[S.termini[dir]].name)
end

---------------------------------------------------------------------
--LuaATC track functions

F.station = function(stn_code,dir)
	if event.train then
		F.arrive(stn_code,dir)
		interrupt(10,"depart")
	elseif event.int and event.msg=="depart" then
		F.depart(stn_code,dir)
	end
end

 
F.terminus = function(stn_code, newdir, line)
    if event.train then
		S.monitoring[newdir][stn_code] = atc_id
		
		atc_send("B0 W R O"..S.stations[stn_code].doors)
		atc_set_text_inside("Arrived at:\n"..S.stations[stn_code].name.."\n \nNext Station:\n"..S.stations[S.stations[stn_code].next_station[newdir]].name)

        atc_set_text_outside("LINE " .. line .."\n---> " .. S.stations[S.termini[newdir]].name)
        interrupt(10, "depart")
    end
    if event.int and event.msg == "depart" then
        F.depart(stn_code, newdir)
    end
end
