MovePhase = {}

function MovePhase.start()
    MovePhase.reset()
    MovePhase.unitsMoved = {}

    UIAdapter.messagePlayers("Select a unit to move.")
    UIAdapter.pickup = MovePhase.pickup
    UIAdapter.release = MovePhase.release
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

    UIAdapter.enableFriendliesOnly(MovePhase.unitsMoved)
end

-- Setup the selected unit for a movement, and cleanup the last unit moved, if needed.
function MovePhase.pickup(player, obj)
    -- Only active player can move
    if Game.players.current ~= player then
        UIAdapter.messagePlayers("Only the active player may move units.")
        obj:release()
        return
    end

    -- The last move was invalid for some reason.
    if MovePhase.invalidMove then
        UIAdapter.messagePlayers("You must place the previous unit in a valid location first.")
        obj:release()
        return
    end

    -- Cleanup the last unit, if needed.
    if MovePhase.objectInMotion and MovePhase.objectInMotion ~= obj:getID() then
        MovePhase.cleanupLastObj()
    end

    MovePhase.setupObj(obj)
end

-- Check that the move was valid.
function MovePhase.release(player, obj)
    -- Not in movement range.
    if obj:rangeTo(MovePhase.startingLocation) > MovePhase.advanceMove then
        UIAdapter.messagePlayers("You must place this unit within its specified movement range.")
        MovePhase.invalidMove = true
        return
    end

    -- Not in squad coherency.
    if MovePhase.squadMoving and not obj:inSquadCoherency() then
        UIAdapter.messagePlayers("You must place this unit within squad coherency.")
        MovePhase.invalidMove = true
        return
    end
end

function MovePhase.cleanupLastObj()
    -- Clean up indicators.
    MovePhase.moveIndicator.destruct()
    MovePhase.advanceIndicator.destruct()

    -- Trigger unit events.
    local lastObj = UIAdapter.getObjectByID(MovePhase.objectInMotion)
    local moveRange = lastObj:rangeTo(MovePhase.startingLocation)
    local advanceMove = moveRange > MovePhase.M
    lastObj:triggerEvent(advanceMove and Events.advance or Events.move)
    MovePhase.unitsMoved[MovePhase.objectInMotion] = true

    -- Squad cleanup.
    if MovePhase.squadMoving then
        MovePhase.squadMoving[MovePhase.objectInMotion] = nil

        -- Squad still has members.
        if next(MovePhase.squadMoving) ~= nil then
            table.insert(
                MovePhase.squadCoherencyIndicators,
                UIAdapter.spawnIndicator(currentLocation, Colors.green, MovePhase.squadCoherency)
            )
            return
        end

        -- Squad done moving.
        for indicator in MovePhase.squadCoherencyIndicators do
            indicator.destruct()
        end
    end

    UIAdapter.log(Events.move, lastObj:getName() .. (advanceMove and " advanced " or " moved ") .. moveRange .. " inches.")
    MovePhase.reset()
end

function MovePhase.setupObj(obj)
    -- Squad setup.
    local squad = obj:getSquad()
    if squad and not MovePhase.squadMoving then
        MovePhase.squadMoving = UIAdapter.getAndEnableSquadOnly(squad)
    end

    -- Moving object setup.
    MovePhase.objectInMotion = obj:getID()
    MovePhase.startingLocation = obj:getLocation()
    MovePhase.invalidMove = false

    -- Stat with modifiers.
    MovePhase.M = obj:getStat(Stats.M)
    MovePhase.d6 = math.random(6)
    obj:applyModifiers(Events.move, MovePhase)
    obj:applyModifiers(Events.advance, MovePhase)
    MovePhase.advanceMove = MovePhase.M + MovePhase.d6

    -- Movement indicators.
    MovePhase.moveIndicator = UIAdapter.spawnIndicator(currentLocation, Colors.green, MovePhase.M)
    MovePhase.advanceIndicator = UIAdapter.spawnIndicator(currentLocation, Colors.yellow, MovePhase.advanceMove)
end
