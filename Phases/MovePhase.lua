MovePhase = {
    movement = nil,
    movementIndicator = nil,
    advanceMove = nil,
    advanceIndicator = nil,
    objectInMotion = nil
}

function MovePhase.start() 
    UIAdapter.enableFriendliesOnly()
end

function MovePhase.pickup(player, obj)
    if Game.players.current ~= player then
        UIAdapter.messagePlayers("Only the active player may move units.")
        obj:release()
    end

    local objID = obj.getGUID()
    if MovePhase.objectInMotion then
        MovePhase.moveIndicator.destruct()
        MovePhase.advanceIndicator.destruct()
        UIAdapter.resetObject(MovePhase.objectInMotion)

        if MovePhase.objectInMotion == objID then 
            return
        end
    end

    MovePhase.objectInMotion = objID
    MovePhase.startingLocation = obj.getPosition()

    MovePhase.movement = obj:getStat(Stats.M)
    MovePhase.moveIndicator = UIAdapter.spawnIndicator(currentLocation, Colors.green, MovePhase.movement)

    MovePhase.advanceMove = MovePhase.movement + math.random(6) + obj:GetModifiers(Events.move)
    MovePhase.advanceIndicator = UIAdapter.spawnIndicator(currentLocation, Colors.yellow, MovePhase.advanceMove)
end

function MovePhase.release(player, obj)
    if Range.distance(MovePhase.startingLocation, obj.getPosition()) > MovePhase.advanceMove then
        UIAdapter.messagePlayers("You must place the unit within its specified movement or advance range")
    end
end
