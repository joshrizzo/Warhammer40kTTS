function Object:getOwner()
    return string.match(self.getDescription(), "[(.+)]")
end

function Object:getName()
    return self.name
end

function Object:isFriendly()
    return self:getOwner() == Game.players.current
end

function Object:isEnemy()
    return not self:isFriendly(Game.players.current)
end

function Object:getStat(stat)
    return tonumber(string.match(self.description, stat .. "(%d+)%s"))
end

function Object:applyModifiers(event, phase)
    return Stats.applyModifiers(event, phase, self.getDescription())
end

function Object:triggerEvent(event)
    for event in string.gfind(self.getDescription(), "\\" .. event .. ":(.+);") do
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
    return string.match(self.getDescription(), "Squad[(](.+)[)]")
end

function Object:objectsInRange(size)
    local hits =
        Physics.cast(
        {
            origin = self.getLocation(),
            type = 2, -- Sphere
            size = size * InchesToPoints
        }
    )

    local objs = {}
    for hit in hits do
        table.insert(objs, hit.hit_object)
    end
    return objs
end

function Object:getClosest()
    local hits =
        Physics.cast(
        {
            origin = self.getLocation(),
            type = 2, -- Sphere
            size = 60 * InchesToPoints
        }
    )

    local closest = hits[0]
    for hit in hits do
        if closest and closest.distance > hit.distance then
            closest = hit
        end
    end
    return closest.hit_object
end

function Object:inSquadCoherency()
    local squad = self:getSquad()
    local isInCoherency = not squad
    for obj in self:objectsInRange(2) do
        if obj:getSquad() == squad then
            isInCoherency = true
        end
    end
    return isInCoherency
end

function Object:getSquadMembers(highlightOn)
    local squad = self:getSquad()
    if squad then
        return UIAdapter.getSquad(squad, highlightOn)
    else
        return {[self:getID()] = self}
    end
end

function Object:createCustomButton(label, funcOwner, funcName, funcParams)
    local position = self.getButtons()
    self.createButton({
        rotation = {0, 0, 0},
        width = 900,
        height = 400,
        font_size = 200,
        function_owner = funcOwner,
        click_function = funcName,
        function_params = funcParams,
        label = label,
        position = {0, 1, #position}
    })
end

function Object:clearControls()
    self.clearButtons()
end

function Object:getShootingWeapons()
    -- TODO: parse out weapons
end