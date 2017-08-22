io.stdout:setvbuf("no") -- this is so that sublime will print things when they come (rather than buffering).


--[[
Power States:
unknown
Cannot determine power status.
battery
Not plugged in, running on a battery.
nobattery
Plugged in, no battery available.
charging
Plugged in, charging battery.
charged
Plugged in, battery is fully charged.


love.system.getOS()
"OS X", "Windows", "Linux", "Android" or "iOS"
love.system.getPowerInfo()
success = love.system.openURL("url")
love.system.openURL("file://"..love.filesystem.getSaveDirectory())
love.filesystem.setIdentity("identity")
love.filesystem.append(filepath, text)
love.filesystem.write(filepath, text)
love.filesystem.exists(filepath)
for line in love.filesystem.lines("highscores.lst") do
love.filesystem.newFile( filename )


seems like 5% is the critical value
]]--

require "mainmenu"
require "helpmenu"
require "settingsmenu"
require "gameplay"

batterySeconds = 0

local globalX = 0
local globalY = 0
local lerpOriginX = 0
local lerpOriginY = 0
-- local lerpGoalX = 0
-- local lerpGoalY = 0

local lerpDx = 0
local lerpDy = 0
local lerpPercent = 1

local sceneTable = {mainmenu = {0, 0}, gameplay = {1, 0}, settings = {0, 1}, about = {0, -1}}

local settingsFilename = "settings.txt"
local scoresFilename = "scores.txt"
local loggingFilename = "logs.txt"

local settings = {drawPublicity = true, minimumDifficulty = 0, os = "", currentPercent = 0, allowStartingLow = false, forceWindowsFive = true}
local highscores = {}
local publicity = {itch = love.graphics.newImage("logo_color.png"), twitter = love.graphics.newImage("TwitterLogo_#55acee.png")}
local globals = {difficultyFont = love.graphics.newFont(40), regularFont = love.graphics.newFont(12), settingsFilename = settingsFilename,
				scoresFilename = scoresFilename, loggingFilename = loggingFilename, scores = {},

				settingsIcon = love.graphics.newImage("settingsicon.png"), scoreIcon = love.graphics.newImage("scoreicon.png"), helpIcon = love.graphics.newImage("helpicon.png"),
				backIcon = love.graphics.newImage("backicon.png"), powerIcon = love.graphics.newImage("powericon.png"), deadIcon = love.graphics.newImage("deadicon.png"),
				quitIcon = love.graphics.newImage("quiticon.png"), sleepIcon = love.graphics.newImage("sleepicon.png")}


local twitterHighlighted = false
local itchHighlighted = false

function love.load(args)
	love.filesystem.setIdentity("RunningOutOfPower")
	love.window.setMode(1920/4, 1080/4, {resizable = false, fullscreen = false})
	love.window.setTitle("Running Out of Power")
	settings.os = love.system.getOS()

	loadScores(scoresFilename)
	loadSettings(settingsFilename)
	if settings.forceWindowsFive and settings.os == "Windows" then
		settings.minimumDifficulty = 5
	end

	MainMenu:init(settings, globals)
	HelpMenu:init(settings, globals)
	SettingsMenu:init(settings, globals)
	Gameplay:init(settings, globals)
end

function love.update(dt)
	local powerType, powerPercent, powerSeconds = love.system.getPowerInfo()
	-- print(love.system.getPowerInfo())
	-- if powerSeconds and powerSeconds > batterySeconds then
	-- 	print("BATTERY INREASING OH MY GOD OH MY DEAR OH ME")
	-- end
	batterySeconds = powerSeconds
	settings.currentPercent = powerPercent
	-- print(powerPercent, batterySeconds)

	love.graphics.setBackgroundColor(getBatteryColor(powerPercent))
	MainMenu:update(dt)
	HelpMenu:update(dt)
	SettingsMenu:update(dt)
	Gameplay:update(dt)

	if lerpPercent < 1 then
		-- thanks to https://chicounity3d.wordpress.com/2014/05/23/how-to-lerp-like-a-pro/ for the formula here, I quite like it!
		globalX = lerpOriginX + lerpDx * (lerpPercent*lerpPercent*lerpPercent * (lerpPercent * (6*lerpPercent - 15) + 10)) 
		globalY = lerpOriginY + lerpDy * (lerpPercent*lerpPercent*lerpPercent * (lerpPercent * (6*lerpPercent - 15) + 10))
		lerpPercent = lerpPercent + dt*2
		if lerpPercent > 1 then
			lerpPercent = 1
		end
	end
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	if settings.drawPublicity then
		twitterHighlighted = false
		itchHighlighted = false
		for k, v in pairs(sceneTable) do
			drawPublicity(v[1]*love.graphics.getWidth(), v[2]*love.graphics.getHeight())
		end
	end

	MainMenu:draw(globalX, globalY)
	HelpMenu:draw(globalX, globalY)
	SettingsMenu:draw(globalX, globalY)
	Gameplay:draw(globalX, globalY)
end

