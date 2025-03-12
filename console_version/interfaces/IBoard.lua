local IBoard = {}
IBoard.__index = IBoard

function IBoard:init()
    error("Метод init() должен быть реализован")
end

function IBoard:tick()
    error("Метод tick() должен быть реализован")
end

function IBoard:move(fromX, fromY, toX, toY)
    error("Метод move() должен быть реализован")
end

function IBoard:mix()
    error("Метод mix() должен быть реализован")
end

function IBoard:dump()
    error("Метод dump() должен быть реализован")
end

return IBoard 