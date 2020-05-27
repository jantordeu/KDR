
local LOG=kps.Logger(kps.LogLevel.INFO)

local castSequenceIndex = 1
local castSequence = nil
local castSequenceStartTime = 0
local castSequenceTarget = 0
local prioritySpell = nil
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

local combatStarted = -1
kps.timeInCombat = 0

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
        local activeRotation = kps.rotations.getActive()
        if not activeRotation then return end
        activeRotation.checkTalents()
        local spell, target, message = activeRotation.getSpell()
        -- Castable Spell while casting
        if spell ~= nil and spell.isCastableSpell and player.isCasting  then
            spell.cast(target,message)
        end
        -- Spell Object
        if spell ~= nil and spell.name ~= nil and not player.isCasting then
            if priorityAction ~= nil then
                priorityAction()
                priorityAction = nil
            elseif prioritySpell ~= nil then
                if prioritySpell.canBeCastAt("target") then
                    prioritySpell.cast(target)
                    LOG.warn("Priority Spell %s was casted.", prioritySpell)
                    prioritySpell = nil
                else
                    if prioritySpell.cooldown > 3 then prioritySpell = nil end
                    spell.cast(target,message)
                end
            else
                LOG.debug("Casting %s for next cast.", spell.name)
                spell.cast(target,message)
            end
        end
        -- Cast Sequence Table
        if type(spell) == "table" and spell.name == nil and not player.isCasting then
            LOG.debug("Starting Cast-Sequence...")
            castSequenceIndex = 1
            castSequence = spell
            castSequenceStartTime = GetTime()
            castSequenceTarget = target
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

hooksecurefunc("UseAction", function(...)
    if kps.enabled and (select(3, ...) ~= nil) and InCombatLockdown() == true  then
        -- actionType, id, subType = GetActionInfo(slot)
        local stype,id,_ = GetActionInfo(select(1, ...))
        if stype == "spell" then
            local spell = kps.Spell.fromId(id)
            if prioritySpell == nil and spell.isPrioritySpell then
                prioritySpell = spell
                LOG.debug("Set %s for next cast.", spell.name)
            end
        end
        if stype == "item" then
            priorityAction = kps.useItem(id)
        end
    end
end)

kps.lastCastedSpell = nil
kps.lastSentSpell = nil
kps.lastStartedSpell = nil

--[[
	-- Spell Object
	if spell ~= nil and not player.isCasting then
		if priorityAction ~= nil then
			priorityAction()
			priorityAction = nil
		elseif prioritySpell ~= nil then
			if prioritySpell.canBeCastAt("target") then
				prioritySpell.cast(target)
				LOG.warn("Priority Spell %s was casted.", prioritySpell)
				prioritySpell = nil
			else
				if prioritySpell.cooldown > 3 then prioritySpell = nil end
				if spell.name ~= nil then spell.cast(target,message) end
			end
		-- Cast Sequence Table
		elseif spell.name == nil and type(spell) == "table" then
			LOG.debug("Starting Cast-Sequence...")
			castSequenceIndex = 1
			castSequence = spell
			castSequenceStartTime = GetTime()
			castSequenceTarget = target
		else
			LOG.debug("Casting %s for next cast.", spell.name)
			spell.cast(target,message)
		end
	end
--]]

--[[
	if not kps["env"].player.isCasting then
		kps.runMacro(macroText)
	elseif kps["env"].player.isCasting and string.find(macroText,"/stopcasting") ~= nil then
		kps.runMacro("/stopcasting")
	end
--]]



