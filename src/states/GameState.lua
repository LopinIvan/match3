-- Импорт необходимых модулей и компонентов
local IGameState = require('src.interfaces.IGameState')
local Board = require('src.components.Board')
local ScoreManager = require('src.components.ScoreManager')
local AnimationManager = require('src.components.AnimationManager')

-- Создание класса GameState, наследующего от IGameState
local GameState = setmetatable({}, { __index = IGameState })
GameState.__index = GameState

-- Константы для настройки игрового поля
local GRID_SIZE = 10  -- Размер сетки
local CELL_SIZE = 50  -- Размер ячейки в пикселях

-- Хранилище игровых ресурсов
local IMAGES = {
    background = nil,  -- Фоновое изображение
    cell = nil,       -- Изображение ячейки
    selected = nil,   -- Изображение выделения
    gems = {}         -- Изображения кристаллов
}

-- Хранилище звуковых эффектов
local SOUNDS = {
    match = nil  -- Звук при совпадении
}

-- Конструктор игрового состояния
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

-- Загрузка игровых ресурсов
function GameState:_loadResources()
    -- Загрузка изображений
    IMAGES.background = love.graphics.newImage("src/assets/background.png")
    IMAGES.cell = love.graphics.newImage("src/assets/cell.png")
    IMAGES.selected = love.graphics.newImage("src/assets/selected.png")
    
    -- Загрузка изображений кристаллов разных цветов
    for _, color in ipairs({'A', 'B', 'C', 'D', 'E', 'F'}) do
        IMAGES.gems[color] = love.graphics.newImage("src/assets/gem_" .. color:lower() .. ".png")
    end
    
    -- Загрузка звуковых эффектов
    SOUNDS.match = love.audio.newSource("src/assets/match.wav", "static")
end

-- Инициализация при входе в игровое состояние
function GameState:enter()
    -- Создание основных компонентов
    self._board = Board.new(GRID_SIZE)
    self._scoreManager = ScoreManager.new()
    self._animationManager = AnimationManager.new()
    
    -- Вычисление отступов для центрирования игрового поля
    self._gridOffsetX = (love.graphics.getWidth() - GRID_SIZE * CELL_SIZE) / 2
    self._gridOffsetY = (love.graphics.getHeight() - GRID_SIZE * CELL_SIZE) / 2
    
    -- Подписка на события игрового поля
    self._board:on('gemsSwapped', function(gem1, gem2)
        self._animationManager:createSwapAnimation(gem1, gem2)
    end)
    
    self._board:on('gemRemoved', function(gem)
        self._animationManager:createFadeAnimation(gem)
    end)
    
    self._board:on('newGemsCreated', function(gems)
        for _, gem in ipairs(gems) do
            local x, y = gem:getPosition()
            -- Анимация падения новых кристаллов
            local startY = y - GRID_SIZE
            self._animationManager:createFallingAnimation(gem, startY, y)
        end
    end)
end

-- Очистка при выходе из игрового состояния
function GameState:exit()
    -- Освобождение ресурсов
    self._board = nil
    self._scoreManager = nil
    self._animationManager:clear()
    self._animationManager = nil
end

