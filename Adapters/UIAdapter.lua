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
