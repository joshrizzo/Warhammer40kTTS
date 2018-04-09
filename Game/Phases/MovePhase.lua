MovePhase = {}

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
    self.unitInMotion = nil
    self.invalidMove = false
    self.squadMoving = nil
    self.squadCoherencyIndicators = {}
    self.moveRange = nil
    self.fallingback = false

    UnitManager.enableFriendliesOnly(false, self.unitsMoved)
end

-- Setup the selected unit for a movement, and cleanup the last unit moved, if needed.
function MovePhase:pickup(player, obj)
    local unit = Unit:adaptFrom(obj)
    if not unit then
        return
    end

    -- Only active player can move
    if Game.players.current ~= player then
        UIAdapter.messagePlayers("Only the active player may move units.")
        unit:release()
        return
    end

    -- The last move was invalid for some reason.
    if self.invalidMove then
        UIAdapter.messagePlayers("You must place the previous unit in a valid location first.")
        unit:release()
        return
    end

    -- Cleanup the last unit, if needed.
    if self.unitInMotion and self.unitInMotion:getID() ~= unit:getID() then
        self:cleanupLastUnit()
    end

    self:setupUnit(unit)
end

-- Check that the move was valid.
function MovePhase:release(player, obj)
    local unit = Unit:adaptFrom(obj)
    if not unit then
        return
    end

    -- Not in movement range.
    if unit:rangeTo(self.startingLocation) > self.advanceMove then
        UIAdapter.messagePlayers("You must place this unit within its specified movement range.")
        self.invalidMove = true
        return
    end

    -- Not in squad coherency.
    local coherencyIndicators = self.squadCoherencyIndicators
    if self.squadMoving and #coherencyIndicators > 0 and not unit:inSquadCoherency() then
        UIAdapter.messagePlayers("You must place this unit within squad coherency.")
        self.invalidMove = true
        return
    end
end

function MovePhase:cleanupLastUnit()
    local unit = self.unitInMotion
    self.moveRange = unit:rangeTo(self.startingLocation)
    self.unitsMoved[self.unitInMotion:getID()] = true
    unit:reset(true)

    -- Clean up indicators.
    self.moveIndicator.destruct()
    self.advanceIndicator.destruct()

    -- Trigger unit event.
    local event = nil
    if self.fallingback then
        event = Events.move.fellBack
        unit.applyAttribute(event)
    elseif self.moveRange > self.M then
        event = Events.move.advanced
        unit.applyAttribute(event)
    else
        event = Events.move.moved
    end
    unit:applyModifiers(Events.move.advanced, phase)

    -- Squad cleanup.
    if self.squadMoving then
        self.squadMoving[self.unitInMotion:getID()] = nil

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

    Game:logEvent(Events.move, unit.name .. (advanceMove and " advanced " or " moved ") .. self.moveRange .. " inches.")
    self:reset()
end

function MovePhase:setupUnit(unit)
    -- Squad setup.
    local squad = unit.squad
    if not self.squadMoving then
        self.squadMoving = UnitManager.enableSquadOnly(squad)
    end

    -- Moving unit setup.
    self.unitInMotion = unit
    self.startingLocation = unit:getLocation()
    self.invalidMove = false

    -- Stat with modifiers.
    self.M = unit.M

    -- Advance or fallback.
    if not unit:inCombat() then
        unit:applyModifiers(Events.move.moving, self)

        self.d6 = Combat.rollD6()
        unit:applyModifiers(Events.move.advancing, self)
        self.advanceMove = self.M + self.d6
    else
        self.fallingback = true
        unit:applyModifiers(Events.move.fallingback, self)
    end

    -- Movement indicators.
    self.moveIndicator = UIAdapter.spawnIndicator(currentLocation, Colors.green, self.M)
    self.advanceIndicator = UIAdapter.spawnIndicator(currentLocation, Colors.yellow, self.advanceMove)
end
