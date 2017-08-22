
--[[
This is the main menu class.
It main menus.
]]

MainMenu = {}

function MainMenu:init(settings, globals)
	-- we don't need to bother with making this a real class, since we don't have to duplicate this.
	self.settings = settings
	self.globals = globals
	self.settings.difficulty = 0
	self.sliderOffset = 50
	self.x = 0
	self.y = 0

	self.sliderWidth = 20
	self.sliderHeight = 40
	self.sliderX = 0 -- will get reset
	self.sliderY = 125 -- the center of the slider
	self.sliderSelected = false
	self.sliderBarHeight = 10

	self.screenCoords = {x = 0, y = 0} --{love.graphics.getWidth()*0, love.graphics.getHeight()*0}

	self.asteriskText = "" -- the help text for the slider
	self.asteriskX = 0
	self.asteriskY = 50
	self.asteriskHitbox = 30
	self.showAsteriskHelp = false

	self.difficultyX = 320--love.graphics.getWidth()/2
	self.difficultyY = 50--love.graphics.getHeight()/6
	print(love.graphics.getWidth(), love.graphics.getHeight())

	self.helpButton = {text = "help", x = 480-40, y = 270 - 40, width = 30, height = 30}
	self.settingsButton = {text = "settings", x = 480-85, y = 270 - 40, width = 30, height = 30}

	self.playButton = {text = "Play", x = love.graphics.getWidth()/2, y = 175, width = 100, height = 50, hovered = false, hoverColor = {100, 230, 100}, color = {100, 255, 100}, collisionBox = {}}
end

function MainMenu:draw(x, y)
	-- we pass in the x and y so that we can slide it off screen.
	self.x = x - self.screenCoords.x
	self.y = y - self.screenCoords.y
	self:drawSliderBar()
	if self.sliderSelected then
		love.graphics.setColor(255, 255, 255, 100)
		local r, g, b, a = getBatteryColor(self.settings.difficulty)
		love.graphics.setColor(r, g, b, 200)
	else
		love.graphics.setColor(230, 230, 230)
		love.graphics.setColor(getBatteryColor(self.settings.difficulty))
	end
	self.sliderX = (self.settings.difficulty/100)*(love.graphics.getWidth() - self.sliderOffset*2) + self.sliderOffset - self.sliderWidth /2
	love.graphics.rectangle("fill", self.sliderX-self.x, self.sliderY-self.sliderHeight/2-self.y, self.sliderWidth, self.sliderHeight, 0, 5, 5)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", self.sliderX-self.x, self.sliderY-self.sliderHeight/2-self.y, self.sliderWidth, self.sliderHeight, 0, 5, 20)
	-- draw the difficulty here:
	love.graphics.setFont(self.globals.difficultyFont)
	local difficultyDisplay = self.settings.difficulty.."%"
	love.graphics.print("Difficulty: ", -self.x + self.difficultyX-self.globals.difficultyFont:getWidth("Difficulty: "), -self.y + self.difficultyY)
	love.graphics.print(difficultyDisplay, -self.x + self.difficultyX, -self.y + self.difficultyY)
	if self.showAsterisk then
		self.asteriskX = self.difficultyX + self.globals.difficultyFont:getWidth(difficultyDisplay)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("*", -self.x + self.asteriskX, -self.y + self.asteriskY)
	end
	love.graphics.setFont(self.globals.regularFont)
	-- draw the help if needed
	if self.showAsteriskHelp then
		-- love.graphics.setFont(self.globals.regularFont)
		local width, lines = self.globals.regularFont:getWrap(self.asteriskText, 200)
		local height = self.globals.regularFont:getHeight() * #lines
		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("fill", math.min(love.mouse.getX()+10, love.graphics.getWidth()-200), love.mouse.getY()+10, 200, height, 5, 5)
		love.graphics.setColor(0, 0, 0)
		love.graphics.printf(self.asteriskText, math.min(love.mouse.getX()+10, love.graphics.getWidth()-200), love.mouse.getY()+10, 200)
	end
	-- draw the play button:
	if self.playButton.hovered then
		love.graphics.setColor(self.playButton.hoverColor)
	else
		love.graphics.setColor(self.playButton.color)
	end
	love.graphics.rectangle("fill", -self.x+self.playButton.x-self.playButton.width/2, -self.y+self.playButton.y-self.playButton.height/2, self.playButton.width, self.playButton.height)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", -self.x+self.playButton.x-self.playButton.width/2, -self.y+self.playButton.y-self.playButton.height/2, self.playButton.width, self.playButton.height)
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(self.globals.difficultyFont)
	love.graphics.printf(self.playButton.text,  -self.x+self.playButton.x-self.playButton.width/2, -self.y+self.playButton.y-self.playButton.height/2, self.playButton.width, "center")

	if self.helpButton.highlighted then
		love.graphics.setColor(200, 200, 200)
	else
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.draw(self.globals.helpIcon, -self.x+self.helpButton.x, -self.y+self.helpButton.y, 0, .5, .5)
	-- love.graphics.rectangle("fill", -self.x+self.helpButton.x, -self.y+self.helpButton.y, self.helpButton.width, self.helpButton.height)
	-- love.graphics.setColor(0, 0, 0)
	-- love.graphics.rectangle("line", -self.x+self.helpButton.x, -self.y+self.helpButton.y, self.helpButton.width, self.helpButton.height)

	if self.settingsButton.highlighted then
		love.graphics.setColor(200, 200, 200)
	else
		love.graphics.setColor(255, 255, 255)
	end
	-- love.graphics.rectangle("fill", -self.x+self.settingsButton.x, -self.y+self.settingsButton.y, self.settingsButton.width, self.settingsButton.height)
	-- love.graphics.setColor(0, 0, 0)
	-- love.graphics.rectangle("line", -self.x+self.settingsButton.x, -self.y+self.settingsButton.y, self.settingsButton.width, self.settingsButton.height)
	love.graphics.draw(self.globals.settingsIcon, -self.x+self.settingsButton.x, -self.y+self.settingsButton.y, 0, .5, .5)
