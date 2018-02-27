Game = {
    startingPlayer = nil,
    turn = 0,
    phase = nil,
    phaseFactory = nil
}

function Game:new(uiAdapter, phaseFactory)
    local new = setmetatable({
        phaseFactory = phaseFactory
    }, {__index = self})
    uiAdapter.game = new;
    return new
end

function Game:nextTurn(player)
    if not self.startingPlayer then
        self.startingPlayer = player
    end
    if self.startingPlayer == player then
        self.turn = self.turn + 1
    end
    self:nextPhase(player)
end

function Game:nextPhase(player)
    self.phase = self.phaseFactory:nextPhase(self.phase, player)
end
