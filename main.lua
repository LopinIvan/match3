local StateManager = require('src.core.StateManager')
local MenuState = require('src.states.MenuState')
local GameState = require('src.states.GameState')

function love.load()
    -- Инициализация генератора случайных чисел
    math.randomseed(os.time())
    
    -- Устанавливаем размер окна и заголовок
    love.window.setMode(800, 600, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
    love.window.setTitle("Match-3 Game")
    
    -- Создаем менеджер состояний
    stateManager = StateManager.new()
    
    -- Добавляем состояния
    stateManager:addState('menu', MenuState.new())
    stateManager:addState('game', GameState.new())
    
    -- Подписываемся на события состояний
    stateManager:on('stateInput', function(action)
        if action == 'startGame' then
            stateManager:changeState('game')
        elseif action == 'exitToMenu' then
            stateManager:changeState('menu')
        end
    end)
    
    -- Начинаем с меню
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