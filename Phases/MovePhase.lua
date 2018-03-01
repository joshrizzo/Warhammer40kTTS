MovePhase = {
    M = nil,
    movementIndicator = nil,
    advanceMove = nil,
    advanceIndicator = nil,
    objectInMotion = nil,
    invalidMove = false,
    squadsMoved = {}
}

function MovePhase.start()
    UIAdapter.enableFriendliesOnly()
end

function MovePhase.pickup(player, obj)
    if Game.players.current ~= player then
        UIAdapter.messagePlayers("Only the active player may move units.")
        obj:release()
        return
    end

    local objID = obj:getID()
    if MovePhase.objectInMotion then
        if MovePhase.objectInMotion == objID then
            return
        elseif MovePhase.invalidMove then
            UIAdapter.messagePlayers("You must place the previous unit in a valid location first.")
            obj:release()
            return
        end

        MovePhase.moveIndicator.destruct()
        MovePhase.advanceIndicator.destruct()

        local lastObj = UIAdapter.getObjectByID(MovePhase.objectInMotion)
        if lastObj:rangeTo(MovePhase.startingLocation) > MovePhase.M then
            lastObj:triggerEvent(Events.advance)
        else
            lastObj:triggerEvent(Events.move)
        end
        lastObj:resetUnit(true)
    end

    MovePhase.objectInMotion = objID
    MovePhase.startingLocation = obj:getLocation()
    MovePhase.invalidMove = false
    MovePhase.d6 = math.random(6)

    MovePhase.M = obj:getStat(Stats.M)
    obj:applyModifiers(Events.move, MovePhase)
    MovePhase.moveIndicator = UIAdapter.spawnIndicator(currentLocation, Colors.green, MovePhase.M)

    local advanceMods = obj:applyModifiers(Events.advance, MovePhase)
    MovePhase.advanceMove = advanceMods.M + advanceMods.d6
    MovePhase.advanceIndicator = UIAdapter.spawnIndicator(currentLocation, Colors.yellow, MovePhase.advanceMove)
end

function MovePhase.release(player, obj)
    if obj:getID() ~= MovePhase.objectInMotion then
        obj:release()
    else
        if obj:rangeTo(MovePhase.startingLocation) > MovePhase.advanceMove then
            UIAdapter.messagePlayers("You must place this unit within its specified movement range.")
        else
            local squad = obj:getSquad()
            if squad then
                if MovePhase.squadsMoved[squad] and not obj:inSquadCoherency() then
                    UIAdapter.messagePlayers("You must place this unit within squad coherency.")
                else
                    table.insert(MovePhase.squadsMoved, squad)
                end
            end
        end
        MovePhase.invalidMove = true
    end
end
