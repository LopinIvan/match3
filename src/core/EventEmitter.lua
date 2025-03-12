-- Базовый класс для реализации системы событий
local EventEmitter = {}
EventEmitter.__index = EventEmitter

-- Конструктор эмиттера событий
function EventEmitter.new()
    local self = setmetatable({}, EventEmitter)
    self._handlers = {}  -- Хранилище обработчиков событий
    return self
end

-- Подписка на событие
-- @param event - название события
-- @param handler - функция-обработчик
function EventEmitter:on(event, handler)
    -- Создаем массив обработчиков для события, если его еще нет
    self._handlers[event] = self._handlers[event] or {}
    -- Добавляем новый обработчик
    table.insert(self._handlers[event], handler)
end

-- Отписка от события
-- @param event - название события
-- @param handler - функция-обработчик для удаления
function EventEmitter:off(event, handler)
    if self._handlers[event] then
        -- Ищем и удаляем указанный обработчик
        for i, h in ipairs(self._handlers[event]) do
            if h == handler then
                table.remove(self._handlers[event], i)
                break
            end
        end
    end
end

-- Генерация события
-- @param event - название события
-- @param ... - дополнительные параметры для передачи обработчикам
function EventEmitter:emit(event, ...)
    if self._handlers[event] then
        -- Вызываем все обработчики данного события
        for _, handler in ipairs(self._handlers[event]) do
            handler(...)
        end
    end
end

return EventEmitter 