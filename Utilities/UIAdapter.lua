UIAdapter = {
    pickup = nil,
    release = nil,
    turnStart = nil
}

function UIAdapter.messagePlayers(message, color)
    broadcastToAll(message, color)
end

function UIAdapter.enableFriendliesOnly()
    for obj in getAllObjects() do
        obj.setLocked(obj:isEnemy())

        if obj:isFriendly() then
            obj.highlightOn({0, 255, 0})
        else
            obj.highlightOff()
        end
    end
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