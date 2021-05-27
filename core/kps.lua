
local LOG=kps.Logger(kps.LogLevel.INFO)

local castSequenceIndex = 1
local castSequence = nil
local castSequenceStartTime = 0
local castSequenceTarget = 0
local prioritySpell = nil
local prioritySpellTarget = nil
local prioritySpellTime = 0
local priorityAction = nil
local priorityMacro = nil

function kps.write(...)
    DEFAULT_CHAT_FRAME:AddMessage("|cffff8000KPS: " .. strjoin(" ", tostringall(...))); -- color orange
end

kps.useItem = function(itemId)
    return function ()
        return true
    end
end

local combatStarted = -1
kps.timeInCombat = 0

kps.prioritySpell = function (spell, target)
    prioritySpell = spell
    prioritySpellTarget = target or "target"
    prioritySpellTime = GetTime()
    LOG.debug("Set %s for next cast.",spell.name)
    LOG.warn("Set for next cast:  %s. %s", spell.name, prioritySpellTarget)
end

function _CastSpellByName(spell,target)
   target = target or "target"
   secured = false
   while not secured do
      RunScript([[
         for index = 1, 100 do
            if not issecure() then
               return
            end
         end
         secured = true
         CastSpellByName("]] .. spell .. [[", "]] .. target .. [[")
      ]])
   end
end

function _RunMacroText(macroText)
    macroText = macroText or ""
    secured = false
    while not secured do
        RunScript([[
        for index = 1, 100 do
            if not issecure() then return end
        end
        secured = true
        RunMacroText("]] .. macroText .. [[")
    ]])
   end
end

function _SpellStopCasting()
   secured = false
   while not secured do
      RunScript([[
         for index = 1, 100 do
            if not issecure() then
               return
            end
         end
         secured = true
         SpellStopCasting()
      ]])
   end
end

kps.runMacro = function(macroText)
    _RunMacroText(macroText)
end

kps.stopCasting = function()
    _SpellStopCasting()
end

kps.combatStep = function ()
    -- Check for combat
    if not InCombatLockdown() and not kps.autoAttackEnabled then
        combatStarted = -1
        kps.timeInCombat = 0
        return
    end

    if combatStarted < 0 then combatStarted = time() end
    kps.timeInCombat = time() - combatStarted

    -- Check for rotation
    if not kps.rotations.getActive() then
        kps.write("KPS does not have a rotation for your class (", kps.classes.className() ,") or spec (", kps.classes.specName(), ")!")
        kps.enabled = false
    end

    local player = kps.env.player

    -- No combat if mounted (except if overriden by config), dead or drinking
    if (player.isMounted and not kps.config.dismountInCombat) or player.isDead or player.isDrinking then return end

    local activeRotation = kps.rotations.getActive()
    if not activeRotation then return end
    activeRotation.checkTalents()
    local spell, target, message = activeRotation.getSpell()
    -- Castable Spell while casting
    if spell ~= nil and spell.isCastableSpell and player.isCasting then
        spell.cast(target,message)
    end
--  if spell ~= nil and spell.id == 0 then
--      return "-stop-", "target", false
--  end

    if castSequence ~= nil then
        if castSequence[castSequenceIndex] ~= nil and (castSequenceStartTime + kps.maxCastSequenceLength > GetTime()) then
            local spell = castSequence[castSequenceIndex]()
            if spell.canBeCastAt(castSequenceTarget) and not player.isCasting then
                LOG.warn("Cast-Sequence: %s. %s", castSequenceIndex, spell)
                castSequenceIndex = castSequenceIndex + 1
                spell.cast(castSequenceTarget)
            end
        else
            castSequenceIndex = 0
            castSequence = nil
        end
    else
        if prioritySpell ~= nil and GetTime() - prioritySpellTime < 5 then
            if prioritySpell.canBeCastAt(prioritySpellTarget) then
                prioritySpell.cast(prioritySpellTarget)
                prioritySpell = nil
            else
                if prioritySpell.cooldown > 5 then prioritySpell = nil end
            end
        end
        -- Spell Object
        if spell ~= nil and spell.name ~= nil and not player.isCasting then
            if priorityMacro ~= nil then
                local macro = priorityMacro
                kps.runMacro(macro)
                priorityMacro = nil
            elseif priorityAction ~= nil then
                priorityAction()
                priorityAction = nil
            else
                LOG.debug("Casting %s[id=%s] for next cast.", spell.name, spell.id)
                spell.cast(target,message)
            end
        end
        -- Cast Sequence Table
        if type(spell) == "table" and spell.name == nil then
            LOG.debug("Starting Cast-Sequence...")
            castSequenceIndex = 1
            castSequence = spell
            castSequenceStartTime = GetTime()
            castSequenceTarget = target
            return
        end
        -- Macro
        if type(spell) == "string" then
            if not player.isCasting then
                kps.runMacro(spell)
            elseif player.isCasting and string.find(spell,"/stopcasting") ~= nil then
                kps.runMacro("/stopcasting")
            end
        end
    end
end

local prioritySpellHistory = {}

hooksecurefunc("UseAction", function(...)
    if kps.enabled and (select(3, ...) ~= nil) and InCombatLockdown() == true  then
        -- actionType, id, subType = GetActionInfo(slot)
        local stype,id,_ = GetActionInfo(select(1, ...))
        if stype == "spell" then
            if prioritySpellHistory[id] == nil then
                prioritySpellHistory[id] = kps.Spell.fromId(id)
            end
            local spell = prioritySpellHistory[id]
            if (prioritySpell == nil or prioritySpell.name ~= spell.name) and spell.isPrioritySpell then
                kps.prioritySpell(spell, "target")
            end
        end
        if stype == "item" then
            priorityAction = kps.useItem(id)
        end
        if stype == "macro" then
            macroText = select(3, GetMacroInfo(id))
            if string.find(macroText,"kps") == nil then
                priorityMacro = macroText
            end
        end
    end
end)

kps.lastCastedSpell = nil
kps.lastSentSpell = nil
kps.lastStartedSpell = nil
