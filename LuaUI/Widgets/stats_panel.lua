--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  author:  Johan Hanssen Seferidis
--  date:    2011 Summer
--	license: GPL
--  description: GUI for the Damage Deal mod. Shows a panel with score and other
--               statistics
--
-- Panel's texture and fonts bound to it are depended on the panelX and panelY. 
-- Changing those coordinates changes the whole panel's position
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


function widget:GetInfo()
  return {
    name      = "Stats Panel",
    desc      = "Panel that keeps track of game statistics",
    author    = "Pithikos",
    date      = "Nov 01, 2010",
    license   = "GNU GPL, v2 or later",
    layer     = -9, 
    enabled   = true  --  loaded by default?
  }
end

-------------------------------------------------------------------------------


-- Make references to Spring's functions for speedup
local echo              = Spring.Echo
local GetGameSeconds    = Spring.GetGameSeconds
local Spring            = Spring
local gl, GL            = gl, GL
local gadgetHandler     = gadgetHandler
local math              = math
local GetGameRulesParam = Spring.GetGameRulesParam
local GetGameFrame      = Spring.GetGameFrame
local IsGameOver        = Spring.IsGameOver

-- Graphics
-- Paddings are counted in relation to the the panel outline
local panelWidth       = 240
local panelHeight      = 280

local head1LeftPadding   = 30  -- header 1
local head1BottomPadding = 255
local head1FontSize      = 20
local header1Font        = gl.LoadFont("fonts/texgyreheros-bold.otf", head1FontSize) -- , 45, 25

local cont1LeftPadding   = 14  -- container 1
local cont1BottomPadding = 228
local cont1FontSize      = 16

local head2LeftPadding   = 28  -- header 2
local head2BottomPadding = 144
local head2FontSize      = 20
local header2Font      = gl.LoadFont("fonts/texgyreheros-bold.otf", head2FontSize)

local cont2LeftPadding   = 14  -- container 2
local cont2BottomPadding = 118
local cont2FontSize      = 16

local head3LeftPadding   = 35  -- header 3
local head3BottomPadding = 6
local head3FontSize      = 20
local header3Font        = gl.LoadFont("fonts/UnDotum.ttf", head3FontSize)

local toolTipLeftPadding   = 35  -- toolTip
local toolTipBottomPadding = 6
local toolTipFontSize      = 12
local toolTipFont          = gl.LoadFont("fonts/UnDotum.ttf", toolTipFontSize)

local panelTopMargin   = 40
local panelLeftPadding = 10
local headerLeftMargin = 10
local panelTopPadding  = 30

local panelTexturePath = "images/panel.png"
local panelTexture     = nil
local displayList      = nil -- gl display list used for speedup of rendering
local panelRightMargin = 25

-- Constants
local dummyID=-1

-- Variables
local updatePanel=false
local initAlliancesN=1
local screenX, screenY
local panelX, panelY
local gameStarted=false
local gameOver=false
local toolTip=""
local panelHovered=false
local panelGrabbed=false

---------------------------------------------------------------------------------

-- Initializer
function widget:Initialize()
	if (GetGameFrame()>0) then
		gameStarted=true    -- in case widget reloaded ingame
		initAlliancesN=GetGameRulesParam("initAlliancesN")
	end
	gameOver=IsGameOver() -- in case widget reloaded ingame
	dummyID=GetGameRulesParam("dummyID")
	screenX, screenY = gl.GetViewSizes()
	panelX = screenX - panelWidth - panelRightMargin
	panelY = screenY              - panelTopMargin

	-- load graphics
	displayList = gl.CreateList( function() --returns a listID
    gl.Texture(panelTexturePath)
    gl.TexRect(panelX, panelY-panelHeight, panelX+panelWidth, panelY)
  end)
  
end


-- Flag the start of the game
function widget:GameStart()
	initAlliancesN=GetGameRulesParam("initAlliancesN")
	gameStarted=true
end


-- Flag the end of the game
function widget:GameOver()
	gameOver=true
end


