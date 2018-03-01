MovePhase = {
    unitsMoved = {}
}

function MovePhase.start()
    MovePhase.M = nil;
    MovePhase.movementIndicator = nil;
    MovePhase.advanceMove = nil;
    MovePhase.advanceIndicator = nil;
    MovePhase.objectInMotion = nil;
    MovePhase.invalidMove = false;
    MovePhase.squadMoving = nil;

    UIAdapter.enableFriendliesOnly(MovePhase.unitsMoved)
    UIAdapter.messagePlayers('Select a unit to move.')
    UIAdapter.pickup = MovePhase.pickup
    UIAdapter.release = MovePhase.release
    UIAdapter.turnStart = MovePhase.start
    UIAdapter.pickup = MovePhase.done
end

function MovePhase.done()
    MovePhase.unitsMoved = {}
end

function MovePhase.pickup(player, obj)
    if Game.players.current ~= player then
        UIAdapter.messagePlayers('Only the active player may move units.')
        obj:release()
        return
    end

    local objID = obj:getID()
    if MovePhase.objectInMotion then
        if MovePhase.objectInMotion == objID then
            return
        elseif MovePhase.invalidMove then
            UIAdapter.messagePlayers('You must place the previous unit in a valid location first.')
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

    local squad = obj:getSquad()
    if squad and not MovePhase.squadMoving then
        MovePhase.squadMoving = UIAdapter.getAndEnableSquadOnly(squad)
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
    local objID = obj:getID()
    if objID ~= MovePhase.objectInMotion then
        obj:release()
        return
    end
    
    if obj:rangeTo(MovePhase.startingLocation) > MovePhase.advanceMove then
        UIAdapter.messagePlayers('You must place this unit within its specified movement range.')
        MovePhase.invalidMove = true
        return
    end
    
    -- Valid single unit move
    if not MovePhase.squadMoving then
        MovePhase.unitsMoved[MovePhase.objectInMotion] = true
        MovePhase.start()
        return 
    end
    
    if not obj:inSquadCoherency() then
        UIAdapter.messagePlayers('You must place this unit within squad coherency.')
        MovePhase.invalidMove = true
        return
    end

    -- Valid squad move
    MovePhase.unitsMoved[MovePhase.objectInMotion] = true
    MovePhase.squadMoving[objID] = nil
    if next(MovePhase.squadMoving) == nil then
        -- Squad complete
        MovePhase.squadMoving = nil
        MovePhase.start()
    end
end
