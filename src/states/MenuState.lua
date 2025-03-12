-- Импорт базового интерфейса состояния игры
local IGameState = require('src.interfaces.IGameState')

-- Создание класса MenuState, наследующего от IGameState
local MenuState = setmetatable({}, { __index = IGameState })
MenuState.__index = MenuState

-- Константы размеров кнопок меню
local BUTTON_WIDTH = 200   -- Ширина кнопки
local BUTTON_HEIGHT = 60   -- Высота кнопки

-- Конструктор состояния меню
function MenuState.new()
    local self = setmetatable({}, MenuState)
    self._background = love.graphics.newImage("src/assets/background.png")  -- Загрузка фонового изображения
    return self
end

-- Загрузка графических ресурсов
function MenuState:_loadAssets()
    -- Проверяем наличие и загружаем фоновое изображение
    if love.filesystem.getInfo("src/assets/background.png") then
        self._background = love.graphics.newImage("src/assets/background.png")
    end
end

-- Вход в состояние меню
function MenuState:enter()
    -- Ничего не делаем при входе в состояние
end

-- Выход из состояния меню
function MenuState:exit()
    -- Ничего не делаем при выходе из состояния
end

-- Обновление состояния меню
function MenuState:update(dt)
    -- В меню нет обновлений состояния
end

-- Отрисовка меню
function MenuState:draw()
    -- Очистка экрана
    love.graphics.clear(0.15, 0.15, 0.2, 1)
    
    -- Отрисовка фонового изображения
    if self._background then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self._background, 0, 0, 0,
            love.graphics.getWidth() / self._background:getWidth(),
            love.graphics.getHeight() / self._background:getHeight())
    end
    
    -- Отрисовка заголовка игры
    love.graphics.setColor(1, 1, 1, 1)
    local title = "Match-3 Game"
    local font = love.graphics.getFont()
    local titleW = font:getWidth(title) * 2  -- Умножаем на 2 для увеличения размера
    love.graphics.print(title, 
        love.graphics.getWidth()/2 - titleW/2,  -- Центрирование по горизонтали
        love.graphics.getHeight()/3,            -- Размещение в верхней трети экрана
        0, 2, 2)                               -- Масштаб текста 2x2
    
    -- Отрисовка кнопки "Start Game"
    self:_drawButton("Start Game", 
        love.graphics.getWidth()/2 - BUTTON_WIDTH/2,  -- Центрирование по горизонтали
        love.graphics.getHeight()/2)                  -- Размещение в центре экрана
end

-- Отрисовка кнопки меню
function MenuState:_drawButton(text, x, y)
    -- Отрисовка фона кнопки
    love.graphics.setColor(0.2, 0.2, 0.25, 1)
    love.graphics.rectangle("fill", x, y, BUTTON_WIDTH, BUTTON_HEIGHT)
    
    -- Отрисовка рамки кнопки
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, BUTTON_WIDTH, BUTTON_HEIGHT)
    
    -- Отрисовка текста кнопки
    love.graphics.setColor(1, 1, 1, 1)
    local font = love.graphics.getFont()
    local textW = font:getWidth(text)
    local textH = font:getHeight()
    -- Центрирование текста внутри кнопки
    love.graphics.print(text, x + (BUTTON_WIDTH - textW)/2, y + (BUTTON_HEIGHT - textH)/2)
end

-- Обработка пользовательского ввода
function MenuState:handleInput(x, y, button)
    if button == 1 then  -- Проверка на нажатие левой кнопки мыши
        -- Проверка попадания клика в кнопку Start Game
        if self:_isPointInButton(x, y, 
            love.graphics.getWidth()/2 - BUTTON_WIDTH/2,
            love.graphics.getHeight()/2) then
            return 'startGame'  -- Сигнал о начале игры
        end
    end
    return nil
end

-- Проверка попадания точки в область кнопки
function MenuState:_isPointInButton(x, y, buttonX, buttonY)
    return x >= buttonX and x <= buttonX + BUTTON_WIDTH and
           y >= buttonY and y <= buttonY + BUTTON_HEIGHT
end

return MenuState 