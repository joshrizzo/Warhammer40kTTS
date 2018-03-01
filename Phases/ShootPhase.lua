ShootPhase = {
    unitsFired = {}
}

function ShootPhase.start()
    ShootPhase.range = nil
    ShootPhase.T = nil
    ShootPhase.SV = nil
    ShootPhase.IS = nil
    ShootPhase.IW = nil
    ShootPhase.weapon = nil
    ShootPhase.selectedUnits = nil
    ShootPhase.targetUnit = nil
    ShootPhase.rangeIndicator = nil
    ShootPhase.weaponsFired = {}

    UIAdapter.enableFriendliesOnly(ShootPhase.unitsFired)
    UIAdapter.messagePlayers("Select a unit to fire with.")
end

function ShootPhase.done()
    ShootPhase.unitsFired = {}
end

function ShootPhase.pickup(player, obj)
    if Game.players.current ~= player then
        UIAdapter.messagePlayers("Only the active player may shoot thier units.")
    end
    obj:release()

    if not ShootPhase.selectedUnits then
        ShootPhase.selectedUnits = obj:getSquadMembers()
        --TODO: make buttons to shoot different weapons
    else
        ShootPhase.targetUnit = obj
        ShootPhase.T = obj:getStat(Stats.T)
        ShootPhase.SV = obj:getStat(Stats.SV)
        ShootPhase.IS = obj:getStat(Stats.IS)
        ShootPhase.IW = obj:getStat(Stats.IW)

        ShootPhase.range = 0
        for unit in ShootPhase.selectedUnits do
            local range = unit:rangeTo(obj)
            if range > ShootPhase.range then
                ShootPhase.range = range
            end
        end

        for unit in ShootPhase.selectedUnits do
            unit:applyModifiers(Events.shoot, ShootPhase)
        end

        ShootPhase.targetUnit:applyModifiers(Events.shoot, ShootPhase)
        Combat.resolveShooting(ShootPhase)
        ShootPhase.weaponsFired[ShootPhase.weapon.name] = ShootPhase.weapon.count
    end
    UIAdapter.resetAllUnits()
end

function ShootPhase.shootWeapon(weapon)
    ShootPhase.weapon = weapon
    Stats.applyModifiers(Events.shoot, ShootPhase, ShootPhase.weapon.mods)
    ShootPhase.rangeIndicator = UIAdapter.spawnIndicator(obj:getLocation(), Colors.green, ShootPhase.weapon.range)
    UIAdapter.enableEnemiesInRange(obj:getLocation(), ShootPhase.weapon.range) --TODO: replace obj:getLocation() with the location of the CLOSEST squad member.
end

function ShootPhase.unitDone()
    for unit in ShootPhase.selectedUnits do
        table.insert(ShootPhase.unitsFired, unit:getID())
    end
    ShootPhase.start()
end

function ShootPhase.release(player, obj)
    -- Release is not needed for non-movement phases.
end
