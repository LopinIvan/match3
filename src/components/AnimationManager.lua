local EventEmitter = require('src.core.EventEmitter')

local AnimationManager = setmetatable({}, { __index = EventEmitter })
AnimationManager.__index = AnimationManager

local ANIM = {
    SWAP_TIME = 0.3,    -- Время на замену кристаллов
    FALL_TIME = 0.5,    -- Время на падение
    FADE_TIME = 0.3,    -- Время на исчезновение
    SPAWN_TIME = 0.2    -- Время на появление новых
}

function AnimationManager.new()
    local self = setmetatable(EventEmitter.new(), AnimationManager)
    self._animations = {}
    return self
end

function AnimationManager:createAnimation(type, params)
    local animation = {
        type = type,
        params = params,
        progress = 0,
        duration = ANIM[type .. '_TIME'],
        complete = false
    }
    
    table.insert(self._animations, animation)
    self:emit('animationCreated', animation)
    return animation
end

function AnimationManager:update(dt)
    local completed = {}
    
    for i, anim in ipairs(self._animations) do
        if not anim.complete then
            anim.progress = anim.progress + dt / anim.duration
            
            if anim.progress >= 1 then
                anim.progress = 1
                anim.complete = true
                table.insert(completed, anim)
            end
            
            self:emit('animationUpdated', anim)
        end
    end
    
    for i = #self._animations, 1, -1 do
        if self._animations[i].complete then
            table.remove(self._animations, i)
        end
    end
    
    for _, anim in ipairs(completed) do
        self:emit('animationCompleted', anim)
    end
    
    return #self._animations > 0
end

function AnimationManager:isAnimating()
    return #self._animations > 0
end

function AnimationManager:clear()
    self._animations = {}
    self:emit('animationsCleared')
end

function AnimationManager:createSwapAnimation(gem1, gem2)
    return self:createAnimation('SWAP', {
        gem1 = gem1,
        gem2 = gem2,
        startPos1 = {gem1:getPosition()},
        startPos2 = {gem2:getPosition()},
        endPos1 = {gem2:getPosition()},
        endPos2 = {gem1:getPosition()}
    })
end

function AnimationManager:createFallingAnimation(gem, startY, endY)
    return self:createAnimation('FALL', {
        gem = gem,
        startY = startY,
        endY = endY
    })
end

function AnimationManager:createFadeAnimation(gem)
    return self:createAnimation('FADE', {
        gem = gem
    })
end

function AnimationManager:createSpawnAnimation(gem)
    return self:createAnimation('SPAWN', {
        gem = gem
    })
end

return AnimationManager 