end

function MainMenu:update(dt)
	self:setCharge()
	-- if not self.settings.allowStartingLow then
	-- 	self.settings.difficulty = math.max(self.settings.difficulty, self.settings.currentPercent)
	-- end
	self.showAsteriskHelp = mouseOverRect(self.asteriskX-self.x, self.asteriskY-self.y, self.asteriskHitbox, self.asteriskHitbox)
	self.playButton.collisionBox = {x = self.playButton.x - self.playButton.width/2-self.x, y = self.playButton.y - self.playButton.height/2-self.y,
								width = self.playButton.width, height = self.playButton.height}
	self.playButton.hovered = mouseOverRect(self.playButton.collisionBox)

	self.helpButton.highlighted = mouseOverRect(self.helpButton.x-self.x, self.helpButton.y-self.y, self.helpButton.width, self.helpButton.height)
	self.settingsButton.highlighted = mouseOverRect(self.settingsButton.x-self.x, self.settingsButton.y-self.y, self.settingsButton.width, self.settingsButton.height)
end

function MainMenu:setCharge()
	-- adjusts the difficulty slider etc. if the charge is too high, assuming the settings say to do so.
	local source, percent, time = love.system.getPowerInfo()
	if not self.settings.allowStartingLow and not Gameplay.isPlaying then
		-- force the player to select a charge that's equal or greater than the current charge of the computer
		self.settings.difficulty = math.max(self.settings.difficulty, percent)
	end
end

function MainMenu:mousepressed(x, y, button)
	x = x + self.x
	y = y + self.y
	if self:isMouseOverSlider(x, y) then
		self.sliderSelected = true
	end
	if self.playButton.hovered then
		-- swap to the play scene.
		moveToScene("gameplay")
		Gameplay:startRun() -- start the run, duh. This is in gameplay.lua
	elseif self.helpButton.highlighted then
		moveToScene("about")
	elseif self.settingsButton.highlighted then
		moveToScene("settings")
	end
end

function MainMenu:mousemoved(x, y, dx, dy)
	x = x + self.x
	y = y + self.y
	-- drag the slider if it's down...
	if self.sliderSelected then
		local minDifficultyCharge = 0
		if not self.settings.allowStartingLow then
			minDifficultyCharge = self.settings.currentPercent
		end
		local goalDifficulty = (x-self.sliderOffset) / (love.graphics.getWidth() - self.sliderOffset*2)*100
		if math.floor(goalDifficulty) <= minDifficultyCharge and math.floor(goalDifficulty) < 100 then
			self.asteriskText = "The difficulty must be greater than or equal to your current battery charge in order to immediately play. Change this in the settings."
			self.showAsterisk = true
		elseif math.floor(goalDifficulty) <= self.settings.minimumDifficulty and math.floor(goalDifficulty) ~= 0 then
			self.asteriskText = "By default Windows computers hibernate at 5% battery. Change the game's limit in the settings."
			self.showAsterisk = true
		else
			self.showAsterisk = false
		end
		goalDifficulty = math.max(math.max(math.min(100, goalDifficulty), minDifficultyCharge), self.settings.minimumDifficulty)
		self.settings.difficulty = math.floor(goalDifficulty)
	end
end

function MainMenu:mousereleased(x, y, button)
	if self.sliderSelected then
		self.sliderSelected = false
	end
end

function MainMenu:drawSliderBar()
	local startX = -self.x + self.sliderOffset
	local startY = -self.y + self.sliderY
	local width = love.graphics.getWidth() - self.sliderOffset*2
	-- draw the entire bar
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", startX, startY, width, self.sliderBarHeight)
	-- then draw the levels that you can't do
	love.graphics.setColor(255, 0, 0)
	local maxDifficulty = 100
	if not self.settings.allowStartingLow then
		maxDifficulty = self.settings.currentPercent
	end
	local allowedwidth = width * maxDifficulty/100
	love.graphics.rectangle("fill", startX, startY, allowedwidth, self.sliderBarHeight)
	love.graphics.setColor(100, 100, 100)
	notAllowedWidth = width * self.settings.minimumDifficulty/100
	love.graphics.rectangle("fill", startX, startY, notAllowedWidth, self.sliderBarHeight)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", startX, startY, width, self.sliderBarHeight)
end

function MainMenu:isMouseOverSlider(mx, my)
	-- mx = mx - self.sliderOffset
	-- local xCorrect =  mx > (self.settings.difficulty/100)*(love.graphics.getWidth() - self.sliderOffset*2) - self.sliderWidth/2 and mx < (self.settings.difficulty/100)*(love.graphics.getWidth() - self.sliderOffset*2) + self.sliderWidth/2
	local xCorrect = mx > self.sliderX and mx < self.sliderX + self.sliderWidth
	local yCorrect = my > self.sliderY - self.sliderHeight/2 and my < self.sliderY + self.sliderHeight/2
	return xCorrect and yCorrect
end