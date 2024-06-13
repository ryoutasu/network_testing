local ServerState = Class{}

local xs, ys = 15, 15

function ServerState:host()
    return self.clients[1]
end

function ServerState:is_host()
    return self.current_client == self:host()
end

function ServerState:addClient(ip, port, name, id)
    for i, client in ipairs(self.clients) do
        if client.ip == ip and client.port == port then
            return client
        end
    end

    if not self.clients[id] then
        self.clients[id] = {
            id = id,
            ip = ip,
            port = port,
            name = name
        }
    end

    local userLabel = self.userlistPanel:getChildren(id, 1)
    if not userLabel then
        self.userlistPanel:addAt(id, 1, Urutora.label({
            text = name, tag = 'user_' .. id
        }):left())
    end

    return self.clients[id]
end

function ServerState:addMessage(new_message, sender)
    table.insert(self.messages, 1, {
        text = new_message,
        sender = sender
    })

    for i, message in ipairs(self.messages) do
        local client = self.clients[message.sender]
        
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
    for id, client in pairs(self.clients) do
        Host:send({ cmd = 'msg', msg = message, sender = sender_id }, client.ip, client.port)
    end
end

function ServerState:init()
    local u = Urutora:new()

    self.clients = {}
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
        text = 'Hello there!'
    }):right():action(function (e)
        if e.value.scancode == 'return' then
            self:sendMessage(e.value.newText, self.current_client.id)
            self:receive()
            u:setFocusedNode(e.target)
            e.target.text = ''
        end
    end)
    local sendButton = Urutora.button({
        x = messageText.x + messageText.w + 10, y = y,
        w = 40, h = h,
        text = 'Send'
    })
    sendButton:action(function (e)
        self:sendMessage(messageText.text, self.current_client.id)
        self:receive()
        u:setFocusedNode(messageText)
        messageText.text = ''
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

    x, y, w, h = label.x + label.w + xs, ys, 200, 30
    local userlistLabel = Urutora.label({
        x = x, y = y,
        w = w, h = h,
        text = 'Userlist:'
    }):left()
    rows, cols = 20, 1
    h = 480
    local userlistPanel = Urutora.panel({
        x = x, y = y + userlistLabel.h + ys,
        w = w, h = h,
        rows = rows, cols = cols,
        cellHeight = h/rows
    })

    u:add(label)
    u:add(messageText)
    u:add(sendButton)
    u:add(messageListPanel)
    u:add(userlistLabel)
    u:add(userlistPanel)

    self.label = label
    self.messageListPanel = messageListPanel
    self.userlistPanel = userlistPanel

    self.u = u
end

function ServerState:config(username)
    -- print(Host.ip, Host.port, username)
    local client = self:addClient(Host.ip, Host.port, username, 1)
    self.current_client = client
    Host:broadcast({ cmd = 'server_up', name = self.name, users = #self.clients, maxUsers = 20 })
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
end

function ServerState:receive()
    while true do
        local data, msg_or_ip, port_or_nil = Host:receive()
        if not data then return end

        -- print(data, msg_or_ip, port_or_nil)
        if type(data) == "string" then
            if data == 'is_server_up' and self:is_host() then
                Host:send({ cmd = 'server_up', name = self.name, users = #self.clients, maxUsers = 20 }, msg_or_ip, port_or_nil)
            end
        end
        
        if type(data) == "table" then
            -- print(data.cmd)
            if data.cmd == 'connect' then
                local new_id = #self.clients + 1
                for id, client in ipairs(self.clients) do
                    Host:send({ cmd = 'new_client', id = new_id, ip = msg_or_ip, port = port_or_nil, username = data.username }, client.ip, client.port)
                end
                Host:send({ cmd = 'clients', clients = self.clients, id = new_id, ip = msg_or_ip, port = port_or_nil, username = data.username }, msg_or_ip, port_or_nil)
            end

            if data.cmd == 'clients' then
                for id, client in ipairs(data.clients) do
                    self:addClient(client.ip, client.port, client.name, id)
                end
                -- self.clients = data.clients
                
                local port = tonumber(data.port)
                local client = self:addClient(data.ip, port, data.username, data.id)
                self.current_client = client
                self:sendMessage('[Connected]', data.id)
            end

            if data.cmd == 'new_client' then
                local port = tonumber(data.port)
                local client = self:addClient(data.ip, port, data.username, data.id)
            end

            if data.cmd == 'msg' then
                self:addMessage(data.msg, data.sender)
            end
        end
    end
end

local timer, receiveTime = 0, 1
function ServerState:update(dt)
    self:receive()

    self.u:update(dt)
end

function ServerState:draw()
    self.u:draw()
end

function ServerState:keypressed(key, scancode, isrepeat)
    -- if key == 'enter' then
        
    -- end
    self.u:keypressed(key, scancode, isrepeat)
end
function ServerState:mousepressed(x, y, button) self.u:pressed(x, y, button) end
function ServerState:mousemoved(x, y, dx, dy) self.u:moved(x, y, dx, dy) end
function ServerState:mousereleased(x, y, button) self.u:released(x, y, button) end
function ServerState:textinput(text) self.u:textinput(text) end
function ServerState:wheelmoved(x, y) self.u:wheelmoved(x, y) end

return ServerState