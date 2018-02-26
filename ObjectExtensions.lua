function Object:isFriendly(player)
    player = player or Game.player.current
    return string.match(self.getDescription(), "[" .. player .. "]") ~= nil
end

function Object:isEnemy()
    return not self.isFriendly()
end

function Object:getStat(stat)
    return string.match(self.description, stat .. '\d\d\s')
end

function Object:release()
    self.setPosition(self.getPosition())
end

function Object:placeMovementRange()
    local M = self:getStat(Stats.M)
    spawnObject({
        scale = { M, M, M }
        type = ''
    })
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
