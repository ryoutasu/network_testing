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
        Network:close()
    end)

    w = 150
    x, y, w, h = center_x - w/2, y + 100, w, h
    local startButton = u.button({
        x = x, y = y,
        w = w, h = h,
        text = 'Start'
    }):action(function ()
        Gamestate.switch(GameState, { ip = Network.ip, port = Network.port })
    end)
    
    u:add(label)
    u:add(backButton)
    u:add(startButton)

    self.u = u
    setup_state_input(self)
end

function HostGameState:quit()
    print('quitting from HostGameState')
end

return HostGameState