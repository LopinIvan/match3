local EventEmitter = require('src.core.EventEmitter')

local ScoreManager = setmetatable({}, { __index = EventEmitter })
ScoreManager.__index = ScoreManager

local MATCH_SCORES = {
    [3] = 10,  -- 3 в ряд
    [4] = 30,  -- 4 в ряд
    [5] = 70,  -- 5 в ряд
    combo = 5  -- дополнительные очки за комбо
}

function ScoreManager.new()
    local self = setmetatable(EventEmitter.new(), ScoreManager)
    self._score = 0
    self._highScore = 0
    self._combo = 0
    self:_loadHighScore()
    return self
end

function ScoreManager:_loadHighScore()
    local success, data = pcall(love.filesystem.read, "highscore.dat")
    if success and data then
        self._highScore = tonumber(data) or 0
    end
end

function ScoreManager:_saveHighScore()
    love.filesystem.write("highscore.dat", tostring(self._highScore))
end

function ScoreManager:getScore()
    return self._score
end

function ScoreManager:getHighScore()
    return self._highScore
end

function ScoreManager:getCombo()
    return self._combo
end

function ScoreManager:addMatchScore(matchLength)
    local baseScore = MATCH_SCORES[matchLength] or MATCH_SCORES[3]
    local comboBonus = self._combo * MATCH_SCORES.combo
    
    self._score = self._score + baseScore + comboBonus
    self._combo = self._combo + 1
    
    if self._score > self._highScore then
        self._highScore = self._score
        self:_saveHighScore()
        self:emit('newHighScore', self._highScore)
    end
    
    self:emit('scoreChanged', self._score, baseScore + comboBonus)
end

function ScoreManager:resetCombo()
    self._combo = 0
    self:emit('comboReset')
end

function ScoreManager:reset()
    self._score = 0
    self._combo = 0
    self:emit('scoreReset')
end

return ScoreManager 