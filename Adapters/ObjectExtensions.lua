Unit = {
    patterns = {
        name = "%[(.+)%]%s*(.+)%s*(%d)/%d",
        description = "[,:]?%s?([^,:]+)[,:\n]?"
    }
}

function Unit:adaptFrom(obj)
    -- Pull the Unit from the cache on obj, if it exists.
    local existing = obj.getTable("Unit")
    if existing then return existing end

    local new = setmetatable({}, {__index = Unit})
    new.object = obj

    new.mods = {}
    local desc = obj.getDescription()
    for rule in desc:match(self.patterns.description) do
        SpecialRules[rule](new)
    end

    local nameMatches = string.match(self.object.getName(), self.patterns.name)
    new.owner = nameMatches[0]
    new.name = nameMatches[1]
    new.remainingW = nameMatches[2]

    obj.setTable("Unit", new) -- Save on the object for caching.
    return new
end

function Unit:isFriendly()
    return self.owner == Game.players.current
end

function Unit:isEnemy()
    return not self:isFriendly()
end

function Unit:rangeTo(vector)
    local v1 = self.object.getPosition()
    local v2 = vector
    return math.abs(math.sqrt((((v2.x - v1.x) ^ 2) + ((v2.y - v1.y) ^ 2) + ((v2.z - v1.z) ^ 2))))
end

function Unit:release()
    self.object.setLocation(self.object.getVar("startingLocation") or self.object.getLocation())
end

function Unit:resetUnit(highlightOff)
    self.object.interactable = true
    if highlightOff then
        self.object.highlightOff()
    end
    self:release()
end

function Unit:getID()
    return self.object.guid
end

function Unit:getLocation()
    return self.object.getPosition()
end

function Unit:objectsInRange(size)
    local hits =
        Physics.cast(
        {
            origin = self.object.getLocation(),
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

function Unit:getClosest()
    local hits =
        Physics.cast(
        {
            origin = self.object.getLocation(),
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

function Unit:applyModifiers(event, phase)
    return Stats.applyModifiers(event, phase, self.getDescription())
end

function Object:triggerEvent(event)
    for event in string.gfind(self.getDescription(), "\\" .. event .. ":(.+);") do
        loadstring(event)()
    end
end

--TODO: Refactor into Unit class and parse from description on creation.

function Object:getSquad()
    return string.match(self.getDescription(), "Squad[(](.+)[)]")
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
        return UnitManager.getSquad(squad, highlightOn)
    else
        return {[self:getID()] = self}
    end
end

function Object:createCustomButton(label, funcOwner, funcName, funcParams)
    local position = self.getButtons()
    self.createButton(
        {
            rotation = {0, 0, 0},
            width = 900,
            height = 400,
            font_size = 200,
            function_owner = funcOwner,
            click_function = funcName,
            function_params = funcParams,
            label = label,
            position = {0, 1, #position}
        }
    )
end

function Object:clearControls()
    self.clearButtons()
end

function Object:getShootingWeapons()
    -- TODO: parse out weapons
end
