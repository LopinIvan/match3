local ConsoleView = {}
ConsoleView.__index = ConsoleView

local GRID_SIZE = 10

function ConsoleView.new()
    local self = setmetatable({}, ConsoleView)
    self.board = nil
    return self
end

function ConsoleView:setModel(board)
    self.board = board
end

function ConsoleView:update()
    if not self.board then
        return false
    end
    return true
end

function ConsoleView:render()
    if not self.board then
        return
    end
    
    self:clear()
    local grid = self.board:dump()
    
    print("  " .. string.rep("-", GRID_SIZE * 2 + 1))
    
    for y = 0, GRID_SIZE - 1 do
        local row = string.format("%2d|", y)
        for x = 0, GRID_SIZE - 1 do
            row = row .. " " .. grid[y][x]
        end
        print(row)
    end
    
    print("  " .. string.rep("-", GRID_SIZE * 2 + 1))
    
    local xCoords = "   "
    for x = 0, GRID_SIZE - 1 do
        xCoords = xCoords .. string.format("%2d", x)
    end
    print(xCoords)
end

function ConsoleView:clear()
    if os.getenv("OS") == "Windows_NT" then
        os.execute("cls")
    else
        os.execute("clear")
    end
end

function ConsoleView:displayPrompt()
    io.write("> ")
end

function ConsoleView:displayError(message)
    print("Ошибка: " .. message)
end

function ConsoleView:displayMessage(message)
    print(message)
end

return ConsoleView 