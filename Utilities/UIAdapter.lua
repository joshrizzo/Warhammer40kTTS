UIAdapter = {
    game = nil
}

function UIAdapter.new()
    return UIAdapter -- This "class" is a singleton, in this implementation.
end

function UIAdapter:messagePlayers(message, color)
    broadcastToAll(message, color)
end

function UIAdapter:enableFriendliesOnly()
    for obj in getAllObjects() do
        obj.setLocked(obj:isEnemy())
        
        if obj:isFriendly() then
            obj.highlightOn({0, 255, 0})
        else
            obj.highlightOff()
        end
    end
end

function UIAdapter:resetAllUnits()
    for obj in getAllObjects() do
        obj.setLocked(true)
        obj.highlightOff()
    end
end

function UIAdapter:spawnIndicator(location, color, size)
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

-- Event API --

function onObjectPickUp(player, obj)
    if UIAdapter.game.phase.pickup then
        UIAdapter.game.phase:pickup(player, obj)
    else
        obj:release()
    end
end

function onObjectDrop(player, obj)
    if UIAdapter.game.phase.release then
        UIAdapter.game.phase:release(player, obj)
    else
        obj:release()
    end
end

function onPlayerTurnStart(startingPlayer, previousPlayer)
    if UIAdapter.game.turnStart then
        UIAdapter.game:turnStart()
    end        
end