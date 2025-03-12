local IGameState = {}
IGameState.__index = IGameState

function IGameState.new()
    error("IGameState is an interface and cannot be instantiated directly")
end

function IGameState:enter()
    error("enter() must be implemented by derived classes")
end

function IGameState:exit()
    error("exit() must be implemented by derived classes")
end

function IGameState:update(dt)
    error("update(dt) must be implemented by derived classes")
end

function IGameState:draw()
    error("draw() must be implemented by derived classes")
end

function IGameState:handleInput(x, y, button)
    error("handleInput(x, y, button) must be implemented by derived classes")
end

return IGameState 