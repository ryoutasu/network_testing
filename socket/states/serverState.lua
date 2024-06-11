local ServerState = Class{}

local xs, ys = 15, 15

function ServerState:host()
    return self.clients[self.clientsID[1]]
end

function ServerState:is_host()
    return self.current_client == self:host()
end

function ServerState:addClient(ip, port, name, id)
    local address = ip..'/'..port
    if not self.clients[address] then
        self.clients[address] = {
            id = id,
            ip = ip,
            port = port,
            name = name
        }
        self.clientsID[id] = address
    end

    return self.clients[address]
end

function ServerState:addMessage(new_message, sender)
    table.insert(self.messages, 1, {
        text = new_message,
        sender = sender
    })

    for i, message in ipairs(self.messages) do
        local clientAddress = self.clientsID[message.sender]
        local client = self.clients[clientAddress]
        
        local messageLabel = self.messageListPanel:getChildren(i, 1)
        if messageLabel then
            messageLabel.text = client.name .. ': ' .. message.text
            messageLabel.tag = 'message_' .. i
        else
            self.messageListPanel:addAt(i, 1, Urutora.label({
                text = client.name .. ': ' .. message.text, tag = 'message_' .. i
            }):left())
        end
    end
end

function ServerState:sendMessage(message, sender_id)
    for key, client in pairs(self.clients) do
        Host:send({ cmd = 'msg', msg = message, sender = sender_id }, client.ip, client.port)
    end
end

function ServerState:init()
    local u = Urutora:new()

    self.clients = {}
    self.clientsID = {}
    self.messages = {}
    
    local x, y, w, h = xs, ys, 550-xs-xs, 30
    local label = Urutora.label({
        x = x, y = y,
        w = w, h = h,
        text = 'Server: '
    }):left()

    x, y, w, h = x, y + label.h + ys, w - 50, 30
    local messageText = Urutora.text({
        x = x, y = y,
        w = w, h = h,
        text = 'Message...'
    }):right()
    local sendButton = Urutora.button({
        x = messageText.x + messageText.w + 10, y = y,
        w = 40, h = h,
        text = 'Send'
    })
    sendButton:action(function (e)
        self:sendMessage(messageText.text, self.current_client.id)
        self:receive()
    end)

    x, y, w, h = x, y + label.h + ys, 550-xs-xs, 480
    local rows, cols = 20, 1
    local messageListPanel = Urutora.panel({
        x = x, y = y,
        w = w, h = h,
        rows = rows, cols = cols,
        cellHeight = h/rows
    })

    -- for i = 1, 40, 1 do
    --     messageListPanel:addAt(i, 1, Urutora.label({
    --         text = '[...]', tag = 'message_' .. i
    --     }):left())
    -- end

    u:add(label)
    u:add(messageText)
    u:add(sendButton)
    u:add(messageListPanel)

    self.label = label
    self.messageListPanel = messageListPanel

    self.u = u
end

function ServerState:config(username)
    -- print(Host.ip, Host.port, username)
    local client = self:addClient(Host.ip, Host.port, username, 1)
    -- self.host = self.clients[address]
    self.current_client = client
    Host:broadcast({ cmd = 'server_up', name = self.name, users = #self.clientsID, maxUsers = 20 })
    self:sendMessage('[Connected]', client.id)
    self:receive()
end

function ServerState:enter(state, serverName, username, server)
    self.name = serverName
    self.label.text = serverName

    if server.ip == Host.ip and server.port == Host.port then
        self:config(username)
    else
        Host:send({ cmd = 'connect', username = username }, server.ip, server.port)
    end

    -- self.current_client = client
    -- self:receive()
end

function ServerState:receive()
    while true do
        local data, msg_or_ip, port_or_nil = Host:receive()
        if not data then return end

        -- print(data, msg_or_ip, port_or_nil)
        if type(data) == "string" then
            if data == 'is_server_up' and self:is_host() then
                Host:send({ cmd = 'server_up', name = self.name, users = #self.clientsID, maxUsers = 20 }, msg_or_ip, port_or_nil)
            end
        end
        
        if type(data) == "table" then
            -- print(data.cmd)
            if data.cmd == 'connect' then
                Host:send({ cmd = 'clients', clients = self.clients, clientsID = self.clientsID }, msg_or_ip, port_or_nil)
                local id = #self.clientsID + 1
                for address, client in pairs(self.clients) do
                    Host:send({ cmd = 'new_client', id = id, ip = msg_or_ip, port = port_or_nil, username = data.username }, client.ip, client.port)
                end
                Host:send({ cmd = 'new_client', id = id, ip = msg_or_ip, port = port_or_nil, username = data.username }, msg_or_ip, port_or_nil)
            end

            if data.cmd == 'clients' then
                self.clients = data.clients
                self.clientsID = data.clientsID
            end

            if data.cmd == 'new_client' then
                local port = tonumber(data.port)
                local client = self:addClient(data.ip, port, data.username, data.id)
                if Host.ip == data.ip and Host.port == port then
                    -- print('Added client is current client')
                    self.current_client = client
                    self:sendMessage('[Connected]', data.id)
                end
            end

            if data.cmd == 'msg' then
                self:addMessage(data.msg, data.sender)
            end
        end
    end
end

local timer, receiveTime = 0, 2
function ServerState:update(dt)
    timer = timer + dt
    if timer >= receiveTime then
        self:receive()
        timer = 0
    end

    self.u:update(dt)
end

function ServerState:draw()
    self.u:draw()
end

function ServerState:mousepressed(x, y, button) self.u:pressed(x, y, button) end
function ServerState:mousemoved(x, y, dx, dy) self.u:moved(x, y, dx, dy) end
function ServerState:mousereleased(x, y, button) self.u:released(x, y, button) end
function ServerState:textinput(text) self.u:textinput(text) end
function ServerState:keypressed(k, scancode, isrepeat) self.u:keypressed(k, scancode, isrepeat) end
function ServerState:wheelmoved(x, y) self.u:wheelmoved(x, y) end

return ServerState