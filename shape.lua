Shape = Object:extend()

function Shape:new(x, y, sprite, speed)
	self.x = x
	self.y = y
	self.sprite = sprite
	self.speed = speed
end

function Shape:update(dt)
	self.x = self.x + self.speed * dt
end

function Shape:draw()
	love.graphics.draw(self.sprite, self.x, self.y)
end

return Shape
