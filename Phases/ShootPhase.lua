ShootPhase = {}

function ShootPhase.start()
    ShootPhase.unitsFired = {}
    ShootPhase.reset()

    UIAdapter.pickup = ShootPhase.pickup
    UIAdapter.release = nil -- Release is not needed for non-movement phases.
end

function ShootPhase.reset()
    ShootPhase.range = nil
    ShootPhase.T = nil
    ShootPhase.SV = nil
    ShootPhase.IS = nil
    ShootPhase.IW = nil
    ShootPhase.weapon = nil
    ShootPhase.selectedUnits = nil
    ShootPhase.selectedModel = nil
    ShootPhase.targetUnit = nil
    ShootPhase.weaponsFired = {}

    UIAdapter.enableFriendliesOnly(ShootPhase.unitsFired)
    UIAdapter.messagePlayers("Select a unit to fire with.")
end

function ShootPhase.pickup(player, obj)
    -- Only the active player can shoot.
    if Game.players.current ~= player then
        UIAdapter.messagePlayers("Only the active player may shoot thier units.")
    end

    -- Always release in the shooting phase
    obj:release()

    -- Player has selected a FRIENDLY unit to shoot WITH.
    if not ShootPhase.selectedUnits then
        ShootPhase.shooterSelected(obj)
    else -- Player has selected an ENEMY unit to shoot AT.
        ShootPhase.targetSelected(obj)
    end
end

function ShootPhase.shooterSelected(obj)
    UIAdapter.resetAllUnits()
    ShootPhase.selectedUnits = obj:getSquadMembers(true)
    ShootPhase.selectedModel = obj

    local weapons = UIAdapter.getShootingWeapons(ShootPhase.selectedUnits)
    for weapon in weapons do
        ShootPhase.selectedModel:createCustomButton(weapon.name, self, 'shootWeapon', weapon)
    end
    ShootPhase.selectedModel:createCustomButton('Unit Done', self, 'unitDone')
end

function ShootPhase.shootWeapon(button)
    ShootPhase.weapon = button.function_params.weapon
    UIAdapter.enableEnemiesInRange(ShootPhase.selectedUnits, ShootPhase.weapon.range)
    UIAdapter.messagePlayers('Select a target unit.')
end

function ShootPhase.unitDone()
    for unit in ShootPhase.selectedUnits do
        ShootPhase.unitsFired[unit:getID()] = true
    end
    ShootPhase.reset()
    ShootPhase.selectedModel:clearControls()
end

function ShootPhase.targetSelected(obj)
    -- Target unit stats.
    ShootPhase.targetUnit = obj
    ShootPhase.T = obj:getStat(Stats.T)
    ShootPhase.SV = obj:getStat(Stats.SV)
    ShootPhase.IS = obj:getStat(Stats.IS)
    ShootPhase.IW = obj:getStat(Stats.IW)

    -- Calculate closest range between units
    for unit in ShootPhase.selectedUnits do
        local range = unit:rangeTo(obj)
        if not ShootPhase.range then
            ShootPhase.range = range
        elseif range < ShootPhase.range then
            ShootPhase.range = range
        end
    end

    -- Modifiers.
    local unitString = nil
    for unit in ShootPhase.selectedUnits do
        unit:applyModifiers(Events.shoot, ShootPhase) -- Triggering the shoot event, since we are already in the loop.
        unit:triggerEvent(Events.shoot)
        local unitName = unit:getName()
        if not unitString then
            unitString = unitName
        else
            unitString = unitString .. ', ' .. unitName
        end
    end
    ShootPhase.targetUnit:applyModifiers(Events.shoot, ShootPhase)
    Stats.applyModifiers(Events.shoot, ShootPhase, ShootPhase.weapon.mods)

    -- Resolve damage.
    UIAdapter.log(Events.shoot, unitString .. ' shot at ' .. ShootPhase.targetUnit:getName() .. '.', true)
    Combat.resolveShooting(ShootPhase) -- Call after main log message so the combat output displays after.
    ShootPhase.weaponsFired[ShootPhase.weapon.name] = ShootPhase.weapon.count
    ShootPhase.targetUnit:triggerEvent(Events.shotAt) -- Trigger this AFTER the unit has recieved damage.

    -- Loop back to selecting a weapon, until they click the "Unit Done" button.
    ShootPhase.shooterSelected(ShootPhase.selectedModel)
end
