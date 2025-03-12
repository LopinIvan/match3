local EventEmitter = require('src.core.EventEmitter')

local Gem = setmetatable({}, { __index = EventEmitter })
Gem.__index = Gem

function Gem.new(color, x, y)
    local self = setmetatable(EventEmitter.new(), Gem)
    self._color = color
    self._x = x
    self._y = y
    self._isSelected = false
    self._isMatched = false
    self._scale = 1
    self._alpha = 1
    return self
end

function Gem:getColor()
    return self._color
end

function Gem:getPosition()
    return self._x, self._y
end

function Gem:setPosition(x, y)
    self._x = x
    self._y = y
    self:emit('positionChanged', x, y)
end

function Gem:isSelected()
    return self._isSelected
end

function Gem:setSelected(selected)
    self._isSelected = selected
    self:emit('selectionChanged', selected)
end

function Gem:isMatched()
    return self._isMatched
end

function Gem:setMatched(matched)
    self._isMatched = matched
    self:emit('matchStateChanged', matched)
end

function Gem:getScale()
    return self._scale
end

function Gem:setScale(scale)
    self._scale = scale
    self:emit('scaleChanged', scale)
end

function Gem:getAlpha()
    return self._alpha
end

function Gem:setAlpha(alpha)
    self._alpha = alpha
    self:emit('alphaChanged', alpha)
end

return Gem 