-- Импорт базового класса для работы с событиями
local EventEmitter = require('src.core.EventEmitter')

-- Создание класса ScoreManager, наследующего от EventEmitter
local ScoreManager = setmetatable({}, { __index = EventEmitter })
ScoreManager.__index = ScoreManager

-- Таблица очков за различные комбинации
local MATCH_SCORES = {
    [3] = 10,  -- 3 в ряд: 10 очков
    [4] = 30,  -- 4 в ряд: 30 очков
    [5] = 70,  -- 5 в ряд: 70 очков
    combo = 5  -- Дополнительные очки за каждое комбо
}

-- Конструктор менеджера очков
function ScoreManager.new()
    local self = setmetatable(EventEmitter.new(), ScoreManager)
    self._score = 0        -- Текущие очки
    self._highScore = 0    -- Рекорд
    self._combo = 0        -- Текущий множитель комбо
    self:_loadHighScore()  -- Загрузка рекорда из файла
    return self
end

-- Загрузка рекорда из файла
function ScoreManager:_loadHighScore()
    local success, data = pcall(love.filesystem.read, "highscore.dat")
    if success and data then
        self._highScore = tonumber(data) or 0
    end
end

-- Сохранение нового рекорда в файл
function ScoreManager:_saveHighScore()
    love.filesystem.write("highscore.dat", tostring(self._highScore))
end

-- Получение текущих очков
function ScoreManager:getScore()
    return self._score
end

-- Получение рекорда
function ScoreManager:getHighScore()
    return self._highScore
end

-- Получение текущего множителя комбо
function ScoreManager:getCombo()
    return self._combo
end

-- Добавление очков за совпадение
function ScoreManager:addMatchScore(matchLength)
    -- Расчет базовых очков и бонуса за комбо
    local baseScore = MATCH_SCORES[matchLength] or MATCH_SCORES[3]
    local comboBonus = self._combo * MATCH_SCORES.combo
    
    -- Обновление текущих очков
    self._score = self._score + baseScore + comboBonus
    self._combo = self._combo + 1
    
    -- Проверка на новый рекорд
    if self._score > self._highScore then
        self._highScore = self._score
        self:_saveHighScore()
        self:emit('newHighScore', self._highScore)
    end
    
    -- Оповещение об изменении очков
    self:emit('scoreChanged', self._score, baseScore + comboBonus)
end

-- Сброс множителя комбо
function ScoreManager:resetCombo()
    self._combo = 0
    self:emit('comboReset')
end

-- Полный сброс очков и комбо
function ScoreManager:reset()
    self._score = 0
    self._combo = 0
    self:emit('scoreReset')
end

return ScoreManager 