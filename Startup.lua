function onLoad()
    self:createCustomButton('Start Game', self, 'startGame')
end

function startGame(button, player)
    button.destruct()
    self:createCustomButton('Next Phase', Game, 'nextPhase')
    Game.nextPhase()
end

function onObjectPickUp(player, obj)
    obj.setVar('startingLocation', obj.getPosition())
    if UIAdapter.pickup then
        UIAdapter.pickup(player, obj)
    else
        obj:release()
    end
end

function onObjectDrop(player, obj)
    if UIAdapter.release then
        UIAdapter.release(player, obj)
    else
        obj:release()
    end
end

function onPlayerTurnStart(startingPlayer, previousPlayer)
    if UIAdapter.turnStart then
        UIAdapter.turnStart()
    end        
end