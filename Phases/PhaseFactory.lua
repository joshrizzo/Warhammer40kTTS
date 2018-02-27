PhaseFactory = {
    phases = {
        [0] = MovePhase,
        [1] = PsykerPhase,
        [2] = ShootPhase,
        [3] = ChargePhase,
        [4] = FightPhase,
        [5] = MoralePhase,
        [6] = EndPhase
    },
    uiAdapter = nil
}

function PhaseFactory:new(uiAdapter)
    return setmetatable({uiAdapter = uiAdapter}, {__index = self})
end

function PhaseFactory:nextPhase(lastPhase, player)
    local nextPhaseNum = 0
    if lastPhase then
        nextPhaseNum = lastPhase.number + 1
        lastPhase:complete()
    end

    local nextPhase = self.phases[nextPhaseNum]
    if not nextPhase then return lastPhase end

    return nextPhase:new(player, uiAdapter)
end