-- Обновление игровой логики
function GameState:update(dt)
    if self._animationManager:isAnimating() then
        -- Обновление анимаций
        self._animationManager:update(dt)
    else
        -- Проверка совпадений после завершения анимаций
        local matches = self._board:findMatches()
        if #matches > 0 then
            -- Воспроизведение звука при совпадении (только для хода игрока)
            if SOUNDS.match and self._isUserMove then
                SOUNDS.match:stop()
                SOUNDS.match:play()
            end
            
            -- Начисление очков за совпадения
            for _, match in ipairs(matches) do
                self._scoreManager:addMatchScore(#match)
            end
            
            -- Удаление совпавших кристаллов
            self._board:removeMatches(matches)
            
            -- Заполнение пустых мест
            self._board:fillEmptySpaces()
            
            -- Сброс флага хода игрока
            self._isUserMove = false
        else
            -- Проверка возможных ходов
            if not self._board:hasValidMoves() then
                -- Перемешивание поля при отсутствии возможных ходов
                self._board:mix()
            end
            
            -- Сброс комбо и флага хода игрока
            self._scoreManager:resetCombo()
            self._isUserMove = false
        end
    end
end

-- Отрисовка игрового состояния
function GameState:draw()
    -- Очистка экрана
    love.graphics.clear(0.15, 0.15, 0.2, 1)
    
    -- Отрисовка фона
    if IMAGES.background then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(IMAGES.background, 0, 0, 0,
            love.graphics.getWidth() / IMAGES.background:getWidth(),
            love.graphics.getHeight() / IMAGES.background:getHeight())
    end
    
    -- Отрисовка сетки
    love.graphics.setColor(0.3, 0.3, 0.35, 0.8)
    for y = 0, GRID_SIZE - 1 do
        for x = 0, GRID_SIZE - 1 do
            love.graphics.rectangle("line",
                self._gridOffsetX + x * CELL_SIZE,
                self._gridOffsetY + y * CELL_SIZE,
                CELL_SIZE, CELL_SIZE)
        end
    end
    
    -- Отрисовка кристаллов
    for y = 0, GRID_SIZE - 1 do
        for x = 0, GRID_SIZE - 1 do
            local gem = self._board:getGemAt(x, y)
            if gem then
                local anim = self:_findGemAnimation(gem)
                self:_drawGem(gem, anim)
            end
        end
    end
    
    -- Отрисовка интерфейса очков
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 5, 5, 200, 70)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Score: " .. self._scoreManager:getScore(), 10, 10)
    love.graphics.print("High Score: " .. self._scoreManager:getHighScore(), 10, 30)
    
    -- Отрисовка множителя комбо
    local combo = self._scoreManager:getCombo()
    if combo > 1 then
        love.graphics.print("Combo: x" .. combo, 10, 50)
    end
end

-- Поиск активной анимации для кристалла
function GameState:_findGemAnimation(gem)
    for _, anim in ipairs(self._animationManager._animations) do
        if anim.params.gem == gem or anim.params.gem1 == gem or anim.params.gem2 == gem then
            return anim
        end
    end
    return nil
end

-- Отрисовка отдельного кристалла с учетом анимации
function GameState:_drawGem(gem, anim)
    local x, y = gem:getPosition()
    local screenX = self._gridOffsetX + x * CELL_SIZE
    local screenY = self._gridOffsetY + y * CELL_SIZE
    
    -- Применение анимаций
    if anim then
        if anim.type == 'SWAP' then
            -- Анимация обмена кристаллов
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
            -- Анимация исчезновения
            love.graphics.setColor(1, 1, 1, 1 - anim.progress)
        elseif anim.type == 'SPAWN' then
            -- Анимация появления
            love.graphics.setColor(1, 1, 1, anim.progress)
        elseif anim.type == 'FALL' then
            -- Анимация падения
            local startY = anim.params.startY
            local endY = anim.params.endY
            screenY = self._gridOffsetY + (startY + (endY - startY) * anim.progress) * CELL_SIZE
        end
    end
    
    -- Отрисовка ячейки
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(IMAGES.cell, screenX, screenY, 0,
        CELL_SIZE / IMAGES.cell:getWidth(),
        CELL_SIZE / IMAGES.cell:getHeight())
    
    -- Отрисовка выделения выбранного кристалла
    if gem == self._selectedGem then
        love.graphics.draw(IMAGES.selected, screenX, screenY, 0,
            CELL_SIZE / IMAGES.selected:getWidth(),
            CELL_SIZE / IMAGES.selected:getHeight())
    end
    
    -- Отрисовка кристалла
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

-- Получение цвета кристалла по коду
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
    if button == 1 then  -- Левый клик
        -- Преобразуем координаты экрана в координаты сетки
        local gridX = math.floor((x - self._gridOffsetX) / CELL_SIZE)
        local gridY = math.floor((y - self._gridOffsetY) / CELL_SIZE)
        
        -- Проверяем, что клик был внутри сетки
        if gridX >= 0 and gridX < GRID_SIZE and gridY >= 0 and gridY < GRID_SIZE then
            local clickedGem = self._board:getGemAt(gridX, gridY)
            
            if self._selectedGem then
                -- Если уже есть выбранный кристалл
                if clickedGem ~= self._selectedGem then
                    -- Пытаемся поменять кристаллы местами
                    if self._board:swapGems(self._selectedGem, clickedGem) then
                        self._isUserMove = true
                    end
                    self._selectedGem = nil
                end
            else
                -- Выбираем кристалл
                self._selectedGem = clickedGem
            end
        end
    end
end

return GameState 