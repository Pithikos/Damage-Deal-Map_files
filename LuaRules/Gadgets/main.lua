--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  author:  Johan Hanssen Seferidis
--  date:    2011 June 5th
--	license: GPL
--  description: checks for winning conditions,
--               updates the game table(read README.txt for more info)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


function gadget:GetInfo()
	return {
		name      = "Main module",
		desc      = "Keeps track of winning conditions",
		author    = "Johan Hanssen Seferidis/aka Pithikos",
		date      = "June, 2011",
		license   = "GPL",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end




--------------------------------------------------------------------------------

-- skip if not synced
if (not gadgetHandler:IsSyncedCode()) then
	return false
end



--------------------------------------------------------------------------------
---------------------------------IDENTIFIERS------------------------------------
--------------------------------------------------------------------------------



-- References
local echo              = Spring.Echo
local DestroyUnit       = Spring.DestroyUnit
local GetTeamUnits      = Spring.GetTeamUnits
local AreTeamsAllied    = Spring.AreTeamsAllied
local GetGameRulesParam = Spring.GetGameRulesParam
local SetGameRulesParam = Spring.SetGameRulesParam
local GetUnitHealth     = Spring.GetUnitHealth

-- Constants
local dummyID
local dummyTeamID=-1
local dummyMaxHealth
local initAlliancesN=0 -- the number of alliances at the beginning of the game

-- Variables
local dummyHealth





--------------------------------------------------------------------------------
---------------------------------CALLINS----------------------------------------
--------------------------------------------------------------------------------


---- Setup game vars and consts at the beginning of the game ----
function gadget:GameStart()
	
	-- set some gamerules constants once the game starts
	dummyID=GetGameRulesParam("dummyID")
	dummyTeamID=Spring.GetGaiaTeamID()                     -- here dummy belongs to gaia team
	SetGameRulesParam("dummyTeamID", dummyTeamID)
	dummyMaxHealth=GetUnitHealth(dummyID)
	SetGameRulesParam("dummyMaxHealth", dummyMaxHealth)
	SetGameRulesParam("dummyHealth", dummyMaxHealth)
	initAlliancesN=(#Spring.GetAllyTeamList())-1           -- -1 because the dummy team is not included
	SetGameRulesParam("initAlliancesN", initAlliancesN)

	-- initiate team score variables
	for i=1, initAlliancesN do
		SetGameRulesParam("alliance"..i.."Score", 0)
	end
end


---- Record damage done to dummy ----
function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
	if (unitID==dummyID) then
	
		-- update dummy's health global
		dummyHealth=GetUnitHealth(dummyID)
		SetGameRulesParam("dummyHealth", dummyHealth)
		
		-- update score
		if (attackerTeam) then -- there is no attackerTeam if the dummy gets damaged by side effects(explosions, etc.)
			local _,_,_,_,_,allianceID = Spring.GetTeamInfo(attackerTeam)
			local scoreKey="alliance"..(allianceID+1).."Score"
			local oldScore=GetGameRulesParam(scoreKey);
			local newScore=oldScore + damage
			newScore=math.ceil(newScore)
			SetGameRulesParam(scoreKey, newScore)
		end
	end
end


---- Update dummy's health ----
function gadget:UnitPreDamaged() -- As long as UnitRepaired() is not available, this only adds to speed when recording a decrease in dummy's health
	dummyHealth=GetUnitHealth(dummyID)
	if (dummyHealth) then
		SetGameRulesParam("dummyHealth", dummyHealth)
	end
end
function gadget:GameFrame(frame) -- This should be replaced with a UnitRepaired() callin once it's developed
	if (frame%15==0) then
		dummyHealth=GetUnitHealth(dummyID)
		if (dummyHealth) then
			SetGameRulesParam("dummyHealth", dummyHealth)
		end
	end
end


---- Check if dummy is killed ----
function gadget:UnitDestroyed(unitID, unitDefID, unitTeamID, attackerID)
	if (unitID==dummyID) then

		-- get alliance with highest score
		local maxScore=0;
		local winnerAllianceID=-1;
		for i=1, initAlliancesN do
			local score=GetGameRulesParam("alliance"..i.."Score")
			if (score>maxScore) then
				maxScore=score;
				winnerAllianceID=i-1;
			end
		end
		SetGameRulesParam("winnerAllianceID", winnerAllianceID)

		-- kill all enemies(gaia included)
		winnerTeams=Spring.GetTeamList(winnerAllianceID);
		if (winnerAllianceID>-1) then
			killAllEnemies(winnerTeams[1])
		else
			killAllEnemies(dummyID)
		end
	end
end




--------------------------------------------------------------------------------
-----------------------------LOCAL FUNCTIONS------------------------------------
--------------------------------------------------------------------------------



-- Kill everyone but given team's allies and himself (kills even Gaia)
function killAllEnemies(survivorTeamID)
	local teams=Spring.GetTeamList()
	for k, teamID in pairs(teams) do
		if (k~="n") then
			if (not AreTeamsAllied(teamID, survivorTeamID)) then
				local teamUnits = GetTeamUnits(teamID)
				for _, unitID in pairs(teamUnits) do
					DestroyUnit(unitID)
				end
			end
		end
  end
end
