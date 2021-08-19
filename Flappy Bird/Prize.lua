--[[
    Bird Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Bird is what we control in the game via clicking or the space bar; whenever we press either,
    the bird will flap and go up a little bit, where it will then be affected by gravity. If the bird hits
    the ground or a pipe, the game is over.
]]

Prize = Class{}

function Prize:init()
    self.bronze = love.graphics.newImage('bronze.jpg')
    self.silver = love.graphics.newImage('silver.jpg')
    self.gold = love.graphics.newImage('gold.jpg')
end

function Prize:update()
    self.x = VIRTUAL_WIDTH / 2
    self.y = VIRTUAL_HEIGHT / 2
end

function Prize:render(score)
    if score >=5 and score < 10 then
        Prize:update()
        love.graphics.draw(self.silver, self.x - 15, self.y - 23)
    elseif score >= 10 then
        Prize:update()
        love.graphics.draw(self.gold, self.x - 15, self.y -25)
    elseif score > 0 then
        Prize:update()
        love.graphics.draw(self.bronze, self.x - 15, self.y - 24)
    elseif true then
        love.graphics.printf('No Medal', 0, 140, VIRTUAL_WIDTH, 'center')
    end
end