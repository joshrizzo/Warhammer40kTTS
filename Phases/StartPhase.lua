StartPhase = {}

function StartPhase:start()
    StartPhase.nextPhase = MovePhase

    Game.log(Events.start, 'Beginning ' .. Game.players.current .. '\'s Turn ' .. Game.turn .. '.', true)

    return setmetatable({}, {__index = StartPhase})
end