ShootPhase = {}

function ShootPhase:start()
    self.unitsFired = {}
    self.nextPhase = EndPhase
    self.reset()

    return setmetatable({}, {__index = ShootPhase})
end

function ShootPhase:reset()
    self.range = nil
    self.T = nil
    self.SV = nil
    self.IS = nil
    self.IW = nil
    self.weapon = nil
    self.selectedUnits = nil
    self.selectedModel = nil
    self.targetUnit = nil
    self.weaponsFired = {}

    UIAdapter.enableFriendliesOnly(self.unitsFired)
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
    UIAdapter.resetAllUnits()
    self.selectedUnits = obj:getSquadMembers(true)
    self.selectedModel = obj

    local weapons = UIAdapter.getShootingWeapons(self.selectedUnits)
    for weapon in weapons do
        self.selectedModel:createCustomButton(weapon.name, self, 'shootWeapon', weapon)
    end
    self.selectedModel:createCustomButton('Unit Done', self, 'unitDone')
end

function ShootPhase:shootWeapon(button)
    self.weapon = button.function_params.weapon
    UIAdapter.enableEnemiesInRange(self.selectedUnits, self.weapon.range)
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
    self.T = obj:getStat(Stats.T)
    self.SV = obj:getStat(Stats.SV)
    self.IS = obj:getStat(Stats.IS)
    self.IW = obj:getStat(Stats.IW)

    -- Calculate closest range between units
    for unit in self.selectedUnits do
        local range = unit:rangeTo(obj)
        if not self.range then
            self.range = range
        elseif range < self.range then
            self.range = range
        end
    end

    -- Modifiers.
    local unitString = nil
    for unit in self.selectedUnits do
        unit:applyModifiers(Events.shoot, self) -- Triggering the shoot event, since we are already in the loop.
        unit:triggerEvent(Events.shoot)
        local unitName = unit:getName()
        if not unitString then
            unitString = unitName
        else
            unitString = unitString .. ', ' .. unitName
        end
    end
    self.targetUnit:applyModifiers(Events.shoot, self)
    Stats.applyModifiers(Events.shoot, self, self.weapon.mods)

    -- Resolve damage.
    Game.log(Events.shoot, unitString .. ' shot at ' .. self.targetUnit:getName() .. '.', true)
    Combat.resolveShooting(self) -- Call after main log message so the combat output displays after.
    self.weaponsFired[self.weapon.name] = self.weapon.count
    self.targetUnit:triggerEvent(Events.shotAt) -- Trigger this AFTER the unit has recieved damage.

    -- Loop back to selecting a weapon, until they click the "Unit Done" button.
    self:shooterSelected(self.selectedModel)
end
