--[[
Player State: Functions which handle player state
]]--

local Player = kps.Player.prototype

local movementStarted = nil
local movementStopped = 0

kps.events.register("PLAYER_STARTED_MOVING", function ()
    movementStarted = GetTime()
    movementStopped = nil
end)
kps.events.register("PLAYER_STOPPED_MOVING", function ()
    movementStarted = nil
    movementStopped = GetTime()
end)

--[[[
@function `<PLAYER>.isMoving` - returns true if the player is currently moving - oppposed to the `<UNIT>.isMoving` this one is more reliable.
]]--
function Player.isMoving(self)
    return movementStopped == nil
end

--[[[
@function `<PLAYER>.isMovingSince(<SECONDS>)` - returns true if the player is currently moving - oppposed to the `<UNIT>.isMoving` this one is more reliable.
]]--
function Player.isMovingSince(self)
    return function (seconds)
        if movementStarted ~= nil then
            return GetTime()-movementStarted > seconds
        end
        return false
    end
end

--[[[
@function `<PLAYER>.isNotMovingSince(<SECONDS>)` - returns true if the player is currently not moving for the given amount of seconds.
]]--
function Player.isNotMovingSince(self)
    return function (seconds)
        if movementStopped ~= nil then
            return GetTime()-movementStopped > seconds
        end
        return false
    end
end
