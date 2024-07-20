local MainMenu = Class{}

local ys = 30

local function try_connect(port)
    port = port or 12345

    if Network.connected then return true end

    return Network:connect(port)
end

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
    
    local portText = u.text({
        x = WIN_WIDTH - 100, y = 0,
        w = 100, h = 30,
        align = 'right',
        text = '12345',
    }):hide()

    w = 150
    x, y, w, h = center_x - w/2, y + 100, w, h
    local playernameText = u.text({
        x = x, y = y,
        w = w, h = h,
        align = 'center',
        text = Player.name
    }):action(function (e)
        Player.name = e.target.text
    end)

    w = 150
    x, y, w, h = center_x - w/2, y + 75, w, h
    local hostGameButton = u.button({
        x = x, y = y,
        w = w, h = h,
        text = 'Host game'
    }):action(function ()
        if try_connect(tonumber(portText.text)) then
            Gamestate.switch(HostGameState)
        end
    end)
    
    w = 150
    x, y, w, h = center_x - w/2, y + 50, w, h
    local joinGameButton = u.button({
        x = x, y = y,
        w = w, h = h,
        text = 'Join game'
    }):action(function ()
        if try_connect(tonumber(portText.text)) then
            Gamestate.switch(GameListState)
        end
    end)

    u:add(label)
    u:add(label2)
    u:add(exitButton)
    u:add(playernameText)
    u:add(portText)
    u:add(hostGameButton)
    u:add(joinGameButton)

    self.portText = portText
    
    self.u = u
    setup_state_urutora(self)
end

function MainMenu:keypressed(k)
    if k == 'f1' then
        self.portText.visible = not self.portText.visible
    end
end

function MainMenu:quit()
    print('quitting from MainMenu')
end

return MainMenu