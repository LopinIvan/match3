local EventEmitter = {}
EventEmitter.__index = EventEmitter

function EventEmitter.new()
    local self = setmetatable({}, EventEmitter)
    self._handlers = {}
    return self
end

function EventEmitter:on(event, handler)
    self._handlers[event] = self._handlers[event] or {}
    table.insert(self._handlers[event], handler)
end

function EventEmitter:off(event, handler)
    if self._handlers[event] then
        for i, h in ipairs(self._handlers[event]) do
            if h == handler then
                table.remove(self._handlers[event], i)
                break
            end
        end
    end
end

function EventEmitter:emit(event, ...)
    if self._handlers[event] then
        for _, handler in ipairs(self._handlers[event]) do
            handler(...)
        end
    end
end

return EventEmitter 