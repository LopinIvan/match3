local EventEmitter = require('src.core.EventEmitter')

local StateManager = setmetatable({}, { __index = EventEmitter })
StateManager.__index = StateManager

function StateManager.new()
    local self = setmetatable(EventEmitter.new(), StateManager)
    self._states = {}
    self._currentState = nil
    return self
end

function StateManager:addState(name, state)
    self._states[name] = state
end

function StateManager:changeState(name)
    if self._states[name] then
        if self._currentState then
            self._currentState:exit()
        end
        
        self._currentState = self._states[name]
        self._currentState:enter()
        
        self:emit('stateChanged', name)
    end
end

function StateManager:getCurrentState()
    return self._currentState
end

function StateManager:update(dt)
    if self._currentState then
        self._currentState:update(dt)
    end
end

function StateManager:draw()
    if self._currentState then
        self._currentState:draw()
    end
end

function StateManager:handleInput(x, y, button)
    if self._currentState then
        local result = self._currentState:handleInput(x, y, button)
        if result then
            self:emit('stateInput', result)
        end
        return result
    end
    return false
end

return StateManager 