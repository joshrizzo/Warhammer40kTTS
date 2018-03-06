ShootPhase = {}

--TODO: Build in pistols and close combat.
function ShootPhase:start()
    self.unitsFired = {}
    self.nextPhase = EndPhase
    self.reset()

    return setmetatable({}, {__index = ShootPhase})
end

function ShootPhase:reset()
    self.range = nil
    self.weapon = nil
    self.selectedUnits = nil
    self.selectedModel = nil
    self.targetUnit = nil
    self.weaponsFired = {}

    UnitManager.enableFriendliesOnly(self.unitsFired)
    UIAdapter.messagePlayers("Select a unit to fire with.")
end

function ShootPhase:pickup(player, obj)
    -- Only the active player can shoot.
    if Game.players.current ~= player then
        UIAdapter.messagePlayers("Only the active player may shoot thier units.")
    end

    -- Always release in the shooting phase
    obj:release()

    -- Player has selected a FRIENDLY unit to shoot WITH.
    if not self.selectedUnits then
        self:shooterSelected(obj)
    else -- Player has selected an ENEMY unit to shoot AT.
        self:targetSelected(obj)
    end
end

function ShootPhase:shooterSelected(obj)
    UnitManager.resetAllUnits()
    self.selectedUnits = obj:getSquadMembers(true)
    self.selectedModel = obj

    local weapons = {}
    for unit in Units do
        for weapon in unit:getShootingWeapons() do
            weapons[weapon.name] = weapon
        end
    end
    for weapon in weapons do
        self.selectedModel:createCustomButton(weapon.name, self, 'shootWeapon', weapon)
    end
    self.selectedModel:createCustomButton('Unit Done', self, 'unitDone')
end

function ShootPhase:shootWeapon(button)
    self.weapon = button.function_params.weapon
    UnitManager.enableEnemiesInRange(self.selectedUnits, self.weapon.range)
    UIAdapter.messagePlayers('Select a target unit.')
end

function ShootPhase:unitDone()
    for unit in self.selectedUnits do
        self.unitsFired[unit:getID()] = true
    end
    self:reset()
    self.selectedModel:clearControls()
end

function ShootPhase:targetSelected(obj)
    -- Target unit stats.
    self.targetUnit = obj

    -- Calculate closest range between units
    for unit in self.selectedUnits do
        local range = unit:rangeTo(obj)
        if not self.range then
            self.range = range
        elseif range < self.range then
            self.range = range
        end
    end

    -- Pre-Combat Modifiers.
    for unit in self.selectedUnits do
        unit:applyModifiers(Events.shoot.shooting, self) -- Triggering the shoot event, since we are already in the loop.
    end
    self.targetUnit:applyModifiers(Events.shoot.shotAt, self)
    Stats.applyModifiers(Events.shoot.shooting, self, self.weapon.mods)
    
    -- Roll combat.
    Combat.rollCombat(self)
    self.weaponsFired[self.weapon.name] = self.weapon.count

    -- Post-Combat Modifiers.
    for unit in self.selectedUnits do
        unit:applyModifiers(Events.damage.causedWounds, self) -- Triggering the shoot event, since we are already in the loop.
    end
    self.targetUnit:applyModifiers(Events.damage.wounded, self)
    Stats.applyModifiers(Events.damage.causedWounds, self, self.weapon.mods)

    -- Resolve Damage.
    Combat.resolveDamage(self)

    -- Loop back to selecting a weapon, until they click the "Unit Done" button.
    self:shooterSelected(self.selectedModel)
end