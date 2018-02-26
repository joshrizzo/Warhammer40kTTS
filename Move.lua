function Move.pickup(player, obj)
    if player ~= Game.player.current then
        obj:release()
        return
    end
    obj:placeMovementRange()
end