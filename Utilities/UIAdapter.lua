UIAdapter = {
    pickup = nil,
    release = nil,
    turnStart = nil
}

function UIAdapter.messagePlayers(message, color)
    broadcastToAll(message, color)
end

function UIAdapter.enableFriendliesOnly(exceptTheseIDs)
    for obj in getAllObjects() do
        local enabled = obj:isFriendly() and not exceptTheseIDs[obj:getID()]
        obj.setLocked(not enabled)

        if enabled then
            obj.highlightOn(Colors.green)
        else
            obj.highlightOff()
        end
    end
end

function UIAdapter.enableEnemiesInRange(location, range)
    for obj in getAllObjects() do
        local isInRange = obj:isEnemy() and obj:rangeTo(location) <= range
        obj.setLocked(isInRange)

        if isInRange then
            obj.highlightOn(Colors.red)
        else
            obj.highlightOff()
        end
    end
end

function UIAdapter.getAndEnableSquadOnly(squad)
    local units = {}
    for obj in getAllObjects() do
        local inSquad = obj:getSquad() == squad and obj:isFriendly()
        obj.setLocked(inSquad)

        if inSquad then
            units[obj:getID()] = obj
            obj.highlightOn(Colors.green)
        else
            obj.highlightOff()
        end
    end
    return units
end

function UIAdapter.getSquad(squad)
    local units = {}
    for obj in getAllObjects() do
        if obj:getSquad() == squad then
            units[obj:getID()] = obj
        end
    end
    return units
end

function UIAdapter.resetAllUnits()
    for obj in getAllObjects() do
        obj.setLocked(true)
        obj.highlightOff()
    end
end

function UIAdapter.clearAllUnits()
    for obj in getAllObjects() do
        obj.setLocked(false)
        obj.highlightOff()
    end
end

function UIAdapter.spawnIndicator(location, color, size)
    local rangeIndicator =
        spawnObject(
        {
            type = "Custom_Model",
            position = obj.getPosition()
        }
    )
    rangeIndicatorsetCustomObject(
        {
            mesh = "https://my.mixtape.moe/xqbmrf.obj",
            collider = "http://pastebin.com/raw.php?i=ahfaXzUd"
        }
    )
    rangeIndicator.setColorTint(color)
    rangeIndicator.scale(size / 10) -- The texture is 10" wide at scale.

    return rangeIndicator
end

function UIAdapter.getPhase()
    return getObjectFromGUID(phaseIndicator).getValue()
end

function UIAdapter.resetObject(objId, highlightOff)
    getObjectFromGUID(objId):resetUnit()
end

function UIAdapter.getObjectByID(id)
    return getObjectFromGUID(id)
end

function UIAdapter.createCustomButton (label, functionName, position)
    local button = {}
    button.click_function = sFunctionName
    button.label = sLabel
    button.function_owner = self
    button.position = tPosition
    button.rotation = {0, 0, 0}
    button.width = 900
    button.height = 400
    button.font_size = 200

    oParent.createButton(button)
end