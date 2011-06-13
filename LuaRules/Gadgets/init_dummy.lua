--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  author:  Johan Hanssen Seferidis
--  date:    2011 June 5th
--	license: GPL
--  description: * sets zombie in the middle of the map
--               * sets resources
--							 * declares globals
--
--  dummy is a unit or structure that will be the tool of sodomy
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Spawn Dummy",
		desc      = "Spawns dummy in the beginning of the game",
		author    = "Johan Hanssen Seferidis/aka Pithikos",
		date      = "June, 2011",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- synced only
if (not gadgetHandler:IsSyncedCode()) then
	return false
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- References
local echo              = Spring.Echo
local SetGameRulesParam = Spring.SetGameRulesParam

--when gadget loads
function gadget:Initialize()
	gaiaTeamID = Spring.GetGaiaTeamID()
	Spring.SetTeamResource(gaiaTeamID, "ms", 1000)
	Spring.SetTeamResource(gaiaTeamID, "es", 1000)
	spawnDummy()
end

--coords used are in gl format(x=width, z=height, y=elevation)
function spawnDummy()
	x = Game.mapSizeX/2
	z = Game.mapSizeZ/2
	y = Spring.GetGroundHeight(x, z)
	local dummyID=-2
	if (y>=0) then
		dummyID=Spring.CreateUnit("dummy", x, y, z, "south", gaiaTeamID);   -- land dummy to be spawned
	else
	  dummyID=Spring.CreateUnit("dummy", x, y, z, "south", gaiaTeamID);   -- sea dummy to be spawned
	end
	SetGameRulesParam("dummyID", dummyID)                                 -- save dummy ID to game table
end
