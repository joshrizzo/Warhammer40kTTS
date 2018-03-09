EndPhase = {}

function EndPhase:start()
    EndPhase.nextPhase = EndPhase

    UnitManager.resetAllUnits(true)
    Game.log(Events.ending, 'Ending ' .. UIAdapter.getPlayerName(Game.players.current) .. '\'s Turn ' .. Game.turn .. '.', true)
    UIAdapter.messagePlayers('Please click "End Turn".')

    return setmetatable({}, {__index = EndPhase})
end