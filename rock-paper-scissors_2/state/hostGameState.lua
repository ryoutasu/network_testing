local HostGameState = Class{}

local ys = 30

function HostGameState:init()
    local u = Urutora:new()
    
    local center_x = WIN_WIDTH / 2
    local w, h = 400, 35
    local x, y = center_x - w/2, ys
    local label = u.label({
        x = x, y = y,
        w = w, h = h,
        align = 'center',
        text = 'Host game'
    }):setStyle({ font = LABEL_FONT })

    local backButton = u.button({
        x = 0, y = 0,
        w = 70, h = 30,
        text = 'Back'
    }):action(function ()
        Gamestate.switch(MainMenu)
    end)
    
    u:add(label)
    u:add(backButton)

    self.u = u
end


function HostGameState:update(dt)
    self.u:update(dt)
end

function HostGameState:draw()
    self.u:draw()
end

function HostGameState:mousepressed(x, y, button) self.u:pressed(x, y, button) end
function HostGameState:mousemoved(x, y, dx, dy) self.u:moved(x, y, dx, dy) end
function HostGameState:mousereleased(x, y, button) self.u:released(x, y, button) end
function HostGameState:textinput(text) self.u:textinput(text) end
function HostGameState:keypressed(k, scancode, isrepeat) self.u:keypressed(k, scancode, isrepeat) end
function HostGameState:wheelmoved(x, y) self.u:wheelmoved(x, y) end

return HostGameState