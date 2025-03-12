local IGameState = require('src.interfaces.IGameState')
local Board = require('src.components.Board')
local ScoreManager = require('src.components.ScoreManager')
local AnimationManager = require('src.components.AnimationManager')

local GameState = setmetatable({}, { __index = IGameState })
GameState.__index = GameState

local GRID_SIZE = 10  -- Размер сетки
local CELL_SIZE = 50  -- Размер ячейки в пикселях

local IMAGES = {
    background = nil,  -- Фоновое изображение
    cell = nil,       -- Изображение ячейки
    selected = nil,   -- Изображение выделения
    gems = {}         -- Изображения кристаллов
}

local SOUNDS = {
    match = nil  -- Звук при совпадении
}

function GameState.new()
    local self = setmetatable({}, GameState)
    self._board = nil              -- Игровое поле
    self._scoreManager = nil       -- Менеджер очков
    self._animationManager = nil   -- Менеджер анимаций
    self._selectedGem = nil        -- Выбранный кристалл
    self._gridOffsetX = 0         -- Смещение сетки по X
    self._gridOffsetY = 0         -- Смещение сетки по Y
    self._isUserMove = false      -- Флаг хода игрока
    self:_loadResources()         -- Загрузка ресурсов
    return self
end

function GameState:_loadResources()
    IMAGES.background = love.graphics.newImage("src/assets/background.png")
    IMAGES.cell = love.graphics.newImage("src/assets/cell.png")
    IMAGES.selected = love.graphics.newImage("src/assets/selected.png")
    
    for _, color in ipairs({'A', 'B', 'C', 'D', 'E', 'F'}) do
        IMAGES.gems[color] = love.graphics.newImage("src/assets/gem_" .. color:lower() .. ".png")
    end
    
    SOUNDS.match = love.audio.newSource("src/assets/match.wav", "static")
end

function GameState:enter()
    self._board = Board.new(GRID_SIZE)
    self._scoreManager = ScoreManager.new()
    self._animationManager = AnimationManager.new()
    
    self._gridOffsetX = (love.graphics.getWidth() - GRID_SIZE * CELL_SIZE) / 2
    self._gridOffsetY = (love.graphics.getHeight() - GRID_SIZE * CELL_SIZE) / 2
    
    self._board:on('gemsSwapped', function(gem1, gem2)
        self._animationManager:createSwapAnimation(gem1, gem2)
    end)
    
    self._board:on('gemRemoved', function(gem)
        self._animationManager:createFadeAnimation(gem)
    end)
    
    self._board:on('newGemsCreated', function(gems)
        for _, gem in ipairs(gems) do
            local x, y = gem:getPosition()
            local startY = y - GRID_SIZE
            self._animationManager:createFallingAnimation(gem, startY, y)
        end
    end)
end

function GameState:exit()
    self._board = nil
    self._scoreManager = nil
    self._animationManager:clear()
    self._animationManager = nil
end

function GameState:update(dt)
    if self._animationManager:isAnimating() then
        self._animationManager:update(dt)
    else
        local matches = self._board:findMatches()
        if #matches > 0 then
            if SOUNDS.match and self._isUserMove then
                SOUNDS.match:stop()
                SOUNDS.match:play()
            end
            
            for _, match in ipairs(matches) do
                self._scoreManager:addMatchScore(#match)
            end
            
            self._board:removeMatches(matches)
            
            self._board:fillEmptySpaces()
            
            self._isUserMove = false
        else
            if not self._board:hasValidMoves() then
                self._board:mix()
            end
            
            self._scoreManager:resetCombo()
            self._isUserMove = false
        end
    end
end

function GameState:draw()
    love.graphics.clear(0.15, 0.15, 0.2, 1)
    
    if IMAGES.background then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(IMAGES.background, 0, 0, 0,
            love.graphics.getWidth() / IMAGES.background:getWidth(),
            love.graphics.getHeight() / IMAGES.background:getHeight())
    end
    
    love.graphics.setColor(0.3, 0.3, 0.35, 0.8)
    for y = 0, GRID_SIZE - 1 do
        for x = 0, GRID_SIZE - 1 do
            love.graphics.rectangle("line",
                self._gridOffsetX + x * CELL_SIZE,
                self._gridOffsetY + y * CELL_SIZE,
                CELL_SIZE, CELL_SIZE)
        end
    end
    
    for y = 0, GRID_SIZE - 1 do
        for x = 0, GRID_SIZE - 1 do
            local gem = self._board:getGemAt(x, y)
            if gem then
                local anim = self:_findGemAnimation(gem)
                self:_drawGem(gem, anim)
            end
        end
    end
    
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 5, 5, 200, 70)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Score: " .. self._scoreManager:getScore(), 10, 10)
    love.graphics.print("High Score: " .. self._scoreManager:getHighScore(), 10, 30)
    
    local combo = self._scoreManager:getCombo()
    if combo > 1 then
        love.graphics.print("Combo: x" .. combo, 10, 50)
    end
