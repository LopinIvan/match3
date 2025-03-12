local IRenderer = {}
IRenderer.__index = IRenderer

function IRenderer.new()
    error("IRenderer is an interface and cannot be instantiated directly")
end

function IRenderer:draw()
    error("draw() must be implemented by derived classes")
end

function IRenderer:update(dt)
    error("update(dt) must be implemented by derived classes")
end

return IRenderer 