function Units.EnableFriendliesOnly()
    for obj in getAllObjects() do
        obj.setLocked(obj:isEnemy())
        if obj:isFriendly() then
            obj.highlightOn({0, 255, 0})
        else
            obj.highlightOff()
        end
    end
end