function drawPublicity(x, y)
	x = x + globalX
	y = y + globalY
	if mouseOverRect(10-x, love.graphics.getHeight()-40-y, 98, 30) then
		love.graphics.setColor(210, 210, 210)
		itchHighlighted = true
	else
		love.graphics.setColor(255, 255, 255)
	end
	drawImageScaled(publicity.itch, 10-x, love.graphics.getHeight()-40-y, 100, 30)
	if mouseOverRect(120-x, love.graphics.getHeight()-40-y, 130, 30) then
		love.graphics.setColor(210, 210, 210)
		twitterHighlighted = true
	else
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.rectangle("fill", 120-x, love.graphics.getHeight()-40-y, 130, 30)
	drawImageScaled(publicity.twitter, 120-x, love.graphics.getHeight()-40-y, 100, 50)
	-- love.graphics.setColor(0, 0, 0)
	love.graphics.setColor(85, 172, 238)
	love.graphics.print("@quickpocket", 150-x, love.graphics.getHeight()-31-y)
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.quit()
	elseif key == "up" then
		globalY = globalY - 10
	elseif key == "down" then
		globalY = globalY + 10
	elseif key == "left" then
		globalX = globalX - 10
	elseif key == "right" then
		globalX = globalX + 10
	end
end

function love.quit()
	Gameplay:quit()
end

function love.keyreleased(key, unicode)
	--
end

function love.mousepressed(x, y, button)
	MainMenu:mousepressed(x, y, button)
	HelpMenu:mousepressed(x, y, button)
	SettingsMenu:mousepressed(x, y, button)
	Gameplay:mousepressed(x, y, button)
	if itchHighlighted then
		love.system.openURL("https://jordanfb.itch.io")
	elseif twitterHighlighted then
		love.system.openURL("https://twitter.com/quickpocket")
	end
end

function love.mousereleased(x, y, button)
	MainMenu:mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
	MainMenu:mousemoved(x, y, dx, dy)
end

function love.resize(w, h)
	--
end


function loadScores(filename)
	-- loads the highscores from a file
	if not love.filesystem.exists(scoresFilename) then
		return -- it doesn't exist!
	end

	local scoreTable = {0, "", 0, ""}
	local lineNumber = 1
	for line in love.filesystem.lines(scoresFilename) do
		if #line > 0 then
			if lineNumber == 1 then
				scoreTable[1] = tonumber(line)
			elseif lineNumber == 2 then
				scoreTable[2] = line
			elseif lineNumber == 3 then
				scoreTable[3] = tonumber(line)
			elseif lineNumber == 4 then
				scoreTable[4] = line
			end
			lineNumber = lineNumber + 1
			if lineNumber > 4 then
				-- add it to the score record
				local found = false
				for i = 1, #globals.scores do
					if globals.scores[i][3] < scoreTable[3] then
						table.insert(globals.scores, i, scoreTable)
						found = true
						break
					end
				end
				if not found then
					table.insert(globals.scores, scoreTable)
				end
				scoreTable = {}
				lineNumber = 1
			end
		end
	end
end

-- function saveHighscore(filename)
-- 	-- saves the highscore to the file -- creates the file first if needed
-- end

function loadSettings(filename)
	-- if the file doesn't exist, then sucks to be you
	if not love.filesystem.exists(filename) then
		return
	end
	-- loads the settings
	local lineNum = 1
	local k = ""
	for line in love.filesystem.lines(filename) do
		if #line > 0 then
			if lineNum % 2 == 1 then
				k = line
			else
				if line == "true" then
					settings[k] = true
				else
					settings[k] = false
				end
			end
			lineNum = lineNum + 1
		end
	end
end

function saveSettings(filename)
	-- saves them. You get the drill
	local saveString = ""
	for k, v in pairs(settings) do
		if type(v) == type(true) then
			saveString = saveString .. k .. "\n"
			saveString = saveString .. tostring(v) .."\n"
			-- love.filesystem.append(filename, k.."\n")
			-- love.filesystem.append(filename, tostring(v).."\n")
		end
	end
	love.filesystem.write(filename, saveString)
end



-- Converts HSL to RGB. (input and output range: 0 - 255)
-- taken from the love2d wiki: https://love2d.org/wiki/HSL_color
-- written by Taehl: https://love2d.org/wiki/User:Taehl
function HSL(h, s, l, a)
	if not a then -- I added this part because I'm not really using alphas
		a = 255
	end
	if s<=0 then return l,l,l,a end
	h, s, l = h/256*6, s/255, l/255
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return (r+m)*255,(g+m)*255,(b+m)*255,a
end

function getBatteryColor(percent)
	return HSL(80*percent/100, 255, 180, 255)
end

function drawImageScaled(image, x, y, width, height)
	local scale = math.floor(height/image:getHeight()*100)/100
	love.graphics.draw(image, x, y, 0, scale, scale)
	-- print(height/image:getHeight()*image:getWidth())
end

function mouseOverRect(x, y, width, height)
	if not height then
		-- you passed in a table as x, so use the contents
		height = x.height
		width = x.width
		y = x.y
		x = x.x
	end
	local mx = love.mouse.getX()
	local my = love.mouse.getY()
	return mx > x and mx < x + width and my > y and my < y + height
end

function moveToScene(sceneName)
	-- changes the coordinates to the cordinates for the scene
	if not sceneTable[sceneName] then
		return -- the scene doesn't exist
	end
	lerpOriginX = globalX
	lerpOriginY = globalY
	-- lerpGoalX = sceneTable[sceneName][1]*love.graphics.getWidth()
	-- lerpGoalY = sceneTable[sceneName][2]*love.graphics.getHeight()
	lerpDx = sceneTable[sceneName][1]*love.graphics.getWidth() - globalX
	lerpDy = sceneTable[sceneName][2]*love.graphics.getHeight() - globalY
	lerpPercent = 0
end

function love.wheelmoved(x, y)
	Gameplay:wheelmoved(x, y)
end