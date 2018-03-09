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
    self.selectedUnit = nil
    self.targetUnit = nil
    self.weaponsFired = {}

    UnitManager.enableFriendliesOnly(self.unitsFired)
    UIAdapter.messagePlayers("Select a unit to fire with.")
end

function ShootPhase:pickup(player, obj)
    local unit = Unit.adaptFrom(obj)
    if not unit then return end

    -- Only the active player can shoot.
    if Game.players.current ~= player then
        UIAdapter.messagePlayers("Only the active player may shoot thier units.")
    end

    -- Always release in the shooting phase
    unit:release()

    if not self.selectedUnit then 
        -- Player has selected a FRIENDLY unit to shoot WITH.
        self:shooterSelected(unit)
    else 
        -- Player has selected an ENEMY unit to shoot AT.
        self:targetSelected(unit)
    end
end

function ShootPhase:shooterSelected(unit)
    UnitManager.resetAllUnits()
    UnitManager:getSquad(unit.name, true)
    self.selectedUnit = unit

    for weapon in unit:getShootingWeapons() do
        self.selectedUnit:createCustomButton(weapon.name, self, 'shootWeapon', weapon)
    end
    self.selectedUnit:createCustomButton('Unit Done', self, 'unitDone')
end

function ShootPhase:shootWeapon(button)
    self.weapon = button.function_params.weapon
    UnitManager.enableEnemiesInRange(self.selectedUnits, self.weapon.range)
    UIAdapter.messagePlayers('Select a target unit.')
end

function ShootPhase:unitDone()
    for unit in self.selectedUnit.squad do
        self.unitsFired[unit:getID()] = true
    end
    self:reset()
    self.selectedUnit:clearControls()
end

function ShootPhase:targetSelected(unit)
    -- Target unit stats.
    self.targetUnit = unit

    -- Calculate closest range between units
    for u1 in self.selectedUnit.squad do
        for u2 in self.targetUnit.squad do
            local range = u1:rangeTo(u2)
            if not self.range or range < self.range then
                self.range = range
            end
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
    self:shooterSelected(self.selectedUnit)
end