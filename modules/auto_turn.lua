--[[
AutoTurn Module
]]--


-- another example
function _JumpOrAscendStart()
   secured = false
   while not secured do
      RunScript([[
         for index = 1, 100 do
            if not issecure() then
               return
            end
         end
         secured = true
         JumpOrAscendStart()
      ]])
   end
end

function _CameraOrSelectOrMoveStop()
   secured = false
   while not secured do
      RunScript([[
         for index = 1, 100 do
            if not issecure() then
               return
            end
         end
         secured = true
         CameraOrSelectOrMoveStop()
      ]])
   end
end

function _CameraOrSelectOrMoveStart()
   secured = false
   while not secured do
      RunScript([[
         for index = 1, 100 do
            if not issecure() then
               return
            end
         end
         secured = true
         CameraOrSelectOrMoveStart()
      ]])
   end
end

function _TurnLeftStart()
   secured = false
   while not secured do
      RunScript([[
         for index = 1, 100 do
            if not issecure() then
               return
            end
         end
         secured = true
         TurnLeftStart()
      ]])
   end
end

function _TurnLeftStop()
   secured = false
   while not secured do
      RunScript([[
         for index = 1, 100 do
            if not issecure() then
               return
            end
         end
         secured = true
         TurnLeftStop()
      ]])
   end
end

local LOG = kps.Logger(kps.LogLevel.INFO)

kps.events.register("UI_ERROR_MESSAGE", function(event_type, event_error)
      if kps.enabled and kps.autoTurn and (event_error == SPELL_FAILED_UNIT_NOT_INFRONT) then -- or (event_error == ERR_BADATTACKFACING)
         if kps["env"].player.isMoving == false then
            if kps.timers.check("Facing") == 0 then kps.timers.create("Facing", 1) end
            _TurnLeftStart()
            _CameraOrSelectOrMoveStart()
            C_Timer.After(1,function() _TurnLeftStop() end)
            C_Timer.After(1,function() _CameraOrSelectOrMoveStop() end)
         end
      end
end)

local function disableTurningAfterCombat()
   if kps.timers.check("Facing") > 0 then
      _TurnLeftStop()
      _CameraOrSelectOrMoveStop()
   end
end
kps.events.register("PLAYER_REGEN_ENABLED", disableTurningAfterCombat)
kps.events.register("PLAYER_UNGHOST", disableTurningAfterCombat)

kps.events.register("UNIT_SPELLCAST_START", function(...)
      if kps.autoTurn and kps.timers.check("Facing") > 0 then
         local unitID = select(1,...)
         if unitID == "player" then 
            TurnLeftStop()
            CameraOrSelectOrMoveStop()
         end
      end
end)

--[[
"UNIT_SPELLCAST_SENT" Fired when an event is sent to the server
"UNIT_SPELLCAST_START" Fired when a unit begins casting
"UNIT_SPELLCAST_SUCCEEDED" Fired when a spell is cast successfully
]]--

function removeBagItems()
	for bag = 0,4,1 do
		for slot = 1, GetContainerNumSlots(bag), 1 do
			local name = GetContainerItemLink(bag,slot)
			if name and string.find(name,"ff9d9d9d") then 
				PickupContainerItem(bag,slot)
				DeleteCursorItem()
			end
		end 
	end
end