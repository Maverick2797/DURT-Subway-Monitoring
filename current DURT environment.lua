S.termini = {
    E = "Tro",
    W = "Dbl"
}

S.stations = {
    Dbl = "Dubulti",
    Pav = "Pence Avenue",
    Ghd = "Greenhat Mountain",
    Acm = "Acacia Mountains",
    Ghb = "Green Hill Beach",
    Ged = "Green Edge",
    Dri = "Dry Island",
    Gcl = "Green Cliffs",
    Sfs = "South Forest",
    Jms = "Jude Milhon Street",
    Bam = "Bamboo Hills",
    Cli = "Clown Island",
    Wat = "Something in the Water",
    Duf = "Duff Rd",
    Tro = "Turtle Rock"
}

S.next_station = {
    E = {
        Dbl = "Pav",
        Pav = "Ghd",
        Ghd = "Acm",
        Acm = "Ghb",
        Ghb = "Ged",
        Ged = "Dri",
        Dri = "Gcl",
        Gcl = "Sfs",
        Sfs = "Jms",
        Jms = "Bam",
        Bam = "Cli",
        Cli = "Wat",
        Wat = "Duf",
        Duf = "Tro"
    },
    W = {
        Tro = "Duf",
        Duf = "Wat",
        Wat = "Cli",
        Cli = "Bam",
        Bam = "Jms",
        Jms = "Sfs",
        Sfs = "Gcl",
        Gcl = "Dri",
        Dri = "Ged",
        Ged = "Ghb",
        Ghb = "Acm",
        Acm = "Ghd",
        Ghd = "Dbl",
    }
}

S.doors = {
    Tro = "L",
    Duf = "R",
    Wat = "L",
    Cli = "R",
    Bam = "R",
    Jms = "R",
    Sfs = "R",
    Gcl = "R",
    Dri = "L",
    Ged = "L",
    Ghb = "L",
    Acm = "L",
    Ghd = "L",
    Dbl = "R",
    Pav = "L"
}

F.arrive = function(stn_code)
    atc_send("B0 W O"..S.doors[stn_code])
    atc_set_text_inside(S.stations[stn_code])
end

F.leave = function(stn_code, dir)
    -- Try to set departure route e.g. StaW->Stb
    local pos = stn_code .. dir
    local route = stn_code .. "->" .. S.next_station[dir][stn_code]
    if can_set_route(pos, route) then
        set_route(pos, route)
        atc_set_text_inside("Next stop:\n" .. S.stations[S.next_station[dir][stn_code]])
        atc_send("OC SM")
        return
    end
    -- Wait another 5s before trying again
    atc_set_text_inside("Waiting to depart...")
    interrupt(5, "depart")
end

F.set_desto = function(dir, line)
    atc_set_text_outside("LINE " .. line ..
        "\n---> " .. S.stations[S.termini[dir]])
end

F.station = function(stn_code, dir)
    if event.train then
        F.arrive(stn_code)
        interrupt(10, "depart")
    end
    if event.int and event.msg == "depart" then 
        F.leave(stn_code, dir)
    end
 end
 
F.terminus = function(stn_code, newdir, line)
    if event.train then
        atc_set_text_inside(S.stations[stn_code])
        atc_send("B0 W R O"..S.doors[stn_code])
        F.set_desto(newdir, line)
        interrupt(10, "depart")
    end
    if event.int and event.msg == "depart" then
        F.leave(stn_code, newdir)
    end
end