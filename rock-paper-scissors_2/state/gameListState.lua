local GameListState = Class{}

local ys = 30
local offset = 30

function GameListState:init()
    local u = Urutora:new()
    self.serverList = {}
    self.serverListID = {}
    
    local center_x = WIN_WIDTH / 2
    local w, h = 400, 35
    local x, y = center_x - w/2, ys
    local label = u.label({
        x = x, y = y,
        w = w, h = h,
        align = 'center',
        text = 'Join game'
    }):setStyle({ font = LABEL_FONT })

    local backButton = u.button({
        x = 0, y = 0,
        w = 70, h = 30,
        text = 'Back'
    }):action(function ()
        Gamestate.switch(MainMenu)
    end)

    w, h = WIN_WIDTH - 100, WIN_HEIGHT - y - h - ys - offset
    x, y = center_x - w/2, y + label.h + offset
    local rows, cols = 10, 6
    local gameListPanel = u.panel({
        x = x, y = y,
        w = w, h = h,
        rows = rows, cols = cols,
        cellHeight = h/rows
    })

    for i = 1, 20, 1 do
        gameListPanel:rowspanAt(i, 1, cols-1):addAt(i, 1, Urutora.button({
            text = 'Placeholder '..i, tag = 'button_'..i
        }):left():disable())

        gameListPanel:addAt(i, cols, Urutora.label({
            text = '0/0', tag = 'label_'..i
        }):right())
    end

    u:add(label)
    u:add(backButton)
    u:add(gameListPanel)

    self.gameListPanel = gameListPanel
    
    self.u = u
    setup_state_input(self)
end

function GameListState:enter()
    Host:broadcast('is_server_up')
end

function GameListState:addServerToList(ip, port, data)
    local address = ip..'/'..port
    if not self.serverList[address] then
        local id = #self.serverListID + 1
        local server = {
            ip = ip,
            port = port,
            id = id,
        }
        self.serverList[address] = server
        self.serverListID[id] = address

        local button = self.gameListPanel:findFromTag('button_'..id)
        local label = self.gameListPanel:findFromTag('label_'..id)

        button.text = data.name
        -- label.text = data.users..'/'..data.maxUsers
        label.text = '1/2'

        button:enable():action(function (e)
            Gamestate.switch(GameState, { ip = ip, port = port }, data.name)
        end)
    end
end

function GameListState:removeServerFromList(ip, port)
    local address = ip..'/'..port
    if self.serverList[address] then
        local server = self.serverList[address]
        local id = server.id

        local lastID = #self.serverListID
        if id ~= lastID then
            local lastAddress = self.serverListID[lastID]
            local lastServer = self.serverList[lastAddress]
            lastServer.id = id
            self.serverListID[id] = lastAddress

            local button = self.gameListPanel:findFromTag('button_'..id)
            local label = self.gameListPanel:findFromTag('label_'..id)
    
            button.text = lastServer.name
            -- label.text = data.users..'/'..data.maxUsers
            label.text = '1/2'
    
            button:enable():action(function (e)
                Gamestate.switch(GameState, { ip = ip, port = port }, lastServer.name)
            end)
        end

        self.serverList[address] = nil
        self.serverListID[lastID] = nil

        local lastButton = self.gameListPanel:findFromTag('button_'..lastID)
        local lastLabel = self.gameListPanel:findFromTag('label_'..lastID)

        lastButton.text = 'Placeholder '..lastID
        lastLabel.text = '0/0'
        lastButton:disable()
    end
end

local timer = 0
function GameListState:receive(dt)
    timer = timer + dt
    if timer < RECEIVE_UPDATE_TIME then
        return
    end
    timer = 0

    while true do
        local data, msg_or_ip, port_or_nil = Host:receive()
        -- data, msg_or_ip, port_or_nil = Host.udp:receivefrom()
        if not data then return end

        if type(data) == "string" then
            if data == 'remove_from_list' then
                self:removeServerFromList(msg_or_ip, port_or_nil)
            end
        end

        if type(data) == "table" then
            if data.cmd == 'server_up' then
                self:addServerToList(msg_or_ip, port_or_nil, data)
            end
        end
    end
end

function GameListState:update(dt)
    self:receive(dt)
    self.u:update(dt)
end

function GameListState:quit()
    print('quitting from GameListState')
end

return GameListState