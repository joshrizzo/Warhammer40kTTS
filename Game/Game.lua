Game = {
    players = {
        starting = nil,
        current = nil
    },
    turn = 0,
    phase = StartPhase,
    log = nil
}

function Game.nextPhase()
    Game.phase = Game.phase.nextPhase:start()
end

function Game.nextTurn(player)
    Game.players = {
        starting = current or player,
        current = player
    }
    if player == Game.current then
        Game.turn = Game.turn + 1
    end
    Game.phase = StartPhase:start()
end

function Game.logEvent(event, message, messagePlayers)
    table.insert(Game.log, {time = os.date(), event = event, message = message})
    UIAdapter.log(message, messagePlayers)
end
