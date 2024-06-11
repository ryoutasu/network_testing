local ServerState = Class{}

local xs, ys = 15, 15

function ServerState:init()
    local u = Urutora:new()

    -- self.name = name
    
    local x, y, w, h = xs, ys, 400-xs-xs, 30
    local label = Urutora.label({
        x = x, y = y,
        w = w, h = h,
        text = 'Server: '
    }):left()

    u:add(label)

    self.label = label

    self.u = u
end

function ServerState:enter(name)
    self.name = name
    self.label.text = name
end

function ServerState:update(dt)
    self.u:update(dt)
end

function ServerState:draw()
    self.u:draw()
end

return ServerState