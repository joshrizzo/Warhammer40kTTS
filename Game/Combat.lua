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
