MovePhase = {}

--TODO: Build in fallback.
function MovePhase:start()
    self:reset()
    self.unitsMoved = {}
    self.nextPhase = ShootPhase

    UIAdapter.messagePlayers("Select a unit to move.")

    return setmetatable({}, {__index = MovePhase})
end

function MovePhase:reset()
    self.M = nil
    self.squadCoherency = 2
    self.movementIndicator = nil
    self.advanceMove = nil
    self.advanceIndicator = nil
    self.objectInMotion = nil
    self.invalidMove = false
    self.squadMoving = nil
    self.squadCoherencyIndicators = {}

    UnitManager.enableFriendliesOnly(self.unitsMoved)
end

-- Setup the selected unit for a movement, and cleanup the last unit moved, if needed.
function MovePhase:pickup(player, obj)
    -- Only active player can move
    if Game.players.current ~= player then
        UIAdapter.messagePlayers("Only the active player may move units.")
        obj:release()
        return
    end

    -- The last move was invalid for some reason.
    if self.invalidMove then
        UIAdapter.messagePlayers("You must place the previous unit in a valid location first.")
        obj:release()
        return
    end

    -- Cleanup the last unit, if needed.
    if self.objectInMotion and self.objectInMotion ~= obj:getID() then
        self:cleanupLastObj()
    end

    self:setupObj(obj)
end

-- Check that the move was valid.
function MovePhase:release(player, obj)
    -- Not in movement range.
    if obj:rangeTo(self.startingLocation) > self.advanceMove then
        UIAdapter.messagePlayers("You must place this unit within its specified movement range.")
        self.invalidMove = true
        return
    end

    -- Not in squad coherency.
    if self.squadMoving and not obj:inSquadCoherency() then
        UIAdapter.messagePlayers("You must place this unit within squad coherency.")
        self.invalidMove = true
        return
    end
end

function MovePhase:cleanupLastObj()
    -- Clean up indicators.
    self.moveIndicator.destruct()
    self.advanceIndicator.destruct()

    -- Trigger unit events.
    local lastObj = UnitManager.getObjectByID(self.objectInMotion)
    local moveRange = lastObj:rangeTo(self.startingLocation)
    local advanceMove = moveRange > self.M
    lastObj:triggerEvent(advanceMove and Events.advance or Events.move)
    self.unitsMoved[self.objectInMotion] = true

    -- Squad cleanup.
    if self.squadMoving then
        self.squadMoving[self.objectInMotion] = nil

        -- Squad still has members.
        if next(self.squadMoving) ~= nil then
            table.insert(
                self.squadCoherencyIndicators,
                UIAdapter.spawnIndicator(currentLocation, Colors.green, self.squadCoherency)
            )
            return
        end

        -- Squad done moving.
        for indicator in self.squadCoherencyIndicators do
            indicator.destruct()
        end
    end

    Game.log(Events.move, lastObj:getName() .. (advanceMove and " advanced " or " moved ") .. moveRange .. " inches.")
    self:reset()
end

function MovePhase:setupObj(obj)
    -- Squad setup.
    local squad = obj:getSquad()
    if squad and not self.squadMoving then
        self.squadMoving = UnitManager.getAndEnableSquadOnly(squad)
    end

    -- Moving object setup.
    self.objectInMotion = obj:getID()
    self.startingLocation = obj:getLocation()
    self.invalidMove = false

    -- Stat with modifiers.
    self.M = obj:getStat(Stats.M)
    self.d6 = Combat.rollD6()
    obj:applyModifiers(Events.move, self)
    obj:applyModifiers(Events.advance, self)
    self.advanceMove = self.M + self.d6

    -- Movement indicators.
    self.moveIndicator = UIAdapter.spawnIndicator(currentLocation, Colors.green, self.M)
    self.advanceIndicator = UIAdapter.spawnIndicator(currentLocation, Colors.yellow, self.advanceMove)
end