-- Draw the GUI on screen
function widget:DrawScreen()
	gl.CallList(displayList) -- draw panel texture
	
	-- things to draw if game has started
	if (gameStarted) then
		-- show dummy's statistics
		header1Font:Print("Dummy", panelX+head1LeftPadding, panelY-(panelHeight-head1BottomPadding)) 
		local dummyHealth=GetGameRulesParam("dummyHealth")
		if (dummyHealth<0) then
			dummyHealth=0
		end
		local dummyMaxHealth=GetGameRulesParam("dummyMaxHealth")
		gl.Text("Health: "..math.ceil(dummyHealth).."/"..dummyMaxHealth, panelX+cont1LeftPadding, panelY-(panelHeight-cont1BottomPadding), cont1FontSize)
		-- show score
		header2Font:Print("Score", panelX+head2LeftPadding, panelY-(panelHeight-head2BottomPadding))
		local scoreStr=""
		local score=GetGameRulesParam("alliance1Score")
		for i=1, initAlliancesN do
			local score=GetGameRulesParam("alliance"..i.."Score")
			scoreStr=scoreStr.."Alliance "..i..": "..score.."\n"
		end
		gl.Text(scoreStr, panelX+cont2LeftPadding, panelY-(panelHeight-cont2BottomPadding), cont2FontSize)
		
		
	-- things do draw if game hasn't started
	else
		header1Font:Print("Dummy", panelX+head1LeftPadding, panelY-(panelHeight-head1BottomPadding)) 
		gl.Text("Once the game starts, dummy\nwill spawn in the center of\nthe map. Be aware that the\ndummy autoheals.", panelX+cont1LeftPadding, panelY-(panelHeight-cont1BottomPadding)+2, 14)
		header2Font:Print("How to win", panelX+head2LeftPadding, panelY-(panelHeight-head2BottomPadding))
		gl.Text("For every damage you do on the\ndummy, you get points. Once\nthe dummy is dead or all other\nteams are dead, the game is\nover. Team with highest score\n wins the game.", panelX+cont2LeftPadding, panelY-(panelHeight-cont2BottomPadding)+1, 14)
	end
	
	-- game over text
	if (gameOver) then
		local winningText=""
		local winner=GetGameRulesParam("winnerAllianceID")
		if (winner~=nil) then
			winner=winner+1
			winningText="Winner is Alliance "..winner
		else
			winningText="There is no winner"
		end
		header3Font:Print(winningText, panelX+head3LeftPadding, panelY-(panelHeight-head3BottomPadding)) 
	else
		toolTipFont:Print(toolTip, panelX+head3LeftPadding, panelY-(panelHeight-head3BottomPadding)) 
	end
	
end


-------------------------------------------------------------------------------
----------------------------- ON WIDGET CLOSING -------------------------------
-------------------------------------------------------------------------------


function widget:Shutdown()
  gl.DeleteList(displayList)
  gl.DeleteFont(header1Font)
  gl.DeleteFont(header2Font)
  gl.DeleteFont(header3Font)
  gl.DeleteFont(toolTipFont)
end


-------------------------------------------------------------------------------
-------------------------- MAKE THE PANEL MOVABLE -----------------------------
-------------------------------------------------------------------------------

local yGrabbed, xGrabbed -- coordinates of cursor when panel got grabbed
local xGrabbedOffset, yGrabbedOffset       -- distance from clicking pos to panelX and panelY

-- Update panel coordinates (in case the panel has been moved)
local function updatePanelCoords()
	panelX=panelX
	panelY=panelY
end


-- Hover cursor above panel
function widget:IsAbove(x, y)
	if (x>panelX and x<panelX+panelWidth and y<panelY and y>panelY-panelHeight) then
		panelHovered=true
		toolTip="Click and drag to move the panel"
	else
		toolTip=""
		panelHovered=false
	end
end


-- Click on the panel
function widget:MousePress(cursorX, cursorY, button)
	if (panelHovered) then
		panelGrabbed=true
		xGrabbedOffset=cursorX-panelX
		yGrabbedOffset=cursorY-panelY
		return true
	end
end


-- Move the panel
function widget:MouseMove(cursorX, cursorY, dx, dy, button)
	if (panelGrabbed) then
		panelX=cursorX-xGrabbedOffset
		panelY=cursorY-yGrabbedOffset
		-- update panel coordinates
		displayList = gl.CreateList( function()
			gl.Texture(panelTexturePath)
			gl.TexRect(panelX, panelY-panelHeight, panelX+panelWidth, panelY)
		end)
	end
end


-- Release panel to new position
function widget:MouseRelease(cursorX, cursorY, button)
	if (panelGrabbed) then
		panelGrabbed=false
	end
end
