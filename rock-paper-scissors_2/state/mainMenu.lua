local MainMenu = Class{}

local win_width = love.graphics.getWidth()
local win_height = love.graphics.getHeight()

local ys = 30

local font = love.graphics.newFont(10)
local align = 'center'

function MainMenu:init()
    local u = Urutora:new()
    
    local center_x = win_width / 2
    local w, h = 400, 35
    local x, y = center_x - w/2, ys
    local label = u.label({
        x = x, y = y,
        w = w, h = h,
        align = align,
        text = 'The Game'
    }):setStyle({ font = love.graphics.newFont(40) })
    y = y + h
    local label2 = u.label({
        x = x, y = y,
        w = w, h = h,
        align = align,
        text = 'about rock-paper-scissors'
    }):setStyle({ font = love.graphics.newFont(15) })

    w = 150
    x, y, w, h = center_x - w/2, y + 100, w, h
    local startButton = u.button({
        x = x, y = y,
        w = w, h = h,
        text = 'Start'
    })
    
    w = 150
    x, y, w, h = center_x - w/2, y + 50, w, h
    local findGameButton = u.button({
        x = x, y = y,
        w = w, h = h,
        text = 'Find game'
    })

    u:add(label)
    u:add(label2)
    u:add(startButton)
    u:add(findGameButton)
    
    self.u = u
end


function MainMenu:update(dt)
    self.u:update(dt)
end

function MainMenu:draw()
    self.u:draw()
end

function MainMenu:mousepressed(x, y, button) self.u:pressed(x, y, button) end
function MainMenu:mousemoved(x, y, dx, dy) self.u:moved(x, y, dx, dy) end
function MainMenu:mousereleased(x, y, button) self.u:released(x, y, button) end
function MainMenu:textinput(text) self.u:textinput(text) end
function MainMenu:keypressed(k, scancode, isrepeat) self.u:keypressed(k, scancode, isrepeat) end
function MainMenu:wheelmoved(x, y) self.u:wheelmoved(x, y) end

return MainMenu