local Title = {textInfo = {}}

function Title:load()
    currentTitle = true

    self.x = 785
    self.y = 300
    self.scale = 2.5

    self.textInfo.x = 775
    self.textInfo.y = 800

    self.font = love.graphics.newFont("assets/font.ttf", 36)

    love.graphics.setFont(self.font)

    black = {0,0,0}
end


function Title:update(dt)
    self:changeState()
end

function Title:draw()
    love.graphics.draw(background, 0, -435)
    love.graphics.print({black ,"IPlat"}, self.x, self.y, 0, 1.25, 1.25)
    love.graphics.print({black, "Press 'S' to start"}, self.textInfo.x, self.textInfo.y)
end

function Title:changeState()
    if love.keyboard.isDown("s") then
        currentTitle = false
    end
end

return Title
