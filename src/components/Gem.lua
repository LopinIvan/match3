-- Импорт базового класса для работы с событиями
local EventEmitter = require('src.core.EventEmitter')

-- Создание класса Gem, наследующего от EventEmitter
local Gem = setmetatable({}, { __index = EventEmitter })
Gem.__index = Gem

-- Конструктор кристалла
function Gem.new(color, x, y)
    local self = setmetatable(EventEmitter.new(), Gem)
    self._color = color        -- Цвет кристалла
    self._x = x               -- Позиция по X
    self._y = y               -- Позиция по Y
    self._isSelected = false  -- Флаг выбора
    self._isMatched = false   -- Флаг совпадения
    self._scale = 1           -- Масштаб отрисовки
    self._alpha = 1           -- Прозрачность
    return self
end

-- Получение цвета кристалла
function Gem:getColor()
    return self._color
end

-- Получение текущей позиции
function Gem:getPosition()
    return self._x, self._y
end

-- Установка новой позиции
function Gem:setPosition(x, y)
    self._x = x
    self._y = y
    self:emit('positionChanged', x, y)  -- Оповещение об изменении позиции
end

-- Проверка, выбран ли кристалл
function Gem:isSelected()
    return self._isSelected
end

-- Установка состояния выбора
function Gem:setSelected(selected)
    self._isSelected = selected
    self:emit('selectionChanged', selected)  -- Оповещение об изменении выбора
end

-- Проверка, входит ли кристалл в совпадение
function Gem:isMatched()
    return self._isMatched
end

-- Установка состояния совпадения
function Gem:setMatched(matched)
    self._isMatched = matched
    self:emit('matchStateChanged', matched)  -- Оповещение об изменении состояния совпадения
end

-- Получение текущего масштаба
function Gem:getScale()
    return self._scale
end

-- Установка масштаба
function Gem:setScale(scale)
    self._scale = scale
    self:emit('scaleChanged', scale)  -- Оповещение об изменении масштаба
end

-- Получение текущей прозрачности
function Gem:getAlpha()
    return self._alpha
end

-- Установка прозрачности
function Gem:setAlpha(alpha)
    self._alpha = alpha
    self:emit('alphaChanged', alpha)  -- Оповещение об изменении прозрачности
end

return Gem 