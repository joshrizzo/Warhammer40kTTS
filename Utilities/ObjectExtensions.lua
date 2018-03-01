function Object:getOwner()
    return string.match(self.getDescription(), '[(.+)]')
end

function Object:isFriendly(player)
    return self:getOwner() == player
end

function Object:isEnemy()
    return not self:isFriendly()
end

function Object:getStat(stat)
    return tonumber(string.match(self.description, stat .. '(%d+)%s'))
end

function Object:applyModifiers(event, phase)
    for mod in string.gfind(self.getDescription(), '/' .. event .. ':(.+);') do
        local condition = loadstring(mod)
        setfenv(condition, phase)
        condition() -- WARNING: SIDE EFFECTS - these scripts should modify the phase variables.
    end
    return context
end

function Object:triggerEvent(event)
    for event in string.gfind(self.getDescription(), '\\' .. event .. ':(.+);') do
        loadstring(event)()
    end
end

function Object:rangeTo(vector)
    local v1 = self.getPosition()
    local v2 = vector
    return math.abs(math.sqrt((((v2.x - v1.x) ^ 2) + ((v2.y - v1.y) ^ 2) + ((v2.z - v1.z) ^ 2))))
end

function Object:release()
    self.setLocation(self.getVar("startingLocation") or self.getLocation())
end

function Object:resetUnit(highlightOff)
    self.setLocked(true)
    if highlightOff then
        self.highlightOff()
    end
    self:release()
end

function Object:getID()
    return self.guid
end

function Object:getLocation()
    return self.getPosition()
end

function Object:getSquad()
    return string.match(self.getDescription(), 'Squad\((.+)\)')
end

function Object:objectsInRange(size)
    local hits = Physics.cast({
        origin = self.getLocation(),
        type = 2, -- Sphere
        size = size * InchesToPoints
    })

    local objs = {}
    for hit in hits do
        table.insert(objs, hit.hit_object)
    end
    return objs
end

function Object:getClosest()
    local hits = Physics.cast({
        origin = self.getLocation(),
        type = 2, -- Sphere
        size = 60 * InchesToPoints
    })

    local closest = hits[0]
    for hit in hits do
        if closest and closest.distance > hit.distance then
            closest = hit
        end
    end
    return closest.hit_object
end

function Object:inSquadCoherency()
    local isInCoherency = false
    local squad = self:getSquad()
    for obj in self:objectsInRange(2) do
        if obj:getSquad() == squad then
            isInCoherency = true
        end
    end
    return isInCoherency
end