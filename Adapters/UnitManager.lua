UnitManager = {}

function UnitManager.enableFriendliesOnly(notInCombat, exceptTheseIDs)
    for obj in getAllObjects() do
        local unit = Unit:adaptFrom(obj)
        if unit then
            local enabled =
                unit:isFriendly() and not exceptTheseIDs[unit:getID()] and not (unit:inCombat() and notInCombat)
            obj.interactable = not enabled

            if enabled then
                obj.highlightOn(Colors.green)
            else
                obj.highlightOff()
            end
        end
    end
end

function UnitManager.enableEnemiesInRange(units, range, notInCombat)
    for obj in getAllObjects() do
        local unit = Unit:adaptFrom(obj)
        if unit then
            local isInRange = false
            for unit in units do
                if
                    unit:isEnemy() and unit:rangeTo(unit:getLocation()) <= range and
                        not (unit:inCombat() and notInCombat)
                 then
                    isInRange = true
                    break
                end
            end
            obj.interactable = not isInRange

            if isInRange then
                obj.highlightOn(Colors.red)
            else
                obj.highlightOff()
            end
        end
    end
end

function UnitManager.enableSquadOnly(squad)
    for obj in getAllObjects() do
        local unit = Unit:adaptFrom(obj)
        if unit then
            local inSquad = unit.name == squad and unit:isFriendly()
            obj.interactable = not inSquad

            if inSquad then
                units[unit:getID()] = obj
                obj.highlightOn(Colors.green)
            else
                obj.highlightOff()
            end
        end
    end
end

function UnitManager.getSquad(name, highlightOn)
    local units = {}
    for obj in getAllObjects() do
        local unit = Unit:new(obj)
        if unit then
            if unit.name == name then
                if highlightOn then
                    obj.highlightOn(Colors.green)
                end
                units[obj.getGUID()] = obj
            end
        end
    end
    return units
end

function UnitManager.resetAllUnits(clearAttr)
    for obj in getAllObjects() do
        local unit = Unit:adaptFrom(obj)
        if unit then
            obj.interactable = true
            obj.highlightOff()
            if clearAttr then
                unit.clearAttributes()
            end
        end
    end
end

function UnitManager.getObjectByID(id)
    return getObjectFromGUID(id)
end
