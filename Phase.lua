Phase = {
    phaseSwitch = {
        [0] = Phase.move,
        [1] = Phase.psyker,
        [2] = Phase.shoot,
        [3] = Phase.charge,
        [4] = Phase.fight,
        [5] = Phase.moral
    }
}

function Phase.begin(phaseNumber)
    Phase.phaseSwitch[phaseNumber]()
end

function Phase.move()
    Units.enableFriendliesOnly()
    Game.pickup = Move.pickup
end

function Phase.psyker()
    Units.enableFriendliesOnly()
end

function Phase.shoot()
    Units.enableFriendliesOnly()
end

function Phase.charge()
    Units.enableFriendliesOnly()
end

function Phase.fight()
end

function Phase.moral()
end
