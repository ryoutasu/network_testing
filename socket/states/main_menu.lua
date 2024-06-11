local MainMenu = Class{}

local xs, ys = 15, 15

function MainMenu:createHost(port)
    if tonumber(port) > 65535 then return false end
    Host = Network(tonumber(port))
    self.portText:disable()
    self.connectButton:disable()
    self.serverButton:enable()
    self.refreshButton:enable()
    return true
end

function MainMenu:init()
    local u = Urutora:new()
    self.serverList = {}
    self.serverListID = {}

    local x, y, w, h = xs, ys, 400-xs-xs, 30
    local label = Urutora.label({
        x = x, y = y,
        w = w, h = h,
        text = 'Socket broadcast test'
    }):left()

    x, y, w, h = x, y + label.h + ys, w, 500
    local rows, cols = 10, 6
    local serverListPanel = Urutora.panel({
        x = x, y = y,
        w = w, h = h,
        rows = rows, cols = cols,
        cellHeight = h/rows
    })

    for i = 1, 20, 1 do
        serverListPanel:rowspanAt(i, 1, cols-1):addAt(i, 1, Urutora.button({
            text = 'Placeholder '..i, tag = 'button_'..i
        }):left():disable())

        serverListPanel:addAt(i, cols, Urutora.label({
            text = '0/0', tag = 'label_'..i
        }):right())
    end


    x, y, w, h = x + label.w + xs + xs, ys, w, 30
    local usernameLabel = Urutora.label({
        x = x, y = y,
        w = 100, h = h,
        text = 'Username:'
    }):left()
    local usernameText = Urutora.text({
        x = x + xs + usernameLabel.w, y = y,
        w = 220, h = h,
        text = 'user_' .. math.random(1, 1024)
    }):right()


    x, y, w, h = x, y + h + ys, w, 30
    local portLabel = Urutora.label({
        x = x, y = y,
        w = 50, h = h,
        text = 'Port:'
    }):left()
    local portText = Urutora.text({
        x = x + xs + portLabel.w, y = y,
        w = 160, h = h,
        text = '12345'
    }):right()
    local connectButton = Urutora.button({
        x = portText.x + portText.w + xs, y = y,
        w = 120, h = h,
        text = 'Connect'
    })
    connectButton:action(function (e)
        if not self:createHost(portText.text) then return end
        Host:broadcast('is_server_up')
        self.connected = true
    end)


    x, y, w, h = x, y + h + ys, w, 30
    local serverLabel = Urutora.label({
        x = x, y = y,
        w = 50, h = h,
        text = 'Name:'
    }):left()
    local serverText = Urutora.text({
        x = x + xs + serverLabel.w, y = y,
        w = 160, h = h,
        text = 'New server ' .. math.random(1, 1024)
    }):right()
    local serverButton = Urutora.button({
        x = serverText.x + serverText.w + xs, y = y,
        w = 120, h = h,
        text = 'Create server'
    }):disable()
    serverButton:action(function (e)
        Gamestate.switch(ServerState, serverText.text, usernameText.text, { ip = Host.ip, port = Host.port })
    end)


    x, y, w, h = serverButton.x, y + h + ys, serverButton.w, h
    local refreshButton = Urutora.button({
        x = x, y = y,
        w = w, h = h,
        text = 'Refresh'
    }):disable()
    refreshButton:action(function (e)
        Host:broadcast('is_server_up')
    end)

    u:add(label)
    u:add(serverListPanel)
    u:add(usernameLabel)
    u:add(usernameText)
    u:add(portLabel)
    u:add(portText)
    u:add(connectButton)
    u:add(serverLabel)
    u:add(serverText)
    u:add(serverButton)
    u:add(refreshButton)

    self.label = label
    self.serverListPanel = serverListPanel
    self.usernameText = usernameText
    self.portText = portText
    self.connectButton = connectButton
    self.serverButton = serverButton
    self.refreshButton = refreshButton

    self.u = u
    self.connected = false
end

function MainMenu:addServerToList(ip, port, data)
    local address = ip..'/'..port
    if not self.serverList[address] then
        local id = #self.serverList + 1
        local server = {
            ip = ip,
            port = port,
            id = id
        }
        self.serverList[address] = server
        self.serverListID[id] = address

        local button = self.serverListPanel:findFromTag('button_'..id)
        local label = self.serverListPanel:findFromTag('label_'..id)

        button.text = data.name
        label.text = data.users..'/'..data.maxUsers

        button:enable():action(function (e)
            Gamestate.switch(ServerState, data.name, self.usernameText.text, { ip = ip, port = port })
        end)
    end
end

function MainMenu:receive()
    while true do
        local data, msg_or_ip, port_or_nil = Host:receive()
        -- data, msg_or_ip, port_or_nil = Host.udp:receivefrom()
        if not data then return end

        -- print(data, msg_or_ip, port_or_nil)
        if type(data) == "table" then
            if data.cmd == 'server_up' then
                self:addServerToList(msg_or_ip, port_or_nil, data)
            end
        end
    end
end

local timer, receiveTime = 0, 2
function MainMenu:update(dt)
    if self.connected then
        timer = timer + dt
        if timer >= receiveTime then
            self:receive()
            timer = 0
        end
    end

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