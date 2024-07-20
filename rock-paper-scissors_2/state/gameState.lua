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
local lineExtensionTime = 3

local bigLabel_y = center_y - 100
local bigLabel_offset_y = 130

function GameState:lock()
    self.rockButton:disable()
    self.paperButton:disable()
    self.scissorsButton:disable()
end

function GameState:setSign(sign)
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
            -- begin countdown ?
            self:lock()
        end
    end

    if opponent then
        Host:send(state, opponent.ip, opponent.port)
    end
end

function GameState:init()
    local u = Urutora:new()

    local w, h = 400, 40
    local x, y = center_x - w/2, bigLabel_y
    local gameResultLabel = Urutora.label({
        x = x, y = y,
        w = w, h = h,
        text = 'Game result',
    }):setStyle({ font = LABEL_FONT }):hide()

    w, h = 100, 30
    x, y = 30, bigLabel_y + bigLabel_offset_y
    local playerLabel = u.label({
        x = x, y = y,
        w = w, h = h,
        text = 'Player: 0'
    })

    x, y = 30, bigLabel_y - bigLabel_offset_y
    local opponentLabel = u.label({
        x = x, y = y,
        w = w, h = h,
        text = 'Opponent...: 0'
    })

    w = 100
    x, y = center_x - w/2, playerLabel.y
    local playerSignLabel = u.label({
        x = x, y = y,
        w = w, h = h,
        text = 'Player sign'
    }):hide()

    y = opponentLabel.y
    local opponentSignLabel = u.label({
        x = x, y = y,
        w = w, h = h,
        text = 'Opponent sign'
    }):hide()

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

    u:add(gameResultLabel)
    u:add(playerLabel)
    u:add(opponentLabel)
    u:add(playerSignLabel)
    u:add(opponentSignLabel)
    u:add(rockButton)
    u:add(paperButton)
    u:add(scissorsButton)
    
    self.gameResultLabel = gameResultLabel
    self.playerLabel = playerLabel
    self.opponentLabel = opponentLabel
    self.playerSignLabel = playerSignLabel
    self.opponentSignLabel = opponentSignLabel
    self.rockButton = rockButton
    self.paperButton = paperButton
    self.scissorsButton = scissorsButton

    self.u = u
    setup_state_input(self)
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

    self.roundNum = 0
    self.inGameList = false

    self.paused = false
end

function GameState:enterHost()
    local w, h = 400, 40
    local x, y = center_x - w/2, bigLabel_y
    local waitOpponentLabel = Urutora.label({
        x = x, y = y,
        w = w, h = h,
        text = 'Wait for the opponent...',
    }):setStyle({ font = LABEL_FONT })

    self.u:add(waitOpponentLabel)

    self.waitOpponentLabel = waitOpponentLabel

    Host:broadcast({ cmd = 'server_up', name = Player.name })
    self.inGameList = true
end

function GameState:setOpponent(name, ip, port)
    self.opponentLabel.text = name .. ': 0'
    self.opponent = { name = name, ip = ip, port = port, ready = false }

    if self.is_host then
        Host:broadcast('remove_from_list')
        self.u:remove(self.waitOpponentLabel)
        self.inGameList = false
    end
    
    self.line.length = 0
    self.line.color = { lineColorRed[1], lineColorRed[2], lineColorRed[3], lineColorRed[4] }
    self.line.extensioning = true
    self.tweenLineLength = tween.new(lineExtensionTime, self.line, { length = lineLength })
    self.tweenLineColor = tween.new(lineExtensionTime, self.line, { color = lineColorGreen })

    self.opponentSignLabel.text = self.opponent.name
    self.gameResultLabel.text = 'VS'
    self.playerSignLabel.text = Player.name
end

function GameState:enter(state, server, name)
    self.is_host = (server.ip == Host.ip and server.port == Host.port)

    if self.is_host then
        self:enterHost()
    else
        Host:send({ cmd = 'connect', name = Player.name }, server.ip, server.port)
        self:setOpponent(name, server.ip, server.port)
    end

    self.playerLabel.text = Player.name .. ': 0'
    self.users = 1
end

local function resolve(playerSign, opponentSign)
    local result = 'draw'

    if playerSign == nil then
        result = 'lose'
    end
    if opponentSign == nil then
        result = 'win'
    end

    if playerSign == 'rock' then
        if opponentSign == 'scissors' then
            result = 'win'
        elseif opponentSign == 'paper' then
            result = 'lose'
        end
    end

    if playerSign == 'paper' then
        if opponentSign == 'rock' then
            result = 'win'
        elseif opponentSign == 'scissors' then
            result = 'lose'
        end
    end

    if playerSign == 'scissors' then
        if opponentSign == 'paper' then
            result = 'win'
        elseif opponentSign == 'rock' then
            result = 'lose'
        end
    end

    return result
end

function GameState:showResult(opponentSign)
    local playerSign = self.currentSign
    local gameResultLabel = self.gameResultLabel
    local result = resolve(playerSign, opponentSign)

    if result == 'win' then
        gameResultLabel.text = Player.name .. ' won!'
    end
    
    if result == 'lose' then
        gameResultLabel.text = self.opponent.name .. ' won!'
    end

    if result == 'draw' then
        gameResultLabel.text = 'Draw!'
    end
    
    gameResultLabel:show()
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

            if data == 'quit' then
                self:lock()
                self.gameResultLabel.text = 'Opponent left the game'
                    self.paused = true
            end
        end

        if type(data) == "table" then
            if data.cmd == 'connect' then
                self:setOpponent(data.name, msg_or_ip, port_or_nil)
            end

            if data.cmd == 'sign' then
                self:showResult(data.sign)
            end
        end
    end
end

function GameState:startRound()
    self.currentSign = nil
    self.rockButton.y = button_y
    self.paperButton.y = button_y
    self.scissorsButton.y = button_y
    
    self.rockButton:enable()
    self.paperButton:enable()
    self.scissorsButton:enable()

    self.roundNum = self.roundNum + 1

    self.opponentSignLabel.text = ''
    self.gameResultLabel.text = 'ROUND ' .. self.roundNum
    self.playerSignLabel.text = ''
    
    self.line.extensioning = false
    self.tweenLineLength = tween.new(roundTime, self.line, { length = 0 }, 'linear')
    self.tweenLineColor = tween.new(roundTime, self.line, { color = lineColorRed }, 'linear')
end

function GameState:endRound()
    self.rockButton:disable()
    self.paperButton:disable()
    self.scissorsButton:disable()

    local opponent = self.opponent
    if opponent then
        Host:send({ cmd = 'sign', sign = self.currentSign }, opponent.ip, opponent.port)
    end
    
    self.line.extensioning = true
    self.tweenLineLength = tween.new(lineExtensionTime, self.line, { length = lineLength })
    self.tweenLineColor = tween.new(lineExtensionTime, self.line, { color = lineColorGreen })
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
            self:startRound()
        else
            self:endRound()
        end
    end

    self.line.x = center_x - self.line.length / 2
end

function GameState:update(dt)
    self:receive(dt)

    if not self.paused then
        self:updateTween(dt)
    end

    self.u:update(dt)
end

function GameState:draw()
    self.u:draw()

    if self.line.length > 0 then
        local line = self.line
        love.graphics.setColor(line.color)
        love.graphics.line(line.x, line.y, line.x + line.length, line.y)
    end
end

function GameState:quit()
    print('quitting from GameState')
    
    if self.inGameList then
        Host:broadcast('remove_from_list')
    end

    local opponent = self.opponent
    if opponent then
        Host:send('quit', opponent.ip, opponent.port)
    end
end

return GameState