local IGameState = require('src.interfaces.IGameState')

local MenuState = setmetatable({}, { __index = IGameState })
MenuState.__index = MenuState

local BUTTON_WIDTH = 200   -- Ширина кнопки
local BUTTON_HEIGHT = 60   -- Высота кнопки

function MenuState.new()
    local self = setmetatable({}, MenuState)
    self._background = love.graphics.newImage("src/assets/background.png")
    return self
end

function MenuState:_loadAssets()
    if love.filesystem.getInfo("src/assets/background.png") then
        self._background = love.graphics.newImage("src/assets/background.png")
    end
end

function MenuState:enter()
end

function MenuState:exit()
end

function MenuState:update(dt)
end

function MenuState:draw()
    love.graphics.clear(0.15, 0.15, 0.2, 1)
    
    if self._background then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self._background, 0, 0, 0,
            love.graphics.getWidth() / self._background:getWidth(),
            love.graphics.getHeight() / self._background:getHeight())
    end
    
    love.graphics.setColor(1, 1, 1, 1)
    local title = "Match-3 Game"
    local font = love.graphics.getFont()
    local titleW = font:getWidth(title) * 2
    love.graphics.print(title, 
        love.graphics.getWidth()/2 - titleW/2,
        love.graphics.getHeight()/3,
        0, 2, 2)
    
    self:_drawButton("Start Game", 
        love.graphics.getWidth()/2 - BUTTON_WIDTH/2,
        love.graphics.getHeight()/2)
end

function MenuState:_drawButton(text, x, y)
    love.graphics.setColor(0.2, 0.2, 0.25, 1)
    love.graphics.rectangle("fill", x, y, BUTTON_WIDTH, BUTTON_HEIGHT)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", x, y, BUTTON_WIDTH, BUTTON_HEIGHT)
    
    love.graphics.setColor(1, 1, 1, 1)
    local font = love.graphics.getFont()
    local textW = font:getWidth(text)
    local textH = font:getHeight()
    love.graphics.print(text, x + (BUTTON_WIDTH - textW)/2, y + (BUTTON_HEIGHT - textH)/2)
end

function MenuState:handleInput(x, y, button)
    if button == 1 then
        if self:_isPointInButton(x, y, 
            love.graphics.getWidth()/2 - BUTTON_WIDTH/2,
            love.graphics.getHeight()/2) then
            return 'startGame'
        end
    end
    return nil
end

function MenuState:_isPointInButton(x, y, buttonX, buttonY)
    return x >= buttonX and x <= buttonX + BUTTON_WIDTH and
           y >= buttonY and y <= buttonY + BUTTON_HEIGHT
end

return MenuState 