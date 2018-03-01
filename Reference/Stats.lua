Stats = {
    M = "M",
    WS = "WS",
    BS = "BS",
    S = "S",
    T = "T",
    W = "W",
    A = "A",
    LD = "LD",
    SV = "SV",
    IS = "IS",
    IW = "IW"
}

function Stats.applyModifiers(event, phase, mods)
    for mod in string.gfind(mods, '/' .. event .. ':(.+);') do
        local condition = loadstring(mod)
        setfenv(condition, phase)
        condition() -- WARNING: SIDE EFFECTS - these scripts should modify the phase variables.
    end
    return phase
end