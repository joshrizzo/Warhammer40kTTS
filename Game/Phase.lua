Phase = {
    [0] = MovePhase,
    [1] = PsykerPhase,
    [2] = ShootPhase,
    [3] = ChargePhase,
    [4] = FightPhase,
    [5] = MoralePhase
}

function Phase.begin(phaseNumber)
    local phase = Phase[phaseNumber]
    Game.pickup = phase.pickup
    Game.release = phase.release
    Game.actions = phase.actions
    phase.start()
end
