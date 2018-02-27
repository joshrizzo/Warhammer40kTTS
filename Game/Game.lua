Game = {
    player = {
        starting = "",
        current = ""
    },
    turn = 0,
    phase = nil,
    actions = {},
    pickup = nil,
    release = nil
}

function Game.nextTurn(player)
    if Game.player.starting == "" then
        Game.player.starting = player
    end
    if Game.player.starting == player then
        Game.turn = Game.turn + 1
    end
    Game.nextPhase()
end

function Game.nextPhase()
    if Game.phase == 5 or Game.phase == nil then
        Game.phase = 0
    else
        Game.phase = Game.phase + 1
    end
    Phase.begin(Game.phase)
end
