local StateManager = require('src.core.StateManager')
local MenuState = require('src.states.MenuState')
local GameState = require('src.states.GameState')

function love.load()
    math.randomseed(os.time())
    
    love.window.setMode(800, 600, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
    love.window.setTitle("Match-3 Game")
    
    stateManager = StateManager.new()
    
    stateManager:addState('menu', MenuState.new())
    stateManager:addState('game', GameState.new())
    
    stateManager:on('stateInput', function(action)
        if action == 'startGame' then
            stateManager:changeState('game')
        elseif action == 'exitToMenu' then
            stateManager:changeState('menu')
        end
    end)
    
    stateManager:changeState('menu')
end

function love.update(dt)
    stateManager:update(dt)
end

function love.draw()
    stateManager:draw()
end

function love.mousepressed(x, y, button, istouch, presses)
    stateManager:handleInput(x, y, button)
end 