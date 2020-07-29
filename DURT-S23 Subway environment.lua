S.lines = {
	S23 = {
		termini = {
			N = "Arc",
			S = "Rew"
		},
		stations = {
			Rew = {
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
					S = "Rew"
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
					N = "Arc",
					S = "Lzf"
				},
			},
			Arc = {
				name = "Arcadius",
				doors = "L",
				next_station = {
					N = false,
					S = "Bbh"
				},
			}
		},
		monitoring = {
			N = {},
			S = {}
		}
	},
	U21 = {
		termini = {
			E = "Tro",
			W = "Dbl"
		},
		stations = {
			Dbl = {
				name = "Dubulti",
				doors = "R",
				next_station = {
					E = "Pav",
					W = "Ghd"
				}
			},
			Pav = {
				name = "Pence Avenue",
				doors = "L",
				next_station = {
					E = "Ghd",
					W = "Dbl"
				}
			},
			Ghd = {
				name = "Greenhat Mountain",
				doors = "L",
				next_station = {
					E = "Acm",
					W = "Dbl"
				}
			},
			Acm = {
				name = "Acacia Mountains",
				doors = "L",
				next_station = {
					E = "Ghb",
					W = "Ghd"
				}
			},
			Ghb = {
				name = "Green Hill Beach",
				doors = "L",
				next_station = {
					E = "Ged",
					W = "Acm"
				}
			},
			Ged = {
				name = "Green Edge",
				doors = "L",
				next_station = {
					E = "Dri",
					W = "Ghb"
				}
			},
			Dri = {
				name = "Dry Island",
				doors = "L",
				next_station = {
					E = "Gcl",
					W = "Ged"
				}
			},
			Gcl = {
				name = "Green Cliffs",
				doors = "R",
				next_station = {
					E ="Sfs",
					W = "Dri"
				}
			},
			Sfs = {
				name = "South Forest",
				doors = "R",
				next_station = {
					E = "Jms",
					W = "Gcl"
				}
			},
			Jms = {
				name = "Jude Milhon Street",
				doors = "R",
				next_station = {
					E = "Bam",
					W = "Sfs"
				}
			},
			Bam = {
				name = "Bamboo Hills",
				doors = "R",
				next_station = {
					E = "Cli",
					W = "Jms"
				}
			},
			Cli = {
				name = "Clown Island",
				doors = "R",
				next_station = {
					E = "Wat",
					W = "Bam"
				}
			},
			Wat = {
				name = "Something in the Water",
				doors = "L",
				next_station = {
					E = "Duf",
					W = "Cli"
				}
			},
			Duf = {
				name = "Duff Rd",
				doors = "R",
				next_station = {
					E = "Tro",
					W = "Wat"
				}
			},
			Tro = {
				name = "Turtle Rock",
				doors = "L",
				next_station = {
					E = false,
					W = "Duf"
				},
			}
		},
		monitoring = {
			E = {},
			W = {},
			S = {},
			N = {}
		}
	}
}

S.runarounds = {
	["TheStacks"] = {},
	["M27_Quarry_runaround"] = {},
	["M27_Breaker_Factory"] = {},
}
---------------------------------------------------------------------
--defining the functions

F.arrive = function(stn_code,dir,line)
	S.lines[line].monitoring[dir][stn_code] = atc_id
    atc_send("B0 W O"..S.lines[line].stations[stn_code].doors)
    atc_set_text_inside("Arrived at:\n"..S.lines[line].stations[stn_code].name.."\n \nNext Station:\n"..S.lines[line].stations[S.lines[line].stations[stn_code].next_station[dir]].name)
end

F.depart = function(stn_code,dir,line)
	local pos = stn_code..dir
	local inside_text = "Next Stop:\n"..S.lines[line].stations[S.lines[line].stations[stn_code].next_station[dir]].name
	if can_set_route(pos,stn_code.."->"..S.lines[line].stations[stn_code].next_station[dir]) then
		set_route(pos,stn_code.."->"..S.lines[line].stations[stn_code].next_station[dir])
		atc_send("OC SM")
		S.lines[line].monitoring[dir][stn_code] = nil
		S.lines[line].monitoring[dir][S.lines[line].stations[stn_code].next_station[dir]] = atc_id
	else
		-- Wait another 5s before trying again
		inside_text = inside_text.."\nWaiting to depart..."
		interrupt(5, "depart")
	end
	atc_set_text_inside(inside_text)
end

F.set_desto = function(dir, line)
    atc_set_text_outside("LINE " .. line .."\n---> " .. S.lines[line].stations[S.lines[line].termini[dir]].name)
end

---------------------------------------------------------------------
--LuaATC track functions

F.station = function(stn_code,dir,line)

-- temp until all SF LuaAtc tracks are changed-------------------------
	if line == nil or line == "1" then
		line = "U21"
	end
---------------------------------------------------------------------

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