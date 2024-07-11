local tween = require 'lib.tween'

local GameState = Class{}

local center_x = WIN_WIDTH / 2
local center_y = WIN_HEIGHT / 2

local button_offset = 10

local button_w = 100
local button_h = 150

local button_y = WIN_HEIGHT - button_h - button_offset
local button_y_clicked = button_y - 15

local line_y = center_y
local lineLength = 600
local lineColorGreen = { 0, 1, 0, 1 }
local lineColorRed = { 1, 0, 0, 1 }
local roundTime = 10
local lineExtensionTime = 1

function GameState:lock()
    self.rockButton:disable()
    self.paperButton:disable()
    self.scissorsButton:disable()
end

function GameState:setSign(sign)
    self:lock()
    self.rockButton.y = button_y
    self.paperButton.y = button_y
    self.scissorsButton.y = button_y

    local state = 'ready'
    local opponent = self.opponent
    if self.currentSign == sign then
        self.currentSign = nil
        state = 'unready'
    else
        self.currentSign = sign
        self[sign..'Button'].y = button_y_clicked

        if opponent and opponent.ready then
            -- begin countdown
        end
    end

    if opponent then
        Host:send(state, opponent.ip, opponent.port)
    end
end

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
        self:setSign('rock')
    end)
    paperButton:action(function (e)
        self:setSign('paper')
    end)
    scissorsButton:action(function (e)
        self:setSign('scissors')
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
    self.currentSign = nil

    self.line = {
        x = center_x, y = line_y,
        length = 0,
        color = { 1, 1, 1, 1 },
        extensioning = false,
    }
    self.tweenLineColor = nil
    self.tweenLineLength = nil
end

function GameState:enterHost()
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

function GameState:setOpponent(name, ip, port)
    self.opponentLabel.text = name
    self.opponent = { name = name, ip = ip, port = port, ready = false }

    if self.is_host then
        Host:broadcast('remove_from_list')
        self.u:remove(self.waitOpponentLabel)
    end
    
    self.rockButton:enable()
    self.paperButton:enable()
    self.scissorsButton:enable()

    self:startRound()
end

function GameState:enter(state, server, name)
    self.is_host = (server.ip == Host.ip and server.port == Host.port)

    if self.is_host then
        self:enterHost()
    else
        Host:send({ cmd = 'connect', name = Player.name }, server.ip, server.port)
        self:setOpponent(name, server.ip, server.port)
    end

    self.playerLabel.text = Player.name
    self.users = 1

    self:startRound()
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

            if data == 'ready' then
                self.opponent.ready = true
                if self.sign then
                    self:lock()
                end
            end
        end

        if type(data) == "table" then
            if data.cmd == 'connect' then
                self:setOpponent(data.name, msg_or_ip, port_or_nil)
            end
        end
    end
end

function GameState:startRound()
    self.line.length = 0
    self.line.color = { lineColorRed[1], lineColorRed[2], lineColorRed[3], lineColorRed[4] }
    self.line.extensioning = true
    self.tweenLineLength = tween.new(lineExtensionTime, self.line, { length = lineLength })
    self.tweenLineColor = tween.new(lineExtensionTime, self.line, { color = lineColorGreen })
end

function GameState:endRound()
    self.rockButton:disable()
    self.paperButton:disable()
    self.scissorsButton:disable()
    self.rockButton.y = button_y
    self.paperButton.y = button_y
    self.scissorsButton.y = button_y
    self.currentSign = nil
end

function GameState:updateTween(dt)
    local tweenLineLength = self.tweenLineLength
    local tweenLineColor = self.tweenLineColor

    local complete = false
    if tweenLineLength then
        complete = tweenLineLength:update(dt)
    end
    
    if tweenLineColor then
        tweenLineColor:update(dt)
    end

    if complete then
        if self.line.extensioning then
            self.line.extensioning = false
            self.tweenLineLength = tween.new(roundTime, self.line, { length = 0 }, 'linear')
            self.tweenLineColor = tween.new(roundTime, self.line, { color = lineColorRed }, 'linear')
        else
            self:endRound()
        end
    end

    self.line.x = center_x - self.line.length / 2
end

function GameState:update(dt)
    self:receive(dt)
    self:updateTween(dt)
    self.u:update(dt)
end

function GameState:draw()
    self.u:draw()

    local line = self.line
    love.graphics.setColor(line.color)
    love.graphics.line(line.x, line.y, line.x + line.length, line.y)
end

function GameState:mousepressed(x, y, button) self.u:pressed(x, y, button) end
function GameState:mousemoved(x, y, dx, dy) self.u:moved(x, y, dx, dy) end
function GameState:mousereleased(x, y, button) self.u:released(x, y, button) end
function GameState:textinput(text) self.u:textinput(text) end
function GameState:keypressed(k, scancode, isrepeat) self.u:keypressed(k, scancode, isrepeat) end
function GameState:wheelmoved(x, y) self.u:wheelmoved(x, y) end

return GameState