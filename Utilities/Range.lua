function Range.distance(v1, v2)
    return math.abs(math.sqrt((((v2.x - v1.x) ^ 2) + ((v2.y - v1.y) ^ 2) + ((v2.z - v1.z) ^ 2))))
end

function Range.spawnIndicator( location, color, size )
    local rangeIndicator =
        spawnObject(
        {
            type = "Custom_Model",
            position = obj.getPosition()
        }
    )
    rangeIndicator.setCustomObject(
        {
            mesh = "https://my.mixtape.moe/xqbmrf.obj",
            collider = "http://pastebin.com/raw.php?i=ahfaXzUd"
        }
    )
    rangeIndicator.setColorTint(color)
    rangeIndicator.scale(size / 10) -- The texture is 10" wide at scale.

    return rangeIndicator
end
