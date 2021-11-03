local enet = require "enet"
local urutora = require 'libs.urutora'

local peer = nil
local host =  nil

local u = urutora:new()
local btnW = 800 / 3 - 10 - 10/3
local btnH = 100

local roundNum = 0
local players = {
    host = { name = nil, score = 0, action = nil },
    peer = { name = nil, score = 0, action = nil }
}

local playerName    = nil
local ipName        = nil
local portName      = nil
local hostBtn       = nil
local connectBtn    = nil

local rockBtn       = nil
local paperBtn      = nil
local scissorsBtn   = nil
local roundLabel    = nil
local vsMessage     = nil
local winMessage    = nil
local hostName      = nil
local peerName      = nil
local hostAction    = nil
local hostScore     = nil
local peerScore     = nil

local function disable_game_control()
    rockBtn:disable()
    paperBtn:disable()
    scissorsBtn:disable()
end

local function enable_game_cotrol()
    rockBtn:enable()
    paperBtn:enable()
    scissorsBtn:enable()
end

local function start_round()
    roundNum = roundNum + 1
    roundLabel.text = 'Round '..roundNum
    enable_game_cotrol()
end

local function win_condition()
    local p1 = players.host
    local p2 = players.peer
    local p1a = p1.action
    local p2a = p2.action
    if p1a and p2a then
        local winner

        vsMessage.text = p1.name..' '..p1a..' VS '..p2.name..' '..p2a

        if p1a == 'rock' then
            if p2a == 'rock' then
                winner = 0
            elseif p2a == 'paper' then
                winner = p2
            elseif p2a == 'scissors' then
                winner = p1
            end

        elseif p1a == 'paper' then
            if p2a == 'rock' then
                winner = p1
            elseif p2a == 'paper' then
                winner = 0
            elseif p2a == 'scissors' then
                winner = p2
            end

        elseif p1a == 'scissors' then
            if p2a == 'rock' then
                winner = p2
            elseif p2a == 'paper' then
                winner = p1
            elseif p2a == 'scissors' then
                winner = 0
            end
        end

        if winner == 0 then
            winMessage.text = 'Draw!'
        else
            winMessage.text = winner.name..' wins!'
            winner.score = winner.score + 1

            hostScore.text = 'Score: '..p1.score
            peerScore.text = 'Score: '..p2.score
        end
        
        hostAction.text = 'Previous action = '..p1a

        p1.action = nil
        p2.action = nil


        start_round()
    end
end

local function set_action(player, action)
    if player == 'host' then
        hostAction.text = 'Host action = '..action
        players.host.action = action
        disable_game_control()
    else
        -- peerAction.text = 'Peer action = '..action
        players.peer.action = action
    end
    win_condition()
end

local function create_game_control()
    players.host.name = playerName.text

    -- Game controls
    rockBtn = urutora.button({
        text = 'Rock',
        x = 10, y = 490,
        w = btnW, h = btnH
    }):action(function(e)
        if peer then
            set_action('host', 'rock')
            peer:send('action rock')
        end
    end)

    paperBtn = urutora.button({
        text = 'Paper',
        x = 20+btnW, y = 490,
        w = btnW, h = btnH
    }):action(function(e)
        if peer then
            set_action('host', 'paper')
            peer:send('action paper')
        end
    end)

    scissorsBtn = urutora.button({
        text = 'Scissors',
        x = 30+btnW+btnW, y = 490,
        w = btnW, h = btnH
    }):action(function(e)
        if peer then
            set_action('host', 'scissors')
            peer:send('action scissors')
        end
    end)

    roundLabel = urutora.label({
        text = 'Round ...',
        x = 300, y = 10,
        w = 200, h = 50
    }):center()

    vsMessage = urutora.label({
        text = 'Waiting...',
        x = 200, y = 200,
        w = 400, h = 50
    }):center()

    winMessage = urutora.label({
        text = '',
        x = 300, y = 260,
        w = 200, h = 50
    }):center()
    
    hostName = urutora.label({
        text = players.host.name,
        x = 10, y = 430,
        w = 200, h = 50
    }):left()

    peerName = urutora.label({
        text = 'Waiting for peer...',
        x = 10, y = 10,
        w = 200, h = 50
    }):left()

    hostAction = urutora.label({
        text = 'Host action...',
        x = 300, y = 430,
        w = 200, h = 50
    })

    -- peerAction = urutora.label({
    --     text = 'Peer action...',
    --     x = 300, y = 10,
    --     w = 200, h = 50
    -- })

    hostScore = urutora.label({
        text = 'Score: 0',
        x = 590, y = 430,
        w = 200, h = 50
    }):right()

    peerScore = urutora.label({
        text = 'Score: 0',
        x = 590, y = 10,
        w = 200, h = 50
    }):right()

    u:add(rockBtn)
    u:add(paperBtn)
    u:add(scissorsBtn)
    u:add(roundLabel)
    u:add(vsMessage)
    u:add(winMessage)
    u:add(hostName)
    u:add(peerName)
    u:add(hostAction)
    -- u:add(peerAction)
    u:add(hostScore)
    u:add(peerScore)

    disable_game_control()
end

local function deactivate_control()
    playerName:deactivate()
    ipName:deactivate()
    portName:deactivate()
    hostBtn:deactivate()
    connectBtn:deactivate()
end

function love.load(args)
    -- Connection controls
    playerName = urutora.text({
        text = 'Player',
        x = 10, y = 10,
        w = 200, h = 50
    })

    ipName = urutora.text({
        text = '127.0.0.1',
        x = 10, y = 70,
        w = 150, h = 50
    })

    portName = urutora.text({
        text = '6750',
        x = 170, y = 70,
        w = 60, h = 50
    })

    hostBtn = urutora.button({
        text = 'Host',
        x = 10, y = 130,
        w = 200, h = 50
    }):action(function(e)
        host = enet.host_create('*:'..portName.text)

        deactivate_control()
        create_game_control()
    end)

    connectBtn = urutora.button({
        text = 'Connect',
        x = 10, y = 190,
        w = 200, h = 50
    }):action(function(e)
        host = enet.host_create()
        peer = host:connect(ipName.text..":"..portName.text)

        deactivate_control()
        create_game_control()
    end)

    u:add(playerName)
    u:add(ipName)
    u:add(portName)
    u:add(hostBtn)
    u:add(connectBtn)
end

function love.update(dt)
    u:update(dt)

    if host then
        local event = host:service(10)

        while event do
            print("Server detected message type: " .. event.type)
            if event.type == "connect" then
                print(event.peer, "connected.")
                peer = event.peer

                peer:send('playername '..players.host.name)

            elseif event.type == 'disconnect' then
                print(event.peer, "disconnected.")
                peer = nil
            elseif event.type == "receive" then
                print("Received message: ", event.data, event.peer)

                local cmd, parms = event.data:match("^(%S*) (.*)")
                if cmd == 'playername' then
                    players.peer.name = parms
                    start_round()
                    peerName.text = players.peer.name
                elseif cmd == 'action' then
                    set_action('peer', parms)
                else
                    print('Unrecognised command:', cmd, parms)
                end
            end
            event = host:service()
        end
    end
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