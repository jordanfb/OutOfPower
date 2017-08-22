HelpMenu = {}

function HelpMenu:init(settings, globals, scores)
	self.settings = settings
	self.globals = globals
	self.screenX = 0
	self.screenY = -love.graphics.getHeight()
	self.x = 0 -- these get reset
	self.y = 0
	self.helpText = "Help/About:\nRunning Out of Power is a game made for the Ludum Dare #39 by Jordan Faas-Bush using LOVE2D.\n\nSelect a battery percentage with the slider on the home screen and then keep your computer's battery lower than that for as long as possible without sleeping or hibernating.\n\nThe symbols to the right of the scores indicate why you stopped that run. A face with Xs for eyes means the battery died. Three Zs means the computer fell asleep or hibernated. A yellow lightning bolt means you over charged it. A red X means that you stopped it using the back button or by quitting.\n\nFor additional challenge, try playing another game at the same time :P"
	self.backButton = {text = "back", x = 480-40, y = 270 - 40, width = 30, height = 30, highlighted = false}
end

function HelpMenu:draw(x, y)
	self.x = x-self.screenX
	self.y = y-self.screenY
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(self.globals.regularFont)
	love.graphics.printf(self.helpText, 10-self.x, 10-self.y, love.graphics.getWidth()-20)
	if self.backButton.highlighted then
		love.graphics.setColor(200, 200, 200)
	else
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.draw(self.globals.backIcon, -self.x+self.backButton.x, -self.y+self.backButton.y, 0, .5, .5)
	-- love.graphics.rectangle("fill", -self.x+self.backButton.x, -self.y+self.backButton.y, self.backButton.width, self.backButton.height)
	-- love.graphics.setColor(0, 0, 0)
	-- love.graphics.rectangle("line", -self.x+self.backButton.x, -self.y+self.backButton.y, self.backButton.width, self.backButton.height)
end

function HelpMenu:update(dt)
	self.backButton.highlighted = mouseOverRect(self.backButton.x-self.x, self.backButton.y-self.y, self.backButton.width, self.backButton.height)
end

function HelpMenu:mousepressed(x, y, button)
	if self.backButton.highlighted then
		moveToScene("mainmenu")
	end
end