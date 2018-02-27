Unit = {}

function Unit:new(obj)
    local new = setmetatable({}, {__index = Unit})

    return new
end



function Unit:getOwner()
    return string.match(self.getDescription(), "[(.+)]")
end

function Unit:isFriendly(player)
    return self:getOwner() == Game.player.current
end

function Unit:isEnemy()
    return not self:isFriendly()
end

function Unit:getStat(stat)
    return tonumber(string.match(self.description, stat .. '(%d+)%s'))
end
