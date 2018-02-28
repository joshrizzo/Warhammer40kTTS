function Object:getOwner()
    return string.match(self.getDescription(), '[(.+)]')
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

function Object:getModifiers(event)
    return string.match(self.getDescription(), '')
end

function Object:rangeTo(vector)
    local v1 = self.getPosition()
    local v2 = vector
    return math.abs(math.sqrt((((v2.x - v1.x) ^ 2) + ((v2.y - v1.y) ^ 2) + ((v2.z - v1.z) ^ 2))))
end

function Object:release()
    self.setLocation(self.getLocation())
end