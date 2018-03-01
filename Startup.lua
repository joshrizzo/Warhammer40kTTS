
function onLoad()
    UIAdapter.createCustomButton("Start Game", startGame, 1, 1)
end

function startGame()
    Phase[UIAdapter.getPhase()].start()
end

function onObjectPickUp(player, obj)
    obj.setVar("startingLocation", obj.getPosition())
    if UIAdapter.pickup then
        UIAdapter.pickup(player, obj)
    else
        UIAdapter.releaseObject(obj)
    end
end

function onObjectDrop(player, obj)
    if UIAdapter.release then
        UIAdapter.release(player, obj)
    else
        UIAdapter.releaseObject(obj)
    end
end

function onPlayerTurnStart(startingPlayer, previousPlayer)
    Game.players = {
        starting = Game.players.starting or startingPlayer,
        current = startingPlayer
    }
    if UIAdapter.turnStart then
        UIAdapter.turnStart()
    end        
end