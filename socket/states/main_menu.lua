local MainMenu = Class{}

function MainMenu:init()
    print('main menu init')
    local u = Urutora:new()

    local text = Urutora.label({
        x = 15, y = 15,
        w = 400, h = 50,
        text = 'Socket test'
    }):left()

    u:add(text)

    self.u = u
end

function MainMenu:update(dt)
    self.u:update(dt)
end

function MainMenu:draw()
    self.u:draw()
end


function MainMenu:mousepressed(x, y, button) self.u:pressed(x, y) end
function MainMenu:mousemoved(x, y, dx, dy) self.u:moved(x, y, dx, dy) end
function MainMenu:mousereleased(x, y, button) self.u:released(x, y) end
function MainMenu:textinput(text) self.u:textinput(text) end
function MainMenu:keypressed(k, scancode, isrepeat) self.u:keypressed(k, scancode, isrepeat) end
function MainMenu:wheelmoved(x, y) self.u:wheelmoved(x, y) end

return MainMenu