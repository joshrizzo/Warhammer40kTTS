Unit = {
    patterns = {
        name = "%[(.+)%]%s*(.+)%s*(%d)/%d",
        description = "[,:]?%s?([^,:]+)[,:\n]?"
    }
}

function Unit:adaptFrom(obj)
    -- Make sure this is actually a unit in the game.
    if not obj or not obj.getName():match("^%[.+%].+") then
        return nil
    end

    -- Pull the Unit from the cache on obj, if it exists.
    local existing = obj.getTable("Unit")
    if existing then
        return existing
    end

    local new = setmetatable({}, {__index = Unit})
    new.object = obj

    -- Get all modifiers and special rules.
    new.mods = {}
    local desc = obj.getDescription()
    for rule in desc:match(self.patterns.description) do
        SpecialRules[rule](new)
    end

    -- Parse out the name field.
    local nameMatches = string.match(self.object.getName(), self.patterns.name)
    new.owner = nameMatches[0]
    new.name = nameMatches[1]
    new.remainingW = nameMatches[2]

    -- Get the other members of the unit's squad.
    local squad = UnitManager.getSquad(new.name)
    if #squad > 1 then
        new.squad = squad
    end

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

function Unit:reset(highlightOff)
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
        local unit = Unit:adaptFrom(hit.hit_object)
        if closest and unit and closest.distance > hit.distance then
            closest = hit
        end
    end
    return Unit:adaptFrom(closest.hit_object)
end

function Unit:applyModifiers(event, phase)
    for mod in self.mods[event] do
        mod(phase)
    end
end

function Unit:inSquadCoherency()
    local isInCoherency = not squad
    for obj in self:objectsInRange(2) do
        local unit = Unit:adaptFrom(obj)
        if unit and unit.name == self.name and self.obj.getGUID() ~= unit.object.getGUID() then
            isInCoherency = true
        end
    end
    return isInCoherency
end

function Unit:inCombat()
    local isInCombat = false
    for unit in self.squad do
        for obj in unit:objectsInRange(1) do
            local u = Unit:adaptFrom(obj)
            if u and u:isEnemy() then
                isInCombat = true
            end
        end
    end
    return isInCombat
end

function Unit:createCustomButton(label, funcOwner, funcName, funcParams)
    local buttons = self.object.getButtons()
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
            position = {0, 1, #buttons}
        }
    )
end

function Unit:clearControls()
    self.object.clearButtons()
end

function Object:getShootingWeapons()
    local shootingWeapons = {}
    for unit in self.squad or {self} do
        for weapon in unit.weapons do
            if weapon.type ~= WeaponTypes.Melee then
                shootingWeapons:insert(weapon)
            end
        end
    end
    return shootingWeapons
end

function Unit:applyAttribute(attr)
    self.object.setName(self.object.getName() .. " (" .. attr .. ")")
    self.attr[attr] = true
end

function Unit:hasAttribute(attr)
    return self.attr[attr]
end

function Unit:clearAttributes()
    self.object.setName(self.object.getName():gsub("(.+)", ""))
    self.attr = {}
end
