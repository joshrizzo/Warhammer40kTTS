function Object:getOwner()
    return string.match(self.getDescription(), "[(.+)]")
end

function Object:isFriendly(player)
    return self:getOwner() == Game.player.current
end

function Object:isEnemy()
    return not self:isFriendly()
end

function Object:getStat(stat)
    return tonumber(string.match(self.description, stat .. '(%d+)%s'))
end

function onObjectPickUp(player, obj)
    if Game.pickup then
        Game.pickup(player, obj)
    else
        obj:release()
    end
end

function onObjectDrop(player, obj)
    if Game.release then
        Game.release(player, obj)
    else
        obj:release()
    end
end
