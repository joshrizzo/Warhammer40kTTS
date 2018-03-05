function UnitManager.enableFriendliesOnly(exceptTheseIDs)
    for obj in getAllObjects() do
        local enabled = obj:isFriendly() and not exceptTheseIDs[obj:getID()]
        obj.interactable = not enabled

        if enabled then
            obj.highlightOn(Colors.green)
        else
            obj.highlightOff()
        end
    end
end

function UnitManager.enableEnemiesInRange(units, range)
    for obj in getAllObjects() do
        local isInRange = false
        for unit in units do
            if obj:isEnemy() and obj:rangeTo(unit:getLocation()) <= range then
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

function UnitManager.getAndEnableSquadOnly(squad)
    local units = {}
    for obj in getAllObjects() do
        local inSquad = obj:getSquad() == squad and obj:isFriendly()
        obj.interactable = not inSquad

        if inSquad then
            units[obj:getID()] = obj
            obj.highlightOn(Colors.green)
        else
            obj.highlightOff()
        end
    end
    return units
end

function UnitManager.getSquad(squad, highlightOn)
    local units = {}
    for obj in getAllObjects() do
        if obj:getSquad() == squad then
            if highlightOn then
                obj.highlightOn(Colors.green)
            end
            units[obj:getID()] = obj
        end
    end
    return units
end

function UnitManager.resetAllUnits()
    for obj in getAllObjects() do
        obj.interactable = true
        obj.highlightOff()
    end
end

function UnitManager.getObjectByID(id)
    return getObjectFromGUID(id)
end