end

function GameState:_findGemAnimation(gem)
    for _, anim in ipairs(self._animationManager._animations) do
        if anim.params.gem == gem or anim.params.gem1 == gem or anim.params.gem2 == gem then
            return anim
        end
    end
    return nil
end

function GameState:_drawGem(gem, anim)
    local x, y = gem:getPosition()
    local screenX = self._gridOffsetX + x * CELL_SIZE
    local screenY = self._gridOffsetY + y * CELL_SIZE
    
    if anim then
        if anim.type == 'SWAP' then
            if anim.params.gem1 == gem then
                local progress = anim.progress
                screenX = screenX + (anim.params.endPos1[1] - x) * progress * CELL_SIZE
                screenY = screenY + (anim.params.endPos1[2] - y) * progress * CELL_SIZE
            elseif anim.params.gem2 == gem then
                local progress = anim.progress
                screenX = screenX + (anim.params.endPos2[1] - x) * progress * CELL_SIZE
                screenY = screenY + (anim.params.endPos2[2] - y) * progress * CELL_SIZE
            end
        elseif anim.type == 'FADE' then
            love.graphics.setColor(1, 1, 1, 1 - anim.progress)
        elseif anim.type == 'SPAWN' then
            love.graphics.setColor(1, 1, 1, anim.progress)
        elseif anim.type == 'FALL' then
            local startY = anim.params.startY
            local endY = anim.params.endY
            screenY = self._gridOffsetY + (startY + (endY - startY) * anim.progress) * CELL_SIZE
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(IMAGES.cell, screenX, screenY, 0,
        CELL_SIZE / IMAGES.cell:getWidth(),
        CELL_SIZE / IMAGES.cell:getHeight())
    
    if gem == self._selectedGem then
        love.graphics.draw(IMAGES.selected, screenX, screenY, 0,
            CELL_SIZE / IMAGES.selected:getWidth(),
            CELL_SIZE / IMAGES.selected:getHeight())
    end
    
    love.graphics.setColor(1, 1, 1, 1)
    local gemImage = IMAGES.gems[gem:getColor()]
    if gemImage then
        love.graphics.draw(gemImage, 
            screenX + CELL_SIZE/2, 
            screenY + CELL_SIZE/2, 
            0,
            CELL_SIZE * 0.8 / gemImage:getWidth(),
            CELL_SIZE * 0.8 / gemImage:getHeight(),
            gemImage:getWidth()/2,
            gemImage:getHeight()/2)
    end
end

function GameState:_getGemColor(colorCode)
    local colors = {
        A = {0.9, 0.3, 0.3},  -- Красный
        B = {0.4, 0.8, 0.4},  -- Зеленый
        C = {0.3, 0.5, 0.9},  -- Синий
        D = {0.9, 0.8, 0.3},  -- Желтый
        E = {0.8, 0.4, 0.8},  -- Пурпурный
        F = {0.4, 0.8, 0.8}   -- Голубой
    }
    return unpack(colors[colorCode] or {1, 1, 1})
end

function GameState:handleInput(x, y, button)
    if button == 1 then 
        local gridX = math.floor((x - self._gridOffsetX) / CELL_SIZE)
        local gridY = math.floor((y - self._gridOffsetY) / CELL_SIZE)
        
        if gridX >= 0 and gridX < GRID_SIZE and gridY >= 0 and gridY < GRID_SIZE then
            local clickedGem = self._board:getGemAt(gridX, gridY)
            
            if self._selectedGem then
                if clickedGem ~= self._selectedGem then
                    if self._board:swapGems(self._selectedGem, clickedGem) then
                        self._isUserMove = true
                    end
                    self._selectedGem = nil
                end
            else
                self._selectedGem = clickedGem
            end
        end
    end
end

return GameState 