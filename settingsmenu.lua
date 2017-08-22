SettingsMenu = {}

function SettingsMenu:init(settings, globals, scores)
	self.settings = settings
	self.globals = globals
	self.screenX = 0
	self.screenY = love.graphics.getHeight()
	self.x = 0 -- these get reset
	self.y = 0
	self.helpText = "Settings:"
	self.backButton = {text = "back", x = 480-40, y = 270 - 40, width = 30, height = 30, highlighted = false}

	-- settings options
	self.forceWindowsCheckbox = {label = "Account for Windows hibernating at 5%", setting = "forceWindowsFive", x = 20, y = 90, width = 30, height = 30, highlighted = false}
	self.drawPublicity = {label = "Show my publicity links", setting = "drawPublicity", x = 20, y = 50, width = 30, height = 30, highlighted = false}
end

function SettingsMenu:draw(x, y)
	self.x = x-self.screenX
	self.y = y-self.screenY
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(self.globals.regularFont)
	love.graphics.printf(self.helpText, 10-self.x, 20-self.y, love.graphics.getWidth()-20)
	if self.backButton.highlighted then
		love.graphics.setColor(200, 200, 200)
	else
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.draw(self.globals.backIcon, -self.x+self.backButton.x, -self.y+self.backButton.y, 0, .5, .5)
	-- love.graphics.rectangle("fill", -self.x+self.backButton.x, -self.y+self.backButton.y, self.backButton.width, self.backButton.height)
	-- love.graphics.setColor(0, 0, 0)
	-- love.graphics.rectangle("line", -self.x+self.backButton.x, -self.y+self.backButton.y, self.backButton.width, self.backButton.height)

	self:drawCheckbox(self.forceWindowsCheckbox)
	self:drawCheckbox(self.drawPublicity)
end

function SettingsMenu:update(dt)
	self.backButton.highlighted = mouseOverRect(self.backButton.x-self.x, self.backButton.y-self.y, self.backButton.width, self.backButton.height)

	self.forceWindowsCheckbox.highlighted = mouseOverRect(self.forceWindowsCheckbox.x-self.x, self.forceWindowsCheckbox.y-self.y, self.forceWindowsCheckbox.width, self.forceWindowsCheckbox.height)
	self.drawPublicity.highlighted = mouseOverRect(self.drawPublicity.x-self.x, self.drawPublicity.y-self.y, self.drawPublicity.width, self.drawPublicity.height)

end

function SettingsMenu:mousepressed(x, y, button)
	if self.backButton.highlighted then
		moveToScene("mainmenu")
		saveSettings(self.globals.settingsFilename)
	end
	if self.forceWindowsCheckbox.highlighted then
		self.settings[self.forceWindowsCheckbox.setting] = not self.settings[self.forceWindowsCheckbox.setting]
		if self.settings[self.forceWindowsCheckbox.setting] and self.settings.os == "Windows" then
			-- force it to be 5
			self.settings.minimumDifficulty = 5
		else
			self.settings.minimumDifficulty = 0
		end
	end
	if self.drawPublicity.highlighted then
		self.settings[self.drawPublicity.setting] = not self.settings[self.drawPublicity.setting]
	end
end

function SettingsMenu:drawCheckbox(checkbox)
	if checkbox.highlighted then
		love.graphics.setColor(200, 200, 200)
	else
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.rectangle("fill", -self.x+checkbox.x, -self.y+checkbox.y, checkbox.width, checkbox.height)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", -self.x+checkbox.x, -self.y+checkbox.y, checkbox.width, checkbox.height)
	if self.settings[checkbox.setting] then
		-- draw the X
		love.graphics.line(-self.x+checkbox.x, -self.y+checkbox.y, -self.x+checkbox.x+checkbox.width, -self.y+checkbox.y+checkbox.height)
		love.graphics.line(-self.x+checkbox.x, -self.y+checkbox.y+checkbox.height, -self.x+checkbox.x+checkbox.width, -self.y+checkbox.y)
	end
	love.graphics.setFont(self.globals.regularFont)
	love.graphics.print(checkbox.label, -self.x+checkbox.x+checkbox.width+10, -self.y+checkbox.y+checkbox.height/3)
end