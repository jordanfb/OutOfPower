--[[
This is pretty much just a scoreboard that goes up...

scores are saved as {difficulty, time started, score/time run, reason for ending, } -- anything else needed? I don't think so...
]]


Gameplay = {}

function Gameplay:init(settings, globals, scores)
	self.settings = settings
	self.globals = globals
	self.scores = scores

	if love.filesystem.exists(self.globals.loggingFilename) then
		-- it ran out of power
		local scoreTable = {0, "", 0, ""}
		for line in love.filesystem.lines(self.globals.loggingFilename) do
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
					lineNumber = 1
				end
			end
		end
		scoreTable[4] = "dead"
		self:saveScore(scoreTable[1], scoreTable[2], scoreTable[3], scoreTable[4])
		self:addScore(scoreTable)
		-- now we've added that score, so delete the file
		love.filesystem.remove(self.globals.loggingFilename)
	end

	self.x = 0
	self.y = 0
	self.screenX = love.graphics.getWidth()
	self.screenY = 0

	self.scrollValue = 0 -- 0 is centered on the current score

	self.deadMansTimer = 0
	self.isPlaying = false
	self.score = 0
	self.startTime = 0

	self.logScoreTimer = 0 -- every second save the score to the log file
	self.backButton = {text = "back", x = 480-40, y = 270 - 40, width = 30, height = 30, highlighted = false}
end

function Gameplay:draw(x, y)
	self.x = x-self.screenX
	self.y = y-self.screenY

	self:drawScores()

	if self.backButton.highlighted then
		love.graphics.setColor(200, 200, 200)
	else
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.draw(self.globals.backIcon, -self.x+self.backButton.x, -self.y+self.backButton.y, 0, .5, .5)
end

function Gameplay:update(dt)
	local batteryStatus, percent, estimate = love.system.getPowerInfo()
	if self.isPlaying then
		if love.timer.getTime() - self.deadMansTimer > 10 then
			-- the computer fell asleep or hibernated
			self.isPlaying = false
			self:recordScore("sleep")
		elseif percent > self.settings.difficulty then
			self.isPlaying = false
			self:recordScore("overcharged")
		else
			-- keep playing!
			self.score = self.score + dt
			self.deadMansTimer = love.timer.getTime()
			self.logScoreTimer = self.logScoreTimer + dt
			if self.logScoreTimer > 1 then
				self:logCurrentScore()
				self.logScoreTimer = 0
			end
		end
	end


	self.backButton.highlighted = mouseOverRect(self.backButton.x-self.x, self.backButton.y-self.y, self.backButton.width, self.backButton.height)
end

function Gameplay:drawScores()
	local scorePosition = #self.globals.scores
	for i = 1, #self.globals.scores do
		if self.globals.scores[i][3] < self.score then
			scorePosition = i-1
			break
		end
	end
	local x = 20
	local boxHeight = self.globals.regularFont:getHeight()
	local yoffset = self.scrollValue - boxHeight*scorePosition
	local y = love.graphics.getHeight()/2-boxHeight/2
	for i = 1, scorePosition do
		self:drawSingleScore(x-self.x, yoffset+y-self.y+boxHeight*(i-3), self.globals.scores[i])
	end
	self:drawSingleScore(x-self.x, yoffset+y-self.y+boxHeight*(scorePosition-1), {self.settings.difficulty, self.startTime, self.score, ""}, true)
	for i = scorePosition+1, #self.globals.scores do
		self:drawSingleScore(x-self.x, yoffset+y-self.y+boxHeight*(i), self.globals.scores[i])
	end
end

function Gameplay:secondsToPretty(sec)
	local days = math.floor(sec/86400)
	sec = sec % 86400
	local hours = math.floor(sec/3600)
	sec = sec % 3600
	local minutes = math.floor(sec/60)
	sec = sec % 60
	return days..":"..hours..":"..minutes..":"..string.format("%.1f", sec)
end

