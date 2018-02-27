MovePhase = {
    actions = {}
}

function MovePhase.start()
    Units.enableFriendliesOnly()
end

function MovePhase.pickup(player, obj)
    local currentLocation = obj.getPosition()
    if player ~= Game.player.current then
        obj.setPosition(currentLocation)
        return
    end
    local movement = obj:getStat(Stats.M)
    MovePhase.startingLocation = currentLocation
    MovePhase.moveIndicator = Range.spawnIndicator(currentLocation, Colors.green, movement)
    MovePhase.advanceIndicator = Range.spawnIndicator(currentLocation, Colors.yellow, movement + math.random(6))
    MovePhase.M = M
end

function MovePhase.place(player, obj)
    if player ~= Game.player.current or Range.distance(MovePhase.startingLocation, obj.getPosition()) > Move.M then
        obj.setLocation(MovePhase.startingLocation)
    else
        obj.setLocked(true)
        obj.highlightOff()
    end
    MovePhase.moveIndicator.destruct()
    MovePhase.advanceIndicator.destruct()
end