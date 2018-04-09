function onLoad()
    UIAdapter.messagePlayers('Please setup the turn order and enable turns in the gmae\'s menu.')
    UIAdapter.messagePlayers('If turns are already enabled, open turn options and click Reset.')
end

function onObjectPickUp(player, obj)
    obj.setVar("startingLocation", obj.getPosition())
    if Game.phase.pickup then
        Game.phase:pickup(player, obj)
    else
        obj:release()
    end
end

function onObjectDrop(player, obj)
    if Game.phase.release then
        Game.phase:release(player, obj)
    else
        obj:release()
    end
end

function onPlayerTurnStart(startingPlayer, previousPlayer)
    if Game.turn == 0 then
        createCustomButton("Next Phase", Game, "nextPhase", 2)
    end
    Game:nextTurn(startingPlayer)
end
