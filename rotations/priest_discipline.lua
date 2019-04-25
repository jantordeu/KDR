--[[[
@module Priest Discipline Rotation
@author htordeux
@version 8.1
]]--

local spells = kps.spells.priest
local env = kps.env.priest

local MassDispel = spells.massDispel.name
local AngelicFeather = spells.angelicFeather.name
local Barriere = spells.powerWordBarrier.name


kps.runAtEnd(function()
   kps.gui.addCustomToggle("PRIEST","DISCIPLINE", "mouseOver", "Interface\\Icons\\priest_spell_leapoffaith_a", "mouseOver")
end)

kps.runAtEnd(function()
   kps.gui.addCustomToggle("PRIEST","DISCIPLINE", "holyNova", "Interface\\Icons\\spell_holy_holynova", "holyNova")
end)

kps.runAtEnd(function()
   kps.gui.addCustomToggle("PRIEST","DISCIPLINE", "focusControl", "Interface\\Icons\\spell_nature_polymorph", "focusControl")
end)


kps.rotations.register("PRIEST","DISCIPLINE",{

    {spells.powerWordFortitude, 'not player.isInGroup and not player.hasBuff(spells.powerWordFortitude)', "player" },

    {{"macro"}, 'not target.isAttackable and mouseover.isAttackable and mouseover.inCombat' , "/target mouseover" },
    {{"macro"}, 'not target.exists and mouseover.isAttackable and mouseover.inCombat' , "/target mouseover" },
    {{"macro"}, 'not focus.exists and mouseover.isAttackable and mouseover.inCombat and not mouseover.isUnit("target")' , "/focus mouseover" },
    {{"macro"}, 'focus.exists and target.isUnit("focus")' , "/clearfocus" },
    --env.haloMessage,
    
    -- "Fade" 586 "Disparition"
    {spells.fade, 'player.isTarget and player.isInGroup' },
    -- "Dissipation de masse" 32375
    {{"macro"}, 'keys.ctrl', "/cast [@cursor] "..MassDispel },
    -- "Power Word: Barrier" 62618
    {{"macro"}, 'keys.shift', "/cast [@cursor] "..Barriere },
    
   {spells.painSuppression, 'heal.lowestTankInRaid.hp < 0.30' , kps.heal.lowestTankInRaid },
   {spells.painSuppression, 'player.hp < 0.30' , "player" },
   {spells.painSuppression, 'mouseover.isHealable and mouseover.hp < 0.30' , "mouseover" },
   {spells.painSuppression, 'focus.isHealable and focus.hp < 0.30' , "focus" },

    -- "Dissipation de la magie" -- Dissipe la magie sur la cible ennemie, supprimant ainsi 1 effet magique bénéfique.
    {spells.dispelMagic, 'target.isAttackable and target.isBuffDispellable and not spells.dispelMagic.lastCasted(6)' , "target" },
    {spells.dispelMagic, 'mouseover.isAttackable and mouseover.isBuffDispellable and not spells.dispelMagic.lastCasted(6)' , "mouseover" },   
    {spells.arcaneTorrent, 'player.timeInCombat > 30 and target.isAttackable and target.distance <= 10' , "target" },

    {spells.mindControl, 'kps.focusControl and focus.isAttackable and not focus.hasMyDebuff(spells.mindControl) and focus.myDebuffDuration(spells.mindControl) < 2' , "focus" },
    {{"nested"}, 'kps.interrupt' ,{
        {spells.shiningForce, 'player.hasTalent(4,3) and player.isTarget and target.distance <= 10 and target.isCasting' , "player" },
        {spells.psychicScream, 'player.hasTalent(4,3) and spells.shiningForce.cooldown > 0 and player.isTarget and target.distance <= 10 and target.isCasting' , "player" },
        {spells.psychicScream, 'not player.hasTalent(4,3) and player.isTarget and target.distance <= 10 and target.isCasting' , "player" },
    }},

    -- "Dispel" "Purifier" 527
    {spells.purify, 'mouseover.isHealable and mouseover.isDispellable("Magic")' , "mouseover" },
    {{"nested"},'kps.cooldowns', {
        {spells.purify, 'heal.lowestTankInRaid.isDispellable("Magic")' , kps.heal.lowestTankInRaid},
        {spells.purify, 'player.isDispellable("Magic")' , "player" },
        {spells.purify, 'heal.lowestInRaid.isDispellable("Magic")' , kps.heal.lowestInRaid},
        {spells.purify, 'heal.isMagicDispellable' , kps.heal.isMagicDispellable },
    }},

    --{spells.fireBlood, 'player.isDispellable("Magic") or player.isDispellable("Disease") or player.isDispellable("Poison") or player.isDispellable("Curse")' , "player" },
    {{"macro"}, 'player.hp < 0.70 and player.useItem(5512)' , "/use item:5512" },
    {spells.giftOfTheNaaru, 'player.hp < 0.70' , "player" },
    {spells.desperatePrayer, 'player.hp < 0.55' , "player" },
    -- "Angelic Feather"
    {{"macro"},'player.hasTalent(2,3) and not player.isSwimming and player.isMovingFor(1.2) and not player.hasBuff(spells.angelicFeather)' , "/cast [@player] "..AngelicFeather },
    -- "Levitate" 1706
    {spells.levitate, 'player.isFallingFor(1.4) and not player.hasBuff(spells.levitate)' , "player" },
    -- "Body and Soul"
    {spells.powerWordShield, 'player.hasTalent(2,1) and player.isMovingFor(1.2) and not player.hasBuff(spells.bodyAndSoul) and not player.hasDebuff(spells.weakenedSoul)' , "player", "SCHIELD_MOVING" },

    -- TRINKETS -- SLOT 0 /use 13
    -- "Inoculating Extract" 160649 -- "Extrait d’inoculation" 160649
    --{{"macro"}, 'player.hasTrinket(0) == 160649 and player.useTrinket(0) and targettarget.exists and targettarget.isHealable' , "/use [@targettarget] 13" },
    {{"macro"}, 'player.useTrinket(0) and heal.lowestInRaid.hp < 0.40' , "/use 13" },
    -- TRINKETS -- SLOT 1 /use 14
    {{"macro"}, 'not player.hasTrinket(1) == 165569 and player.useTrinket(1) and heal.lowestInRaid.hp < 0.40' , "/use 14" },
    {{"macro"}, 'player.hasTrinket(1) == 165569 and player.useTrinket(1) and heal.lowestInRaid.hp < 0.40' , "/use [@player] 14" },
    
    {{"nested"}, 'player.hasBuff(spells.rapture)' , {
        {spells.powerWordShield, 'not heal.lowestTankInRaid.hasBuff(spells.powerWordShield) and heal.lowestTankInRaid.hp < 0.82' , kps.heal.lowestTankInRaid },
        {spells.powerWordShield, 'not player.hasBuff(spells.powerWordShield) and player.hp < 0.82 and not spells.powerWordShield.isRecastAt("player")' , "player" },
        {spells.powerWordShield, 'not heal.lowestUnitInRaid.hasBuff(spells.powerWordShield) and heal.lowestUnitInRaid.hp < 0.82 and not spells.powerWordShield.isRecastAt(heal.lowestUnitInRaid.unit)' , kps.heal.lowestUnitInRaid },
        {spells.powerWordShield, 'mouseover.isHealable and mouseover.hp < 0.65 and not mouseover.hasBuff(spells.powerWordShield) and not spells.powerWordShield.isRecastAt("mouseover")' , "mouseover" },
        {spells.powerWordShield, 'target.isAttackable and targettarget.isHealable and targettarget.hp < 0.82 and not targettarget.hasBuff(spells.powerWordShield) and not targettarget.hasDebuff(spells.weakenedSoul) and not spells.powerWordShield.isRecastAt("targettarget")' , "targettarget" },
    }},

    -- TANK 
    {spells.shadowMend, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.40 and heal.lowestTankInRaid.myBuffDuration(spells.atonement) < 2' , kps.heal.lowestTankInRaid , "shadowMend_tank" },
    {spells.powerWordShield, 'heal.lowestTankInRaid.myBuffDuration(spells.atonement) < 2 and not heal.lowestTankInRaid.hasDebuff(spells.weakenedSoul)' , kps.heal.lowestTankInRaid , "powerWordShield_tank" },
    {spells.penance, 'heal.lowestTankInRaid.hp < 0.40' , kps.heal.lowestTankInRaid  , "penance_defensive" },
    {spells.shadowMend, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.40 and not spells.shadowMend.isRecastAt(heal.lowestTankInRaid.unit)' , kps.heal.lowestTankInRaid },
    -- TANK MOUSEOVER
    {spells.powerWordShield, 'mouseovertarget.isHealable and mouseovertarget.isRaidTank and mouseovertarget.myBuffDuration(spells.atonement) < 2 and not mouseover.hasDebuff(spells.weakenedSoul) ' , "mouseovertarget" , "powerWordShield_isRaidTank" },
    {spells.powerWordShield, 'mouseover.isHealable and mouseover.isRaidTank and mouseover.myBuffDuration(spells.atonement) < 2 and not mouseover.hasDebuff(spells.weakenedSoul) ' , "mouseover" , "powerWordShield_isRaidTank" },
    -- PLAYER
    {spells.shadowMend, 'not player.isMoving and player.hp < 0.40 and player.myBuffDuration(spells.atonement) < 2' , "player" , "shadowMend_player" },
    {spells.powerWordShield, 'player.hp < 0.82 and player.myBuffDuration(spells.atonement) < 2 and not player.hasDebuff(spells.weakenedSoul)' , "player" , "powerWordShield_player" },
    {spells.penance, 'player.hp < 0.40' , "player"  , "penance_defensive" },
    {spells.shadowMend, 'not player.isMoving and player.hp < 0.40 and not spells.shadowMend.isRecastAt("player")' , "player" },

    -- GROUPHEAL
    -- heal.lossHealthRaid` - Returns the loss Health for all raid members
    -- heal.atonementHealthRaid - Returns the loss Health for all raid members with buff atonement
    -- heal.hasBuffCount(spells.atonement)
    -- heal.hasNotBuffAtonementCount(0.82) -- count unit below 0.82 health without atonement buff
    -- heal.hasBuffAtonementCount(0.82) -- count unit below 0.82 health with atonement buff
    -- heal.countLossInRange(0.82) -- count unit below 0.82 health
    -- heal.hasNotBuffAtonement.hp < 0.92 -- UNIT with lowest health without Atonement Buff on raid -- default "player" 
    -- heal.hasBuffAtonement.hp < 0.92 - UNIT with lowest health with Atonement Buff on raid e.g. -- default "player"    
    {spells.evangelism, 'player.hasTalent(7,3) and spells.powerWordRadiance.charges == 0' },
    {spells.powerWordRadiance, 'kps.defensive' , "player" , "radiance_defensive" },
    {spells.powerWordRadiance, 'not player.isMoving and heal.hasNotBuffAtonementCount(0.82) >= 3 and heal.lowestTankInRaid.myBuffDuration(spells.atonement) < 2 and not spells.powerWordRadiance.isRecastAt(heal.lowestTankInRaid.unit)' , kps.heal.lowestTankInRaid , "radiance_tank" },
    {spells.powerWordRadiance, 'not player.isMoving and heal.hasNotBuffAtonementCount(0.82) >= 3 and player.myBuffDuration(spells.atonement) < 2 and not spells.powerWordRadiance.isRecastAt("player")' , "player" , "radiance_player" },
    {spells.powerWordRadiance, 'not player.isMoving and heal.hasNotBuffAtonementCount(0.82) >= 3 and not heal.hasNotBuffAtonement.isUnit("player") and not spells.powerWordRadiance.isRecastAt(heal.hasNotBuffAtonement.unit)' , kps.heal.hasNotBuffAtonement , "radiance_hasNotBuffAtonement" },

    {{"nested"}, 'spells.powerWordRadiance.lastCasted(7) or spells.rapture.lastCasted(9) or spells.evangelism.lastCasted(5)' , {
        {spells.powerWordSolace, 'player.hasTalent(3,3)' , env.damageTarget },
        {spells.mindbender, 'player.hasTalent(3,2) and heal.hasBuffAtonementCount(0.82) >= 3' , env.damageTarget },
        {spells.shadowfiend, 'not player.hasTalent(3,2) and heal.hasBuffAtonementCount(0.82) >= 3' , env.damageTarget },
        {spells.schism, 'not player.isMoving and player.hasTalent(1,3) and heal.hasBuffAtonement.hp < 0.92' , env.damageTarget },
        {spells.penance, 'heal.hasBuffAtonement.hp < 0.92' , env.damageTarget  },
    }},

    {spells.rapture, 'heal.lowestTankInRaid.hp < 0.40 and not heal.lowestTankInRaid.hasBuff(spells.painSuppression) and spells.penance.cooldown > kps.gcd' },
    {spells.rapture, 'spells.powerWordRadiance.charges == 0 and heal.hasNotBuffAtonementCount(0.65) >= 3 and spells.penance.cooldown > kps.gcd' },
    
    {spells.powerWordSolace, 'player.hasTalent(3,3)' , env.damageTarget },    
    {spells.divineStar, 'player.hasTalent(6,2) and heal.countLossInRange(0.90) >= 3 and target.distance <= 30' , "target" },
    {spells.halo, 'not player.isMoving and player.hasTalent(6,3) and heal.countLossInRange(0.90) >= 3' },
    {spells.shadowCovenant, 'player.hasTalent(5,3) and heal.countLossInRange(0.82) >= 3' , kps.heal.lowestInRaid },
    {spells.luminousBarrier, 'player.hasTalent(7,2) and heal.countLossInRange(0.82)*2 > heal.countInRange' },
    {spells.holyNova, 'kps.holyNova' },

    -- NOT ISINGROUP
    {{"nested"}, 'kps.multiTarget' , {
        {spells.powerWordShield, 'heal.lowestTankInRaid.myBuffDuration(spells.atonement) < 2 and not heal.lowestTankInRaid.hasDebuff(spells.weakenedSoul)' , kps.heal.lowestTankInRaid },
        {spells.powerWordShield, 'player.myBuffDuration(spells.atonement) < 2 and not player.hasDebuff(spells.weakenedSoul)' , "player" },
        {spells.powerWordShield, 'target.isAttackable and targettarget.isFriend and targettarget.hp < 0.92 and targettarget.myBuffDuration(spells.atonement) < 2 and not targettarget.hasDebuff(spells.weakenedSoul)' , "targettarget" , "powerWordShield_targettarget" },
        {spells.powerWordShield, 'mouseover.isFriend and mouseover.myBuffDuration(spells.atonement) < 2 and mouseover.hp < 0.92 and not mouseover.hasDebuff(spells.weakenedSoul)' , "mouseover" },
        {spells.shadowMend, 'not player.isMoving and mouseover.isFriend and mouseover.hp < 0.65 and not spells.shadowMend.isRecastAt("mouseover")' , "mouseover" },
        {spells.shadowMend, 'not player.isMoving and player.hp < 0.65 and not spells.shadowMend.isRecastAt("player")' , "player" },
        {spells.shadowMend, 'not player.isMoving and heal.lowestTankInRaid.hp < 0.65 and not spells.shadowMend.isRecastAt(heal.lowestTankInRaid.unit)' , kps.heal.lowestTankInRaid },
        {spells.holyNova, 'kps.holyNova' },
        {spells.shadowWordPain, 'target.isAttackable and target.myDebuffDuration(spells.shadowWordPain) < 4.8 and not spells.shadowWordPain.isRecastAt("target")' , "target" },
        {spells.shadowWordPain, 'mouseover.isAttackable and mouseover.inCombat and mouseover.myDebuffDuration(spells.shadowWordPain) < 4.8 and not spells.shadowWordPain.isRecastAt("mouseover")' , "mouseover" },
        {spells.powerWordSolace, 'player.hasTalent(3,3) and target.isAttackable' , "target" },
        {spells.schism, 'not player.isMoving and player.hasTalent(1,3) and target.isAttackable and spells.penance.cooldown < 7' , "target" },
        {spells.penance, 'target.isAttackable' , "target" },
        {spells.divineStar, 'player.hasTalent(6,2) and target.isAttackable and target.distance <= 30' , "target" },
        {spells.mindbender, 'player.hasTalent(3,2) and target.isAttackable' , "target" },
        {spells.shadowfiend, 'not player.hasTalent(3,2) and target.isAttackable' , "target" },
        {spells.smite, 'not player.isMoving and target.isAttackable' , "target" },
    }},

    --{spells.schism, 'not player.isMoving and player.hasTalent(1,3) and heal.hasBuffAtonementCount(0.82) >= 3' , env.damageTarget , "schism_count" },
    --{spells.schism, 'not player.isMoving and player.hasTalent(1,3) and heal.hasBuffAtonement.hp < 0.65' , env.damageTarget , "schism_low" },
    {spells.shadowWordPain,'target.isAttackable and not target.hasMyDebuff(spells.shadowWordPain) and not spells.shadowWordPain.isRecastAt("target")', "target" , "pain_target"},
    {spells.holyNova, 'player.isMoving and heal.countLossInDistance(0.92,10) >= 3' },

     -- MOUSEOVER
    {{"nested"}, 'kps.mouseOver and mouseover.isAttackable' , {
        {spells.shadowMend, 'not player.isMoving and mouseovertarget.isHealable and mouseovertarget.hp < 0.55 and mouseovertarget.myBuffDuration(spells.atonement) < 2' , "mouseovertarget" , "shadowMend_mouseovertarget"},
        {{spells.powerWordShield,spells.penance}, 'mouseovertarget.isHealable and mouseovertarget.myBuffDuration(spells.atonement) < 2 and mouseovertarget.hp < 0.82 and not mouseovertarget.hasDebuff(spells.weakenedSoul)' , "mouseover" , "powerWordShield_mouseover" },
        {spells.powerWordShield, 'mouseovertarget.isHealable and mouseovertarget.myBuffDuration(spells.atonement) < 2 and mouseovertarget.hp < 0.92 and not mouseovertarget.hasDebuff(spells.weakenedSoul)' , "mouseovertarget" , "powerWordShield_mouseovertarget" },
        {spells.penance, 'mouseovertarget.isHealable and mouseovertarget.myBuffDuration(spells.atonement) > 2 and mouseovertarget.hp < 0.92' , "mouseover" , "penance_mouseover" },
        {spells.shadowWordPain,'not mouseover.hasMyDebuff(spells.shadowWordPain) and not spells.shadowWordPain.isRecastAt("mouseover")', "mouseover" , "pain_mouseover"},
        {spells.shadowMend, 'not player.isMoving and mouseovertarget.isHealable and mouseovertarget.hp < 0.40' , "mouseovertarget" , "shadowMend_mouseovertarget"},
        {spells.smite, 'not player.isMoving', "mouseover" , "smite_mouseover"},
    }},

    {{"nested"}, 'kps.mouseOver and mouseover.isHealable' , {
        {spells.shadowMend, 'not player.isMoving and mouseover.hp < 0.55 and mouseover.myBuffDuration(spells.atonement) < 2' , "mouseover" , "shadowMend_mouseover"},
        {{spells.powerWordShield,spells.penance}, 'mouseover.myBuffDuration(spells.atonement) < 2 and mouseover.hp < 0.82 and not mouseover.hasDebuff(spells.weakenedSoul)' , "mouseover" , "powerWordShield_mouseover" },
        {spells.powerWordShield, 'mouseover.myBuffDuration(spells.atonement) < 2 and mouseover.hp < 0.92 and not mouseover.hasDebuff(spells.weakenedSoul)' , "mouseover" , "powerWordShield_mouseover" },
        {spells.penance, 'mouseover.myBuffDuration(spells.atonement) > 2 and mouseover.hp < 0.92 and mouseovertarget.isAttackable' , "mouseover" , "penance_mouseovertarget" },
        {spells.shadowWordPain, 'mouseovertarget.isAttackable and not mouseovertarget.hasMyDebuff(spells.shadowWordPain) and not spells.shadowWordPain.isRecastAt("mouseovertarget")' , "mouseovertarget" , "pain_mouseovertarget" },
        {spells.shadowMend, 'not player.isMoving and mouseover.hp < 0.40' , "mouseover" , "shadowMend_mouseover"},
        {spells.smite, 'not player.isMoving and mouseovertarget.isAttackable' , "mouseovertarget" , "smite_mouseovertarget" },
    }},

    {spells.penance, 'heal.hasBuffAtonement.hp < 0.92' , env.damageTarget  , "penance_offensive" },
    {spells.smite, 'not player.isMoving and heal.lowestInRaid.hp > 0.65' , env.damageTarget , "smite_lowest" },
    {spells.shadowMend, 'not player.isMoving and heal.lowestInRaid.hp < 0.40 and heal.lowestInRaid.myBuffDuration(spells.atonement) < 2', kps.heal.lowestInRaid ,  "shadowMend_lowest" },
    {spells.powerWordShield, 'heal.lowestInRaid.hp < 0.65 and heal.lowestInRaid.myBuffDuration(spells.atonement) < 2 and not heal.lowestInRaid.hasDebuff(spells.weakenedSoul)', kps.heal.lowestInRaid ,  "powerWordShield_lowest" },
    {spells.shadowMend, 'not player.isMoving and heal.lowestInRaid.hp < 0.40 and not spells.shadowMend.isRecastAt(heal.lowestInRaid.unit)', kps.heal.lowestInRaid ,  "shadowMend_lowest" },
    {spells.smite, 'not player.isMoving' , env.damageTarget , "smite_offensive" },

}
,"priest_discipline_bfa")


-- MACRO --
--[[

#showtooltip Mot de pouvoir : Bouclier
/cast [@mouseover,exists,nodead,help] Mot de pouvoir : Bouclier; [@mouseover,exists,nodead,harm] Châtiment

#showtooltip Pénitence
/cast [@mouseover,exists,nodead,help] Mot de pouvoir : Bouclier; [@mouseover,exists,nodead,harm] Pénitence

]]--