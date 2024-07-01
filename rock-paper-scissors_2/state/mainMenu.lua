local MainMenu = Class{}

local ys = 30

function MainMenu:init()
    local u = Urutora:new()
    
    local center_x = WIN_WIDTH / 2
    local w, h = 400, 35
    local x, y = center_x - w/2, ys
    local label = u.label({
        x = x, y = y,
        w = w, h = h,
        align = 'center',
        text = 'The Game'
    }):setStyle({ font = LABEL_FONT })
    y = y + h
    local label2 = u.label({
        x = x, y = y,
        w = w, h = h,
        align = 'center',
        text = 'about rock-paper-scissors'
    }):setStyle({ font = love.graphics.newFont(15) })

    local exitButton = u.button({
        x = 0, y = 0,
        w = 70, h = 30,
        text = 'Exit'
    }):action(function ()
        love.event.quit()
    end)

    w = 150
    x, y, w, h = center_x - w/2, y + 100, w, h
    local hostGameButton = u.button({
        x = x, y = y,
        w = w, h = h,
        text = 'Host game'
    }):action(function ()
        Gamestate.switch(HostGameState)
    end)
    
    w = 150
    x, y, w, h = center_x - w/2, y + 50, w, h
    local joinGameButton = u.button({
        x = x, y = y,
        w = w, h = h,
        text = 'Join game'
    }):action(function ()
        Gamestate.switch(GameListState)
    end)

    u:add(label)
    u:add(label2)
    u:add(exitButton)
    u:add(hostGameButton)
    u:add(joinGameButton)
    
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