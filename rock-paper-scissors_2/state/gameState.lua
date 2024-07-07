local GameState = Class{}

local center_x = WIN_WIDTH / 2
local center_y = WIN_HEIGHT / 2

local button_offset = 10

local button_w = 100
local button_h = 150

local button_y = WIN_HEIGHT - button_h - button_offset
local button_y_clicked = button_y - 15

function GameState:init()
    local u = Urutora:new()

    local w, h = 100, 30
    local x, y = 30, WIN_HEIGHT - 100

    local playerLabel = u.label({
        x = x, y = y,
        w = w, h = h,
        text = 'Player'
    })

    local opponentLabel = u.label({
        x = x, y = 100 - h,
        w = w, h = h,
        text = 'Opponent...'
    })

    -- Game controls
    w, h = button_w, button_h
    x, y = center_x - w/2 - w - button_offset, button_y
    local rockButton = u.button({
        x = x, y = y,
        w = w, h = h,
        text = 'Rock',
    }):disable()

    x = center_x - w/2
    local paperButton = u.button({
        x = x, y = y,
        w = w, h = h,
        text = 'Paper',
    }):disable()

    x = center_x + w/2 + button_offset
    local scissorsButton = u.button({
        x = x, y = y,
        w = w, h = h,
        text = 'Scissors',
    }):disable()

    rockButton:action(function (e)
        e.target.y = button_y_clicked
        paperButton.y = button_y
        scissorsButton.y = button_y
    end)
    paperButton:action(function (e)
        e.target.y = button_y_clicked
        rockButton.y = button_y
        scissorsButton.y = button_y
    end)
    scissorsButton:action(function (e)
        e.target.y = button_y_clicked
        rockButton.y = button_y
        paperButton.y = button_y
    end)
    -- Game controls

    u:add(playerLabel)
    u:add(opponentLabel)
    u:add(rockButton)
    u:add(paperButton)
    u:add(scissorsButton)
    
    self.playerLabel = playerLabel
    self.opponentLabel = opponentLabel
    self.rockButton = rockButton
    self.paperButton = paperButton
    self.scissorsButton = scissorsButton

    self.u = u
    self.opponent = false
end

function GameState:enter_host()
    local w, h = 400, 40
    local x, y = center_x - w/2, center_y - h
    local waitOpponentLabel = Urutora.label({
        x = x, y = y,
        w = w, h = h,
        text = 'Wait for the opponent...',
    }):setStyle({ font = LABEL_FONT })

    self.u:add(waitOpponentLabel)

    self.waitOpponentLabel = waitOpponentLabel

    Host:broadcast({ cmd = 'server_up', name = Player.name })
end

function GameState:set_opponent(name, ip, port)
    self.opponentLabel.text = name
    self.opponent = { name = name, ip = ip, port = port }

    if self.is_host then
        Host:broadcast('remove_from_list')
        self.u:remove(self.waitOpponentLabel)
    end
    
    self.rockButton:enable()
    self.paperButton:enable()
    self.scissorsButton:enable()
end

function GameState:enter(state, server, name)
    self.is_host = (server.ip == Host.ip and server.port == Host.port)

    if self.is_host then
        self:enter_host()
    else
        Host:send({ cmd = 'connect', name = Player.name }, server.ip, server.port)
        self:set_opponent(name, server.ip, server.port)
    end

    self.playerLabel.text = Player.name
    self.users = 1
end

local timer = 0
function GameState:receive(dt)
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
            if data == 'is_server_up' and self.is_host and not self.opponent then
                Host:send({ cmd = 'server_up', name = Player.name }, msg_or_ip, port_or_nil)
            end
        end

        if type(data) == "table" then
            if data.cmd == 'connect' then
                self:set_opponent(data.name, msg_or_ip, port_or_nil)
            end
        end
    end
end


function GameState:update(dt)
    self:receive(dt)
    self.u:update(dt)
end

function GameState:draw()
    self.u:draw()
end

function GameState:mousepressed(x, y, button) self.u:pressed(x, y, button) end
function GameState:mousemoved(x, y, dx, dy) self.u:moved(x, y, dx, dy) end
function GameState:mousereleased(x, y, button) self.u:released(x, y, button) end
function GameState:textinput(text) self.u:textinput(text) end
function GameState:keypressed(k, scancode, isrepeat) self.u:keypressed(k, scancode, isrepeat) end
function GameState:wheelmoved(x, y) self.u:wheelmoved(x, y) end

return GameState