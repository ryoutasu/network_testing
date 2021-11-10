local enet = require 'enet'
local urutora = require 'libs.urutora'
local u = urutora:new()

local host = nil
local peers = {}

local portName = nil
local hostBtn = nil
local connectBtn = nil
local multiconnectBtn = nil
local msgBox = nil
local sendBtn = nil
local peersN = nil
local messageList = {} -- stores text of all recieved messages
local messagesPanel = nil
local maxMessages = 20
local messageListScroll = nil

local function try_to_connect(address)
    if not peers[address] then
        local peer = host:connect(address)
        return peer
    else
        --return 'Peer '..tostring(peer)..' already connected'
        return peers[address]
    end
end

local function add_message(sender, text)
    table.insert(messageList, 1, { sender = sender, text = text })
    if #messageList > maxMessages then
        table.remove(messageList)
    end
    for i, v in ipairs(messageList) do
        local str = tostring(v.sender)..': '..v.text
        -- messagesPanel:addAt(i, 1, u.label({text = str}))
        messagesPanel:findFromTag('msgbox_'..i).text = str
    end
end

function love.load()
    portName = urutora.text({
        text = '6750',
        x = 10, y = 10,
        w = 100, h = 50
    })

    hostBtn = urutora.button({
        text = 'Host',
        x = 120, y = 10,
        w = 80, h = 50
    }):action(function(e)
        host = enet.host_create('*:'..portName.text)
        print('Hosted with address ', host:get_socket_address())

        hostBtn:disable()
        connectBtn:disable()
    end)

    connectBtn = urutora.button({
        text = 'Connect',
        x = 210, y = 10,
        w = 80, h = 50
    }):action(function(e)
        if not host then
            host = enet.host_create()
            print('Created host with address ', host:get_socket_address())
        end
        try_to_connect("127.0.0.1:"..portName.text)
        -- peers[peer] = 1
        hostBtn:disable()
        connectBtn:disable()
    end)

    -- multiconnectBtn = urutora.button({
    --     text = 'Multiconnection',
    --     x = 300, y = 10,
    --     w = 140, h = 50
    -- }):action(function(e)
    --     if not host then
    --         host = enet.host_create()
    --         print('Created host with address ', host:get_socket_address())
    --     end
    --     local peer = try_to_connect("127.0.0.1:"..portName.text)
    --     if peer then
    --         peer:send('multiconnection _')
    --     end
    -- end)

    msgBox = urutora.text({
        x = 10, y = 100,
        w = 400, h = 50
    })

    sendBtn = urutora.button({
        text = 'Send',
        x = 420, y = 100,
        w = 50, h = 50
    }):action(function(e)
        host:broadcast('message '..msgBox.text)
        add_message('self', msgBox.text)
        msgBox.text = ''
    end)

    peersN = urutora.label({
        text = 'Number of peers = ',
        x = 480, y = 10,
        w = 210, h = 400
    }):left():up()

    messagesPanel = urutora.panel({
        x = 10, y = 160,
        w = 400, h = 430,
        rows = 20, cols = 1, csy = 30
    })
    messagesPanel.outline = true
    for i = 1, 20 do
        messagesPanel:addAt(i, 1, u.label({text = '', tag = 'msgbox_'..i}):left())
    end

    messageListScroll = urutora.slider({
        x = 420, y = 160,
        w = 50, h = 430,
        value = 0, axis = 'y'
    }):action(function(e)
        messagesPanel:setScrollY(e.target.value)
    end)

    messagesPanel:action(function(e)
        messageListScroll:setValue(e.target:getScrollY())
    end)

    u:add(portName)
    u:add(hostBtn)
    u:add(connectBtn)
    -- u:add(multiconnectBtn)
    u:add(msgBox)
    u:add(sendBtn)
    u:add(peersN)
    u:add(messagesPanel)
    u:add(messageListScroll)
end

function love.update(dt)
    u:update(dt)

    if host then
        local event = host:service(10)

        while event do
            print("Server detected message type: " .. event.type)
            if event.type == "connect" then
                print(event.peer, "connected.")

                for peer, v in pairs(peers) do
                    if v and tostring(event.peer) ~= peer then
                        event.peer:send('newpeer '..tostring(peer))
                    end
                end

                peers[tostring(event.peer)] = event.peer
                
            elseif event.type == 'disconnect' then
                print(event.peer, "disconnected.")

                peers[tostring(event.peer)] = nil

            elseif event.type == "receive" then
                print("Received message: ", event.data, event.peer)

                local cmd, parms = event.data:match("^(%S*) (.*)")
                if cmd == 'message' then
                    print('New message from '..tostring(event.peer)..': '..parms)
                    add_message(event.peer, parms)
                elseif cmd == 'newpeer' then
                    try_to_connect(parms)
                elseif cmd == 'multiconnection' then
                    for peer, v in pairs(peers) do
                        if v and tostring(event.peer) ~= peer then
                            event.peer:send('newpeer '..tostring(peer))
                        end
                    end
                else
                    print('Unrecognised command:', cmd, parms)
                end
            end
            event = host:service()
        end
    end

    local n = 0
    local str = ''
    for key, value in pairs(peers) do
        if value then
            n = n + 1
            str = str..'Peer number '..n..': '..tostring(key)..'\n'
        end
    end
    str = str..'Number of peers = '..n
    peersN.text = str
end

function love.draw()
    u:draw()
end

function love.mousepressed(x, y, button) u:pressed(x, y) end
function love.mousemoved(x, y, dx, dy) u:moved(x, y, dx, dy) end
function love.mousereleased(x, y, button) u:released(x, y) end
function love.textinput(text) u:textinput(text) end
function love.keypressed(k, scancode, isrepeat) u:keypressed(k, scancode, isrepeat) end
function love.wheelmoved(x, y) u:wheelmoved(x, y) end