function Gameplay:drawSingleScore(x, y, scoreTable, special)
	local width = 440
	local height = self.globals.regularFont:getHeight()
	if special then
		love.graphics.setColor(255, 255, 255)
	else
		love.graphics.setColor(200, 200, 200)
	end
	love.graphics.rectangle("fill", x, y, width, height)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", x, y, width, height)
	local displayText = "Score: "..self:secondsToPretty(scoreTable[3]).." -  Difficulty: "..scoreTable[1] .. "  -  Started: "..scoreTable[2]
	love.graphics.print(displayText, x, y)

	local otherX = self.globals.regularFont:getWidth(displayText)+x+2
	y = y - 1
	love.graphics.setColor(255, 255, 255)
	if scoreTable[4] == "quit" then
		love.graphics.draw(self.globals.quitIcon, otherX, y)
	elseif scoreTable[4] == "sleep" then
		love.graphics.draw(self.globals.sleepIcon, otherX, y)
	elseif scoreTable[4] == "dead" then
		love.graphics.draw(self.globals.deadIcon, otherX, y)
	elseif scoreTable[4] == "overcharged" then
		love.graphics.draw(self.globals.powerIcon, otherX, y)
	end
end

function Gameplay:logCurrentScore()
	love.filesystem.write(self.globals.loggingFilename, "")
	love.filesystem.append(self.globals.loggingFilename, tostring(self.settings.difficulty).."\r\n")
	love.filesystem.append(self.globals.loggingFilename, tostring(self.startTime).."\r\n")
	love.filesystem.append(self.globals.loggingFilename, tostring(self.score).."\r\n")
	-- love.filesystem.append(self.globals.loggingFilename, tostring(failureReason).."\r\n") -- duh, this is nil
end

function Gameplay:recordScore(failureReason)
	-- records the score and the reason for failure to the scores file
	if love.filesystem.exists(self.globals.loggingFilename) then
		love.filesystem.remove(self.globals.loggingFilename)
	end
	if not love.filesystem.exists(self.globals.scoresFilename) then
		love.filesystem.write(self.globals.scoresFilename, "")
	end

	self:saveScore(self.settings.difficulty, self.startTime, self.score, failureReason)

	local scoreTable = {self.settings.difficulty, self.startTime, self.score, failureReason}
	self:addScore(scoreTable)
end

function Gameplay:saveScore(difficulty, startTime, score, failureReason)
	love.filesystem.append(self.globals.scoresFilename, tostring(difficulty).."\r\n")
	love.filesystem.append(self.globals.scoresFilename, tostring(startTime).."\r\n")
	love.filesystem.append(self.globals.scoresFilename, tostring(score).."\r\n")
	love.filesystem.append(self.globals.scoresFilename, tostring(failureReason).."\r\n")
end

function Gameplay:addScore(scoreTable)
	print("adding score")
	for i = 1, #self.globals.scores do
		if self.globals.scores[i][3] < scoreTable[3] then
			table.insert(self.globals.scores, i, scoreTable)
			print("added to "..i)
			return
		end
	end
	table.insert(self.globals.scores, scoreTable)
end


function Gameplay:startRun()
	-- currently a global because I'm too lazy to make it nice
	self.isPlaying = true
	self.deadMansTimer = love.timer.getTime()
	self.score = 0
	self.startTime = os.date() -- should be a string
	self.scrollValue = 0
end

function Gameplay:quit()
	-- this gets run when the game is closed
	-- if a run is in progress it will save it as a "quit" run
	if self.isPlaying then
		self.isPlaying = false
		self:recordScore("quit")
	end
end

function Gameplay:mousepressed(x, y, button)
	if self.backButton.highlighted then
		moveToScene("mainmenu")
		if self.isPlaying then
			self:recordScore("quit")
			self.isPlaying = false
		end
	end
end

function Gameplay:wheelmoved(x, y)
	self.scrollValue = self.scrollValue + y*10
end