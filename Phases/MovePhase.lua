MovePhase = {}
MovePhase.__index = PhaseBase

function MovePhase:new(player, uiAdapter)
    uiAdapter:enableFriendliesOnly()
    return setmetatable(PhaseBase:new(player, uiAdapter), {__index = self})
end

function MovePhase:pickup(player, obj)
    self.startingLocation = obj.getPosition()
    if self.player ~= player then
        self.uiAdapter:messagePlayers("Only the active player may move units.")
        obj.setPosition(self.startingLocation)
    end

    local objID = obj.getGUID()
    if objID ~= self.objectInMotion then
        self.moveIndicator.destruct()
        self.advanceIndicator.destruct()

        --TODO: Move to UIAdapter
        local lastObj = getObjectFromGUID(self.objId)
        lastObj.setLocked(true)
        lastObj.highlightOff(self.playerMoving[player])
    end
    self.objectInMotion = objID

    self.movement = obj:getStat(Stats.M)
    self.moveIndicator = self.UIAdapter.spawnIndicator(currentLocation, Colors.green, self.movement)

    self.advanceMove = self.movement + math.random(6) --TODO: apply modifiers
    self.advanceIndicator = self.UIAdapter.spawnIndicator(currentLocation, Colors.yellow, self.advanceMove)
end

function MovePhase:release(player, obj)
    if Range.distance(self.startingLocation, obj.getPosition()) > self.advanceMove then
        self.uiAdapter.messagePlayers("You must place the unit within its specified movement or advance range")
    end
end
