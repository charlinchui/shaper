Shape = Object:extend()

function Shape:new(x, y, sprite, speed, w, s, team)
	self.x = x
	self.y = y
	self.s = s
	self.sprite = love.graphics.newImage(sprite)
	self.width = self.sprite:getWidth()
	self.height = self.sprite:getHeight()
	self.speed = speed
	self.body = love.physics.newBody(w, self.x, self.y, "dynamic")
	self.shape = love.physics.newRectangleShape(self.width, self.height)
	self.fixture = love.physics.newFixture(self.body, self.shape)
	self.state = "alive"
	self.team = team

	self.fixture:setUserData(self)
end

function Shape:update(dt)
	self.body:setLinearVelocity(self.speed, 0)
	self.x, self.y = self.body:getPosition()
end

function Shape:draw()
	if self.state == "alive" then
		love.graphics.draw(self.sprite, self.x, self.y)
	end
end

return Shape
