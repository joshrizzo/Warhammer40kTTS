MovePhase = {
    unitsMoved = {}
}

function MovePhase.start()
    MovePhase.reset()
    UIAdapter.enableFriendliesOnly(MovePhase.unitsMoved)
    UIAdapter.messagePlayers("Select a unit to move.")
    UIAdapter.pickup = MovePhase.pickup
    UIAdapter.release = MovePhase.release
    UIAdapter.turnStart = MovePhase.start
    UIAdapter.pickup = MovePhase.done
end

function MovePhase.reset()
    MovePhase.M = nil
    MovePhase.squadCoherency = 2
    MovePhase.movementIndicator = nil
    MovePhase.advanceMove = nil
    MovePhase.advanceIndicator = nil
    MovePhase.objectInMotion = nil
    MovePhase.invalidMove = false
    MovePhase.squadMoving = nil
    MovePhase.squadCoherencyIndicators = {}
end

function MovePhase.done()
    MovePhase.unitsMoved = {}
end

function MovePhase.pickup(player, obj)
    -- Only active player can move
    if Game.players.current ~= player then
        UIAdapter.messagePlayers("Only the active player may move units.")
        obj:release()
        return
    end

    -- If there was an object before this...
    local objID = obj:getID()
    if MovePhase.objectInMotion then
        -- Finish moving the last unit before moving this one.
        if MovePhase.objectInMotion == objID then
            return
        elseif MovePhase.invalidMove then
            UIAdapter.messagePlayers("You must place the previous unit in a valid location first.")
            obj:release()
            return
        end

        -- Clean up last movement.
        MovePhase.moveIndicator.destruct()
        MovePhase.advanceIndicator.destruct()
        for indicator in MovePhase.squadCoherencyIndicators do
            indicator.destruct()
        end

        -- Trigger unit events and reset.
        local lastObj = UIAdapter.getObjectByID(MovePhase.objectInMotion)
        if lastObj:rangeTo(MovePhase.startingLocation) > MovePhase.M then
            lastObj:triggerEvent(Events.advance)
        else
            lastObj:triggerEvent(Events.move)
        end
        lastObj:resetUnit(true)
        MovePhase.unitsMoved[MovePhase.objectInMotion] = true

        -- Squad cleanup
        if MovePhase.squadMoving then
            MovePhase.squadMoving[objID] = nil
            if next(MovePhase.squadMoving) == nil then
                -- Squad complete
                MovePhase.squadMoving = nil
                MovePhase.reset()
            else
                table.insert(
                    MovePhase.squadCoherencyIndicators,
                    UIAdapter.spawnIndicator(currentLocation, Colors.green, MovePhase.squadCoherency)
                )
            end
        end

        -- Reset if we are done with the complete squad, or there wasn't a squad.
        if not MovePhase.squadMoving then
            MovePhase.reset()
        end
    end

    -- Squad setup
    local squad = obj:getSquad()
    if squad and not MovePhase.squadMoving then
        MovePhase.squadMoving = UIAdapter.getAndEnableSquadOnly(squad)
    end

    -- Moving object setup
    MovePhase.objectInMotion = objID
    MovePhase.startingLocation = obj:getLocation()
    MovePhase.invalidMove = false
    MovePhase.d6 = math.random(6)

    -- Movement stat with modifiers and indicators
    MovePhase.M = obj:getStat(Stats.M)
    obj:applyModifiers(Events.move, MovePhase)
    MovePhase.moveIndicator = UIAdapter.spawnIndicator(currentLocation, Colors.green, MovePhase.M)

    -- Advance stat with modifiers and indicators
    local advanceMods = obj:applyModifiers(Events.advance, MovePhase)
    MovePhase.advanceMove = advanceMods.M + advanceMods.d6
    MovePhase.advanceIndicator = UIAdapter.spawnIndicator(currentLocation, Colors.yellow, MovePhase.advanceMove)
end

function MovePhase.release(player, obj)
    -- Fix for picking up multiple objects
    local objID = obj:getID()
    if objID ~= MovePhase.objectInMotion then
        obj:release()
        return
    end

    -- Not in movement range
    if obj:rangeTo(MovePhase.startingLocation) > MovePhase.advanceMove then
        UIAdapter.messagePlayers("You must place this unit within its specified movement range.")
        MovePhase.invalidMove = true
        return
    end

    -- Valid single unit move
    if not MovePhase.squadMoving then
        return
    end

    -- Not in squad coherency
    if not obj:inSquadCoherency() then
        UIAdapter.messagePlayers("You must place this unit within squad coherency.")
        MovePhase.invalidMove = true
        return
    end
end
