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
    
    self._grid[x1][y1] = gem2
    self._grid[x2][y2] = gem1
    
    gem1:setPosition(x2, y2)
    gem2:setPosition(x1, y1)
    
    self:emit('gemsSwapped', gem1, gem2)
end

function Board:findMatches()
    local matches = {}
    
    -- Проверка горизонтальных совпадений
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
    
    -- Проверка вертикальных совпадений
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
        
        -- Создаем новые кристаллы сверху
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

return Board 