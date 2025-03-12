-- Импорт базового класса для работы с событиями
local EventEmitter = require('src.core.EventEmitter')

-- Создание класса AnimationManager, наследующего от EventEmitter
local AnimationManager = setmetatable({}, { __index = EventEmitter })
AnimationManager.__index = AnimationManager

-- Константы времени для различных типов анимаций (в секундах)
local ANIM = {
    SWAP_TIME = 0.3,    -- Время на замену кристаллов
    FALL_TIME = 0.5,    -- Время на падение
    FADE_TIME = 0.3,    -- Время на исчезновение
    SPAWN_TIME = 0.2    -- Время на появление новых
}

-- Конструктор менеджера анимаций
function AnimationManager.new()
    local self = setmetatable(EventEmitter.new(), AnimationManager)
    self._animations = {}  -- Список активных анимаций
    return self
end

-- Создание новой анимации заданного типа
function AnimationManager:createAnimation(type, params)
    local animation = {
        type = type,           -- Тип анимации
        params = params,       -- Параметры анимации
        progress = 0,          -- Прогресс выполнения (0-1)
        duration = ANIM[type .. '_TIME'],  -- Длительность
        complete = false       -- Флаг завершения
    }
    
    -- Добавление анимации в список и оповещение
    table.insert(self._animations, animation)
    self:emit('animationCreated', animation)
    return animation
end

-- Обновление состояния всех анимаций
function AnimationManager:update(dt)
    local completed = {}  -- Список завершенных анимаций
    
    -- Обновление прогресса каждой анимации
    for i, anim in ipairs(self._animations) do
        if not anim.complete then
            -- Увеличение прогресса на основе прошедшего времени
            anim.progress = anim.progress + dt / anim.duration
            
            -- Проверка завершения анимации
            if anim.progress >= 1 then
                anim.progress = 1
                anim.complete = true
                table.insert(completed, anim)
            end
            
            -- Оповещение об обновлении анимации
            self:emit('animationUpdated', anim)
        end
    end
    
    -- Удаление завершенных анимаций из списка
    for i = #self._animations, 1, -1 do
        if self._animations[i].complete then
            table.remove(self._animations, i)
        end
    end
    
    -- Оповещение о завершенных анимациях
    for _, anim in ipairs(completed) do
        self:emit('animationCompleted', anim)
    end
    
    return #self._animations > 0
end

-- Проверка наличия активных анимаций
function AnimationManager:isAnimating()
    return #self._animations > 0
end

-- Очистка всех анимаций
function AnimationManager:clear()
    self._animations = {}
    self:emit('animationsCleared')
end

-- Создание анимации обмена двух кристаллов
function AnimationManager:createSwapAnimation(gem1, gem2)
    return self:createAnimation('SWAP', {
        gem1 = gem1,
        gem2 = gem2,
        startPos1 = {gem1:getPosition()},  -- Начальная позиция первого кристалла
        startPos2 = {gem2:getPosition()},  -- Начальная позиция второго кристалла
        endPos1 = {gem2:getPosition()},    -- Конечная позиция первого кристалла
        endPos2 = {gem1:getPosition()}     -- Конечная позиция второго кристалла
    })
end

-- Создание анимации падения кристалла
function AnimationManager:createFallingAnimation(gem, startY, endY)
    return self:createAnimation('FALL', {
        gem = gem,     -- Падающий кристалл
        startY = startY,  -- Начальная позиция по Y
        endY = endY      -- Конечная позиция по Y
    })
end

-- Создание анимации исчезновения кристалла
function AnimationManager:createFadeAnimation(gem)
    return self:createAnimation('FADE', {
        gem = gem  -- Исчезающий кристалл
    })
end

-- Создание анимации появления кристалла
function AnimationManager:createSpawnAnimation(gem)
    return self:createAnimation('SPAWN', {
        gem = gem  -- Появляющийся кристалл
    })
end

return AnimationManager 