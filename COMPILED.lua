UIAdapter = {}

function UIAdapter.messagePlayers(message, color)
    broadcastToAll(message, color)
end

function UIAdapter.getPlayerName(player)
    return Player[player].steam_name
end

function UIAdapter.log(message, messagePlayers)
    log(message)
    if messagePlayers then
        UIAdapter.messagePlayers(message)
    end
end

function UIAdapter.spawnIndicator(location, color, size)
    local rangeIndicator =
        spawnObject(
        {
            type = "Custom_Model",
            position = obj.getPosition()
        }
    )
    rangeIndicatorsetCustomObject(
        {
            mesh = "https://my.mixtape.moe/xqbmrf.obj",
            collider = "http://pastebin.com/raw.php?i=ahfaXzUd"
        }
    )
    rangeIndicator.setColorTint(color)
    rangeIndicator.scale(size / 10) -- The texture is 10" wide at scale.

    return rangeIndicator
end
Unit = {
    patterns = {
        name = "%[(.+)%]%s*(.+)%s*(%d)/%d",
        description = "[,:]?%s?([^,:]+)[,:\n]?"
    }
}

function Unit:adaptFrom(obj)
    -- Make sure this is actually a unit in the game.
    if not obj or not obj.getName():match("^%[.+%].+") then
        return nil
    end

    -- Pull the Unit from the cache on obj, if it exists.
    local existing = obj.getTable("Unit")
    if existing then
        return existing
    end

    local new = setmetatable({}, {__index = Unit})
    new.object = obj

    -- Get all modifiers and special rules.
    new.mods = {}
    local desc = obj.getDescription()
    for rule in desc:match(self.patterns.description) do
        SpecialRules[rule](new)
    end

    -- Parse out the name field.
    local nameMatches = string.match(self.object.getName(), self.patterns.name)
    new.owner = nameMatches[0]
    new.name = nameMatches[1]
    new.remainingW = nameMatches[2]

    -- Get the other members of the unit's squad.
    local squad = UnitManager.getSquad(new.name)
    if #squad > 1 then
        new.squad = squad
    end

    obj.setTable("Unit", new) -- Save on the object for caching.
    return new
end

function Unit:isFriendly()
    return self.owner == Game.players.current
end

function Unit:isEnemy()
    return not self:isFriendly()
end

function Unit:rangeTo(vector)
    local v1 = self.object.getPosition()
    local v2 = vector
    return math.abs(math.sqrt((((v2.x - v1.x) ^ 2) + ((v2.y - v1.y) ^ 2) + ((v2.z - v1.z) ^ 2))))
end

function Unit:release()
    self.object.setLocation(self.object.getVar("startingLocation") or self.object.getLocation())
end

function Unit:reset(highlightOff)
    self.object.interactable = true
    if highlightOff then
        self.object.highlightOff()
    end
    self:release()
end

function Unit:getID()
    return self.object.guid
end

function Unit:getLocation()
    return self.object.getPosition()
end

function Unit:objectsInRange(size)
    local hits =
        Physics.cast(
        {
            origin = self.object.getLocation(),
            type = 2, -- Sphere
            size = size * InchesToPoints
        }
    )

    local objs = {}
    for hit in hits do
        table.insert(objs, hit.hit_object)
    end
    return objs
end

function Unit:getClosest()
    local hits =
        Physics.cast(
        {
            origin = self.object.getLocation(),
            type = 2, -- Sphere
            size = 60 * InchesToPoints
        }
    )

    local closest = hits[0]
    for hit in hits do
        local unit = Unit:adaptFrom(hit.hit_object)
        if closest and unit and closest.distance > hit.distance then
            closest = hit
        end
    end
    return Unit:adaptFrom(closest.hit_object)
end

function Unit:applyModifiers(event, phase)
    for mod in self.mods[event] do
        mod(phase)
    end
end

function Unit:inSquadCoherency()
    local isInCoherency = not squad
    for obj in self:objectsInRange(2) do
        local unit = Unit:adaptFrom(obj)
        if unit and unit.name == self.name and self.obj.getGUID() ~= unit.object.getGUID() then
            isInCoherency = true
        end
    end
    return isInCoherency
