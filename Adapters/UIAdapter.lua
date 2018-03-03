function UIAdapter.messagePlayers(message, color)
    broadcastToAll(message, color)
end

function UIAdapter.getPlayerName(player)
    return Player[player].steam_name
end

function UIAdapter.log(message, messagePlayers)
    log(message)
    if messagePlayers then
        UIAdapter.messagePlayers(message)
    end
end

function UIAdapter.enableFriendliesOnly(exceptTheseIDs)
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

function UIAdapter.enableEnemiesInRange(units, range)
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

function UIAdapter.getAndEnableSquadOnly(squad)
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

function UIAdapter.getSquad(squad, highlightOn)
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

function UIAdapter.resetAllUnits()
    for obj in getAllObjects() do
        obj.interactable = true
        obj.highlightOff()
    end
end

function UIAdapter.clearAllUnits()
    for obj in getAllObjects() do
        obj.interactable = false
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

function UIAdapter.resetObject(objId, highlightOff)
    getObjectFromGUID(objId):resetUnit()
end

function UIAdapter.getObjectByID(id)
    return getObjectFromGUID(id)
end

function UIAdapter.getShootingWeapons(units)
    local weapons = {}
    for unit in Units do
        for weapon in unit:getShootingWeapons() do
            weapons[weapon.name] = weapon
        end
    end
    return weapons
end
