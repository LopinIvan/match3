-- Добавляем текущую директорию в путь поиска модулей
package.path = ".\\?.lua;" .. package.path

local Board = require('console_version.components.Board')
local ConsoleView = require('console_version.view.ConsoleView')

-- Инициализация генератора случайных чисел
math.randomseed(os.time())

-- Создаем экземпляры классов
local board = Board.new()
local view = ConsoleView.new()

-- Устанавливаем модель для представления
view:setModel(board)

-- Инициализируем игровое поле
board:init()

-- Основной игровой цикл
while true do
    -- Отображаем текущее состояние поля
    view:render()
    view:displayPrompt()
    
    -- Читаем ввод пользователя
    local input = io.read()
    if not input then break end
    
    -- Обрабатываем команду выхода
    if input == "q" then
        break
    end
    
    -- Парсим команду перемещения
    local x, y, direction = input:match("^m%s+(%d+)%s+(%d+)%s+([lrud])$")
    
    if x and y and direction then
        x = tonumber(x)
        y = tonumber(y)
        
        -- Определяем координаты целевой ячейки
        local toX, toY = x, y
        if direction == "l" then
            toX = x - 1
        elseif direction == "r" then
            toX = x + 1
        elseif direction == "u" then
            toY = y - 1
        elseif direction == "d" then
            toY = y + 1
        end
        
        -- Пытаемся выполнить ход
        if board:move(x, y, toX, toY) then
            -- Если ход успешен, обрабатываем изменения на поле
            while board:tick() do
                view:render()
                -- Небольшая пауза для анимации (Windows-совместимая версия)
                os.execute("timeout /t 1 >nul")
            end
        else
            view:displayError("Недопустимый ход")
        end
    else
        view:displayError("Неверный формат команды. Используйте: m x y d (где d = l|r|u|d)")
    end
    
    -- Проверяем, есть ли возможные ходы
    local hasValidMoves = false
    for y = 0, 9 do
        for x = 0, 9 do
            -- Проверяем все возможные направления
            for _, d in ipairs({"l", "r", "u", "d"}) do
                local toX, toY = x, y
                if d == "l" then toX = x - 1
                elseif d == "r" then toX = x + 1
                elseif d == "u" then toY = y - 1
                elseif d == "d" then toY = y + 1
                end
                
                -- Временно меняем кристаллы местами и проверяем на совпадения
                if board:move(x, y, toX, toY) then
                    hasValidMoves = true
                    board:move(toX, toY, x, y) -- возвращаем обратно
                    break
                end
            end
            if hasValidMoves then break end
        end
        if hasValidMoves then break end
    end
    
    -- Если нет возможных ходов, перемешиваем поле
    if not hasValidMoves then
        view:displayMessage("Нет возможных ходов. Перемешиваем поле...")
        board:mix()
    end
end

view:displayMessage("Игра завершена") 