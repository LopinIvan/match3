-- Импорт необходимых модулей
local StateManager = require('src.core.StateManager')
local MenuState = require('src.states.MenuState')
local GameState = require('src.states.GameState')

-- Функция инициализации игры, вызывается при запуске
function love.load()
    -- Инициализация генератора случайных чисел
    math.randomseed(os.time())
    
    -- Настройка окна игры
    love.window.setMode(800, 600, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
    love.window.setTitle("Match-3 Game")
    
    -- Создание менеджера состояний
    stateManager = StateManager.new()
    
    -- Добавление состояний игры
    stateManager:addState('menu', MenuState.new())
    stateManager:addState('game', GameState.new())
    
    -- Обработка переходов между состояниями
    stateManager:on('stateInput', function(action)
        if action == 'startGame' then
            stateManager:changeState('game')
        elseif action == 'exitToMenu' then
            stateManager:changeState('menu')
        end
    end)
    
    -- Установка начального состояния
    stateManager:changeState('menu')
end

-- Функция обновления игры, вызывается каждый кадр
function love.update(dt)
    stateManager:update(dt)
end

-- Функция отрисовки игры, вызывается каждый кадр
function love.draw()
    stateManager:draw()
end

-- Обработка нажатий мыши
function love.mousepressed(x, y, button, istouch, presses)
    stateManager:handleInput(x, y, button)
end 