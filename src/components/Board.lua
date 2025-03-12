local EventEmitter = require('src.core.EventEmitter')
local Gem = require('src.components.Gem')

local Board = setmetatable({}, { __index = EventEmitter })
Board.__index = Board

local COLORS = {'A', 'B', 'C', 'D', 'E', 'F'}

function Board.new(size)
    local self = setmetatable(EventEmitter.new(), Board)
    self._size = size
    self._grid = {}
    self._selectedGem = nil
    self:_initializeGrid()
    return self
end

function Board:_initializeGrid()
    for x = 0, self._size - 1 do
        self._grid[x] = {}
        for y = 0, self._size - 1 do
            self:_createGemAt(x, y)
        end
    end
end

function Board:_createGemAt(x, y)
    local color = COLORS[love.math.random(#COLORS)]
    local gem = Gem.new(color, x, y)
    self._grid[x][y] = gem
    self:emit('gemCreated', gem)
    return gem
end

function Board:getGemAt(x, y)
    if x >= 0 and x < self._size and y >= 0 and y < self._size then
        return self._grid[x][y]
    end
    return nil
end

function Board:swapGems(gem1, gem2)
    local x1, y1 = gem1:getPosition()
    local x2, y2 = gem2:getPosition()
    
    local tempGrid = {}
    for x = 0, self._size - 1 do
        tempGrid[x] = {}
        for y = 0, self._size - 1 do
            tempGrid[x][y] = self._grid[x][y]
        end
    end
    
    self._grid[x1][y1] = gem2
    self._grid[x2][y2] = gem1
    
    local matches = self:findMatches()
    
    if #matches == 0 then
        self._grid = tempGrid
        return false
    end
    
    gem1:setPosition(x2, y2)
    gem2:setPosition(x1, y1)
    
    self:emit('gemsSwapped', gem1, gem2)
    return true
end

function Board:findMatches()
    local matches = {}
    
    for y = 0, self._size - 1 do
        local matchCount = 1
        local currentColor = nil
        local matchStart = 0
        
        for x = 0, self._size - 1 do
            local gem = self:getGemAt(x, y)
            if gem then
                if gem:getColor() == currentColor then
                    matchCount = matchCount + 1
                else
                    if matchCount >= 3 then
                        local match = {}
                        for i = matchStart, x - 1 do
                            table.insert(match, self:getGemAt(i, y))
                        end
                        table.insert(matches, match)
                    end
                    matchCount = 1
                    currentColor = gem:getColor()
                    matchStart = x
                end
            end
        end
        
        if matchCount >= 3 then
            local match = {}
            for i = matchStart, self._size - 1 do
                table.insert(match, self:getGemAt(i, y))
            end
            table.insert(matches, match)
        end
    end
    
    for x = 0, self._size - 1 do
        local matchCount = 1
        local currentColor = nil
        local matchStart = 0
        
        for y = 0, self._size - 1 do
            local gem = self:getGemAt(x, y)
            if gem then
                if gem:getColor() == currentColor then
                    matchCount = matchCount + 1
                else
                    if matchCount >= 3 then
                        local match = {}
                        for i = matchStart, y - 1 do
                            table.insert(match, self:getGemAt(x, i))
                        end
                        table.insert(matches, match)
                    end
                    matchCount = 1
                    currentColor = gem:getColor()
                    matchStart = y
                end
            end
        end
        
        if matchCount >= 3 then
            local match = {}
            for i = matchStart, self._size - 1 do
                table.insert(match, self:getGemAt(x, i))
            end
            table.insert(matches, match)
        end
    end
    
    return matches
end

function Board:removeMatches(matches)
    for _, match in ipairs(matches) do
        for _, gem in ipairs(match) do
            local x, y = gem:getPosition()
            self._grid[x][y] = nil
            self:emit('gemRemoved', gem)
        end
    end
end

function Board:fillEmptySpaces()
    local newGems = {}
    
    for x = 0, self._size - 1 do
        local emptySpaces = 0
        for y = self._size - 1, 0, -1 do
            local gem = self:getGemAt(x, y)
            if not gem then
                emptySpaces = emptySpaces + 1
            elseif emptySpaces > 0 then
                local newY = y + emptySpaces
                self._grid[x][y] = nil
                self._grid[x][newY] = gem
                gem:setPosition(x, newY)
            end
        end
        
        for y = 0, emptySpaces - 1 do
            local newGem = self:_createGemAt(x, y)
            table.insert(newGems, newGem)
        end
    end
    
    if #newGems > 0 then
        self:emit('newGemsCreated', newGems)
    end
    
    return newGems
end

-- Проверка наличия возможных ходов
function Board:hasValidMoves()
    -- Проверяем все возможные ходы
    for y = 0, self._size - 1 do
        for x = 0, self._size - 1 do
            -- Проверяем ход вправо
            if x < self._size - 1 then
                -- Временно меняем кристаллы
                local gem1 = self:getGemAt(x, y)
                local gem2 = self:getGemAt(x + 1, y)
                if gem1 and gem2 then
                    local x1, y1 = gem1:getPosition()
                    local x2, y2 = gem2:getPosition()
                    
                    -- Меняем местами
                    self._grid[x1][y1] = gem2
                    self._grid[x2][y2] = gem1
                    gem1:setPosition(x2, y2)
                    gem2:setPosition(x1, y1)
                    
                    -- Проверяем на совпадения
                    local hasMatch = #self:findMatches() > 0
                    
                    -- Возвращаем обратно
                    self._grid[x1][y1] = gem1
                    self._grid[x2][y2] = gem2
                    gem1:setPosition(x1, y1)
                    gem2:setPosition(x2, y2)
                    
                    if hasMatch then
                        return true
                    end
                end
            end
            
            -- Проверяем ход вниз
            if y < self._size - 1 then
                -- Временно меняем кристаллы
                local gem1 = self:getGemAt(x, y)
                local gem2 = self:getGemAt(x, y + 1)
                if gem1 and gem2 then
                    local x1, y1 = gem1:getPosition()
                    local x2, y2 = gem2:getPosition()
                    
                    -- Меняем местами
                    self._grid[x1][y1] = gem2
                    self._grid[x2][y2] = gem1
                    gem1:setPosition(x2, y2)
                    gem2:setPosition(x1, y1)
                    
                    -- Проверяем на совпадения
                    local hasMatch = #self:findMatches() > 0
                    
                    -- Возвращаем обратно
                    self._grid[x1][y1] = gem1
                    self._grid[x2][y2] = gem2
                    gem1:setPosition(x1, y1)
                    gem2:setPosition(x2, y2)
                    
                    if hasMatch then
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- Перемешивание поля
function Board:mix()
    -- Собираем все кристаллы
    local gems = {}
    for y = 0, self._size - 1 do
        for x = 0, self._size - 1 do
            local gem = self:getGemAt(x, y)
            if gem then
                table.insert(gems, gem)
            end
        end
    end
    
    -- Перемешиваем и расставляем, пока не получим валидное состояние
    repeat
        -- Перемешиваем
        for i = #gems, 2, -1 do
            local j = love.math.random(i)
            gems[i], gems[j] = gems[j], gems[i]
        end
        
        -- Расставляем
        local index = 1
        for y = 0, self._size - 1 do
            for x = 0, self._size - 1 do
                local gem = gems[index]
                self._grid[x][y] = gem
                gem:setPosition(x, y)
                index = index + 1
            end
        end
        
        -- Проверяем условия:
        -- 1. Нет готовых троек
        -- 2. Есть хотя бы один возможный ход
    until #self:findMatches() == 0 and self:hasValidMoves()
    
    -- Оповещаем об изменениях
    self:emit('boardMixed')
    
    return true
end

return Board 