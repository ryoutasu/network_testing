local GameListState = Class{}

local ys = 30
local offset = 30

function GameListState:init()
    local u = Urutora:new()
    
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
    
    self.u = u
end

function GameListState:update(dt)
    self.u:update(dt)
end

function GameListState:draw()
    self.u:draw()
end

function GameListState:mousepressed(x, y, button) self.u:pressed(x, y, button) end
function GameListState:mousemoved(x, y, dx, dy) self.u:moved(x, y, dx, dy) end
function GameListState:mousereleased(x, y, button) self.u:released(x, y, button) end
function GameListState:textinput(text) self.u:textinput(text) end
function GameListState:keypressed(k, scancode, isrepeat) self.u:keypressed(k, scancode, isrepeat) end
function GameListState:wheelmoved(x, y) self.u:wheelmoved(x, y) end

return GameListState