end

function Unit:inCombat()
    local isInCombat = false
    for unit in self.squad do
        for obj in unit:objectsInRange(1) do
            local u = Unit:adaptFrom(obj)
            if u and u:isEnemy() then
                isInCombat = true
            end
        end
    end
    return isInCombat
end

function Unit:createCustomButton(label, funcOwner, funcName, funcParams)
    local buttons = self.object.getButtons()
    createCustomButton(label, funcOwner, funcName, funcParams, #buttons)
end

function createCustomButton(label, funcOwner, funcName, funcParams, position)
    self.createButton(
        {
            rotation = {0, 0, 0},
            width = 900,
            height = 400,
            font_size = 200,
            function_owner = funcOwner,
            click_function = funcName,
            function_params = funcParams,
            label = label,
            position = {0, 1, position}
        }
    )
end

function Unit:clearControls()
    self.object.clearButtons()
end

function Unit:getShootingWeapons()
    local shootingWeapons = {}
    for unit in self.squad or {self} do
        for weapon in unit.weapons do
            if weapon.type ~= WeaponTypes.Melee then
                shootingWeapons:insert(weapon)
            end
        end
    end
    return shootingWeapons
end

function Unit:applyAttribute(attr)
    self.object.setName(self.object.getName() .. " (" .. attr .. ")")
    self.attr[attr] = true
end

function Unit:hasAttribute(attr)
    return self.attr[attr]
end

function Unit:clearAttributes()
    self.object.setName(self.object.getName():gsub("(.+)", ""))
    self.attr = {}
end
UnitManager = {}

function UnitManager.enableFriendliesOnly(notInCombat, exceptTheseIDs)
    for obj in getAllObjects() do
        local unit = Unit:adaptFrom(obj)
        if unit then
            local enabled =
                unit:isFriendly() and not exceptTheseIDs[unit:getID()] and not (unit:inCombat() and notInCombat)
            obj.interactable = not enabled

            if enabled then
                obj.highlightOn(Colors.green)
            else
                obj.highlightOff()
            end
        end
    end
end

function UnitManager.enableEnemiesInRange(units, range, notInCombat)
    for obj in getAllObjects() do
        local unit = Unit:adaptFrom(obj)
        if unit then
            local isInRange = false
            for unit in units do
                if
                    unit:isEnemy() and unit:rangeTo(unit:getLocation()) <= range and
                        not (unit:inCombat() and notInCombat)
                 then
                    isInRange = true
                    break
                end
            end
            obj.interactable = not isInRange

            if isInRange then
                obj.highlightOn(Colors.red)
            else
                obj.highlightOff()
            end
        end
    end
end

function UnitManager.enableSquadOnly(squad)
    for obj in getAllObjects() do
        local unit = Unit:adaptFrom(obj)
        if unit then
            local inSquad = unit.name == squad and unit:isFriendly()
            obj.interactable = not inSquad

            if inSquad then
                units[unit:getID()] = obj
                obj.highlightOn(Colors.green)
            else
                obj.highlightOff()
            end
        end
    end
end

function UnitManager.getSquad(name, highlightOn)
    local units = {}
    for obj in getAllObjects() do
        local unit = Unit:new(obj)
        if unit then
            if unit.name == name then
                if highlightOn then
                    obj.highlightOn(Colors.green)
                end
                units[obj.getGUID()] = obj
            end
        end
    end
    return units
end

function UnitManager.resetAllUnits(clearAttr)
    for obj in getAllObjects() do
        local unit = Unit:adaptFrom(obj)
        if unit then
            obj.interactable = true
            obj.highlightOff()
            if clearAttr then
                unit.clearAttributes()
            end
        end
    end
end

function UnitManager.getObjectByID(id)
    return getObjectFromGUID(id)
end
EndPhase = {}

function EndPhase:start()
    EndPhase.nextPhase = EndPhase

    UnitManager.resetAllUnits(true)
    Game:logEvent(Events.ending, 'Ending ' .. UIAdapter.getPlayerName(Game.players.current) .. '\'s Turn ' .. Game.turn .. '.', true)
    UIAdapter.messagePlayers('Please click "End Turn".')

    return setmetatable({}, {__index = EndPhase})
end
MovePhase = {}

function MovePhase:start()
    self:reset()
    self.unitsMoved = {}
    self.nextPhase = ShootPhase

    UIAdapter.messagePlayers("Select a unit to move.")

    return setmetatable({}, {__index = MovePhase})
end

function MovePhase:reset()
    self.M = nil
    self.squadCoherency = 2
    self.movementIndicator = nil
    self.advanceMove = nil
    self.advanceIndicator = nil
    self.unitInMotion = nil
    self.invalidMove = false
    self.squadMoving = nil
    self.squadCoherencyIndicators = {}
    self.moveRange = nil
    self.fallingback = false

    UnitManager.enableFriendliesOnly(false, self.unitsMoved)
end

-- Setup the selected unit for a movement, and cleanup the last unit moved, if needed.
function MovePhase:pickup(player, obj)
    local unit = Unit:adaptFrom(obj)
    if not unit then
        return
    end

    -- Only active player can move
    if Game.players.current ~= player then
        UIAdapter.messagePlayers("Only the active player may move units.")
        unit:release()
        return
    end

    -- The last move was invalid for some reason.
    if self.invalidMove then
        UIAdapter.messagePlayers("You must place the previous unit in a valid location first.")
        unit:release()
        return
    end

    -- Cleanup the last unit, if needed.
    if self.unitInMotion and self.unitInMotion:getID() ~= unit:getID() then
        self:cleanupLastUnit()
    end

    self:setupUnit(unit)
end

-- Check that the move was valid.
function MovePhase:release(player, obj)
    local unit = Unit:adaptFrom(obj)
    if not unit then
        return
    end

    -- Not in movement range.
    if unit:rangeTo(self.startingLocation) > self.advanceMove then
        UIAdapter.messagePlayers("You must place this unit within its specified movement range.")
        self.invalidMove = true
        return
    end

    -- Not in squad coherency.
    local coherencyIndicators = self.squadCoherencyIndicators
    if self.squadMoving and #coherencyIndicators > 0 and not unit:inSquadCoherency() then
        UIAdapter.messagePlayers("You must place this unit within squad coherency.")
        self.invalidMove = true
        return
    end
end

function MovePhase:cleanupLastUnit()
    local unit = self.unitInMotion
    self.moveRange = unit:rangeTo(self.startingLocation)
    self.unitsMoved[self.unitInMotion:getID()] = true
    unit:reset(true)

    -- Clean up indicators.
    self.moveIndicator.destruct()
    self.advanceIndicator.destruct()

    -- Trigger unit event.
    local event = nil
    if self.fallingback then
        event = Events.move.fellBack
        unit.applyAttribute(event)
    elseif self.moveRange > self.M then
        event = Events.move.advanced
        unit.applyAttribute(event)
    else
        event = Events.move.moved
    end
    unit:applyModifiers(Events.move.advanced, phase)

    -- Squad cleanup.
    if self.squadMoving then
        self.squadMoving[self.unitInMotion:getID()] = nil

        -- Squad still has members.
        if next(self.squadMoving) ~= nil then
            table.insert(
                self.squadCoherencyIndicators,
                UIAdapter.spawnIndicator(currentLocation, Colors.green, self.squadCoherency)
            )
            return
        end

        -- Squad done moving.
        for indicator in self.squadCoherencyIndicators do
            indicator.destruct()
        end
    end

    Game:logEvent(Events.move, unit.name .. (advanceMove and " advanced " or " moved ") .. self.moveRange .. " inches.")
    self:reset()
end

function MovePhase:setupUnit(unit)
    -- Squad setup.
    local squad = unit.squad
    if not self.squadMoving then
        self.squadMoving = UnitManager.enableSquadOnly(squad)
    end

    -- Moving unit setup.
    self.unitInMotion = unit
    self.startingLocation = unit:getLocation()
    self.invalidMove = false

    -- Stat with modifiers.
    self.M = unit.M

    -- Advance or fallback.
    if not unit:inCombat() then
        unit:applyModifiers(Events.move.moving, self)

        self.d6 = Combat.rollD6()
        unit:applyModifiers(Events.move.advancing, self)
        self.advanceMove = self.M + self.d6
    else
        self.fallingback = true
        unit:applyModifiers(Events.move.fallingback, self)
    end

    -- Movement indicators.
    self.moveIndicator = UIAdapter.spawnIndicator(currentLocation, Colors.green, self.M)
    self.advanceIndicator = UIAdapter.spawnIndicator(currentLocation, Colors.yellow, self.advanceMove)
end
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
StartPhase = {}

function StartPhase:start()
    StartPhase.nextPhase = MovePhase

    Game:logEvent(Events.start, 'Beginning ' .. UIAdapter.getPlayerName(Game.players.current) .. '\'s Turn ' .. Game.turn .. '.', true)

    return setmetatable({}, {__index = StartPhase})
end
SpecialRules = {
    -- Example special rule.
    -- ["Mega Melta"] = function(unit) 
    --     unit.mods[Events.shoot.shooting] = function(phase)
    --         if phase.range < 16 then
    --             phase.weapon.D = phase.weapon.D * 3
    --         end
    --     end
    -- end
}
Combat = {}

function Combat.rollCombat(phase)
    phase.combatRolls = {}
    for i = 0, i < phase.weapon.attacks do
        table.insert(phase.combatRolls, {hit = Combat.rollD6(), wound = Combat.rollD6(), save = Combat.rollD6()})
    end
end

function Combat.resolveDamage(phase)
    --TODO: return damage done
end

function Combat.rollD6()
    return math.random(6)
end

-- function Combat.resolveCombatRolls(rolls, toHit, hitRR, toWound, woundRR, toSave, saveRR, combatMods)
--     local wounds = {}
--     for i = 0, i < rolls do
--         local hit = combatRoll(toHit, hitRR)
--         if hit then
--             local wound = combatRoll(toWound, woundRR)
--             if wound then
--                 local save = combatRoll(toSave, saveRR)
--             end
--         end
--     end
-- end

-- function combatRoll(target, reroll)
--     if reroll > target then
--         reroll = target - 1
--     end

--     local roll = Combat.rollD6()
--     if roll <= reroll then
--         roll = Combat.rollD6()
--     end

--     if roll >= target then
--         return roll
--     else
--         return nil
--     end
-- end
Game = {
    players = {
        starting = nil,
        current = nil
    },
    turn = 0,
    phase = StartPhase,
    log = {}
}

function Game:nextPhase()
    Game.phase = Game.phase.nextPhase:start()
end

function Game:nextTurn(player)
    Game.players.starting = Game.players.starting or player
    Game.players.current = player
    if player == Game.current then
        Game.turn = Game.turn + 1
    end
    Game.phase = StartPhase:start()
end

function Game:logEvent(event, message, messagePlayers)
    table.insert(Game.log, {time = os.date(), event = event, message = message})
    UIAdapter.log(message, messagePlayers)
end
Colors = {
    green = {0, 255, 0},
    yellow = {255, 255, 0},
    red = {255, 0, 0}
}
Events = {
    start = "Start",
    move = {
        moving = "Moving",
        moved = "Moved",
        advancing = "Advancing",
        advanced = "Advanced",
        fallingBack = "FallingBack",
        fellBack = "FellBack"
    },
    psyker = {},
    shoot = {
        shooting = "Shooting",
        shotAt = "ShotAt"
    },
    charge = {},
    fight = {},
    morale = {},
    damage = {
        wounded = "Wounded",
        causedWounds = "CausedWounds"
    }
}
Stats = {
    M = "M",
    WS = "WS",
    BS = "BS",
    S = "S",
    T = "T",
    W = "W",
    A = "A",
    LD = "LD",
    SV = "SV",
    IS = "IS"
}
WeaponTypes = {
    Melee = "Melee"
}
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
        createCustomButton("Next Phase", Game, "nextPhase", 0)
    end
    Game:nextTurn(startingPlayer)
end
