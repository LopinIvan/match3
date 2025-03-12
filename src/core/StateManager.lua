-- Импорт базового класса для работы с событиями
local EventEmitter = require('src.core.EventEmitter')

-- Создание класса StateManager, наследующего от EventEmitter
local StateManager = setmetatable({}, { __index = EventEmitter })
StateManager.__index = StateManager

-- Конструктор менеджера состояний
function StateManager.new()
    local self = setmetatable(EventEmitter.new(), StateManager)
    self._states = {}  -- Хранилище всех состояний
    self._currentState = nil  -- Текущее активное состояние
    return self
end

-- Добавление нового состояния в менеджер
function StateManager:addState(name, state)
    self._states[name] = state
end

-- Смена текущего состояния
function StateManager:changeState(name)
    if self._states[name] then
        -- Выход из текущего состояния, если оно существует
        if self._currentState then
            self._currentState:exit()
        end
        
        -- Активация нового состояния
        self._currentState = self._states[name]
        self._currentState:enter()
        
        -- Оповещение о смене состояния
        self:emit('stateChanged', name)
    end
end

-- Получение текущего активного состояния
function StateManager:getCurrentState()
    return self._currentState
end

-- Обновление текущего состояния
function StateManager:update(dt)
    if self._currentState then
        self._currentState:update(dt)
    end
end

-- Отрисовка текущего состояния
function StateManager:draw()
    if self._currentState then
        self._currentState:draw()
    end
end

-- Обработка пользовательского ввода
function StateManager:handleInput(x, y, button)
    if self._currentState then
        local result = self._currentState:handleInput(x, y, button)
        if result then
            -- Отправка события о пользовательском вводе
            self:emit('stateInput', result)
        end
        return result
    end
    return false
end

return StateManager 