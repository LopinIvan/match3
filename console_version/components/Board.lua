local IBoard = require('console_version.interfaces.IBoard')

local Board = setmetatable({}, { __index = IBoard })
Board.__index = Board

local GRID_SIZE = 10
local COLORS = {'A', 'B', 'C', 'D', 'E', 'F'}

function Board.new()
    local self = setmetatable({}, Board)
    self.grid = {}
    self.changes = false -- флаг для отслеживания изменений на поле
    return self
end

-- Инициализация поля случайными кристаллами
function Board:init()
    self.grid = {}
    for y = 0, GRID_SIZE - 1 do
        self.grid[y] = {}
        for x = 0, GRID_SIZE - 1 do
            self.grid[y][x] = self:_getRandomColor()
        end
    end
    -- Убираем начальные совпадения
    while self:_hasMatches() do
        self:_removeMatches()
        self:_fillEmptySpaces()
    end
end

-- Выполнение хода игрока
function Board:move(fromX, fromY, toX, toY)
    if not self:_isValidMove(fromX, fromY, toX, toY) then
        return false
    end
    
    -- Меняем кристаллы местами
    self:_swapGems(fromX, fromY, toX, toY)
    
    -- Проверяем, образовалось ли совпадение
    if not self:_hasMatches() then
        -- Если совпадений нет, возвращаем кристаллы обратно
        self:_swapGems(fromX, fromY, toX, toY)
        return false
    end
    
    return true
end

-- Выполнение действий на поле (удаление совпадений, заполнение пустот)
function Board:tick()
    self.changes = false
    
    if self:_hasMatches() then
        self:_removeMatches()
        self:_fillEmptySpaces()
        self.changes = true
    end
    
    return self.changes
end

-- Перемешивание поля
function Board:mix()
    local tempGrid = {}
    -- Собираем все кристаллы
    local gems = {}
    for y = 0, GRID_SIZE - 1 do
        for x = 0, GRID_SIZE - 1 do
            table.insert(gems, self.grid[y][x])
        end
    end
    
    -- Перемешиваем
    for i = #gems, 2, -1 do
        local j = math.random(i)
        gems[i], gems[j] = gems[j], gems[i]
    end
    
    -- Расставляем обратно
    local index = 1
    for y = 0, GRID_SIZE - 1 do
        tempGrid[y] = {}
        for x = 0, GRID_SIZE - 1 do
            tempGrid[y][x] = gems[index]
            index = index + 1
        end
    end
    
    -- Проверяем, нет ли совпадений после перемешивания
    self.grid = tempGrid
    if self:_hasMatches() then
        -- Если есть совпадения, перемешиваем снова
        return self:mix()
    end
    
    return true
end

-- Получение содержимого поля для отображения
function Board:dump()
    return self.grid
end

-- Приватные методы

function Board:_getRandomColor()
    return COLORS[math.random(#COLORS)]
end

function Board:_isValidMove(fromX, fromY, toX, toY)
    -- Проверяем, что координаты в пределах поля
    if fromX < 0 or fromX >= GRID_SIZE or fromY < 0 or fromY >= GRID_SIZE or
       toX < 0 or toX >= GRID_SIZE or toY < 0 or toY >= GRID_SIZE then
        return false
    end
    
    -- Проверяем, что кристаллы соседние
    local dx = math.abs(fromX - toX)
    local dy = math.abs(fromY - toY)
    return (dx == 1 and dy == 0) or (dx == 0 and dy == 1)
end

function Board:_swapGems(x1, y1, x2, y2)
    self.grid[y1][x1], self.grid[y2][x2] = self.grid[y2][x2], self.grid[y1][x1]
end

function Board:_hasMatches()
    -- Проверка горизонтальных совпадений
    for y = 0, GRID_SIZE - 1 do
        for x = 0, GRID_SIZE - 3 do
            local color = self.grid[y][x]
            if color == self.grid[y][x + 1] and color == self.grid[y][x + 2] then
                return true
            end
        end
    end
    
    -- Проверка вертикальных совпадений
    for y = 0, GRID_SIZE - 3 do
        for x = 0, GRID_SIZE - 1 do
            local color = self.grid[y][x]
            if color == self.grid[y + 1][x] and color == self.grid[y + 2][x] then
                return true
            end
        end
    end
    
    return false
end

function Board:_removeMatches()
    local matched = {}
    
    -- Находим горизонтальные совпадения
    for y = 0, GRID_SIZE - 1 do
        local x = 0
        while x < GRID_SIZE - 2 do
            local matchLength = 1
            local color = self.grid[y][x]
            
            -- Считаем длину совпадения
            while x + matchLength < GRID_SIZE and 
                  self.grid[y][x + matchLength] == color do
                matchLength = matchLength + 1
            end
            
            -- Если есть совпадение из 3+ кристаллов
            if matchLength >= 3 then
                for i = 0, matchLength - 1 do
                    matched[y .. "," .. (x + i)] = true
                end
            end
            
            x = x + matchLength
        end
    end
    
    -- Находим вертикальные совпадения
    for x = 0, GRID_SIZE - 1 do
        local y = 0
        while y < GRID_SIZE - 2 do
            local matchLength = 1
            local color = self.grid[y][x]
            
            -- Считаем длину совпадения
            while y + matchLength < GRID_SIZE and 
                  self.grid[y + matchLength][x] == color do
                matchLength = matchLength + 1
            end
            
            -- Если есть совпадение из 3+ кристаллов
            if matchLength >= 3 then
                for i = 0, matchLength - 1 do
                    matched[(y + i) .. "," .. x] = true
                end
            end
            
            y = y + matchLength
        end
    end
    
    -- Удаляем совпавшие кристаллы
    for pos in pairs(matched) do
        local y, x = pos:match("(%d+),(%d+)")
        y, x = tonumber(y), tonumber(x)
        self.grid[y][x] = nil
    end
end

function Board:_fillEmptySpaces()
    -- Смещаем кристаллы вниз
    for x = 0, GRID_SIZE - 1 do
        local emptySpaces = 0
        for y = GRID_SIZE - 1, 0, -1 do
            if self.grid[y][x] == nil then
                emptySpaces = emptySpaces + 1
            elseif emptySpaces > 0 then
                self.grid[y + emptySpaces][x] = self.grid[y][x]
                self.grid[y][x] = nil
            end
        end
        
        -- Заполняем пустые места сверху новыми кристаллами
        for y = 0, emptySpaces - 1 do
            self.grid[y][x] = self:_getRandomColor()
        end
    end
end

return Board 