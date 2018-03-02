Game = {
    players = {
        starting = nil,
        current = nil
    },
    turn = 0,
    phase = 0,
    log = nil
}

Phases = {
    [0] = MovePhase,
    [1] = PsykerPhase,
    [2] = ShootPhase,
    [3] = ChargePhase,
    [4] = FightPhase,
    [5] = MoralePhase,
    [6] = EndPhase
}

function Game.nextPhase()
    if (Game.phase < (table.getn(Phases) - 1)) then
        Game.phase = Game.phase + 1
    end
    Phases[Game.phase].start()
end

function Game.nextTurn()
    Game.turn = Game.turn + 1
    Game.phase = 0
    Phases[Game.phase].start()
end