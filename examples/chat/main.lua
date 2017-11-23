package.path = '../../?.lua;love_nut/?.lua;' .. package.path

nut = require 'love_nut'

ssx = love.graphics.getWidth()
ssy = love.graphics.getHeight()

love.filesystem.setIdentity(love.window.getTitle())
math.randomseed(love.timer.getTime())

love.keyboard.setKeyRepeat(true)

fonts = {
	f12 = love.graphics.newFont(12),
	f24 = love.graphics.newFont(24)
}

nut.server:addRPCs{
	chat_msg = function(self, data, clientid)
		self:sendRPC('chat_msg', data)
	end,
	-- override connect/disconnect
	connect = function(self, data, clientid)
		print('hit connect')
		print(clientid .. ' connected')
		self.clients[clientid] = {}
		self:sendRPC('chat_msg', clientid .. ' connected')
	end,
	disconnect = function(self, data, clientid)
		print(clientid .. ' disconnected')
		self.clients[clientid] = nil
		self:sendRPC('chat_msg', clientid .. ' disconnected')
	end
}

nut.client:addRPCs{
	chat_msg = function(self, data)
		chat = chat .. data .. '\n'
	end,
	closed = function(self, data)
		chat = chat .. 'Server Closed'
	end
}

function love.load()
	chat = '--Chat:\n'
	message = ''
	typing = false
end

function love.update(dt)
	if server then
		server:update(dt)
	end
	if client then
		client:update(dt)
	end
end

function love.textinput(t)
	if typing then
		message = message .. t
	end
end

function love.keypressed(k, scancode, isrepeat)
	if k == 'escape' then
		love.event.quit()
	elseif k == 'backspace' then
		if client and typing then
			message = message:sub(0, math.max(message:len()-1, 0))
		end
	elseif k == 'return' then
		if client then
			typing = not typing
			if not typing then
				client:sendRPC('chat_msg', message)
				message = ''
			end
		end
	end
end

function love.mousepressed(x, y, btn, isTouch)
	if not client and y < ssy/3 then
		server = nut.server()
		client = nut.client()
		client:connect('localhost', 1357)
	elseif not client and y < ssy*2/3 then
		client = nut.client()
		client:connect('localhost', 1357)
	end
end

function love.draw()
	love.graphics.setBackgroundColor(200, 200, 200)
	local mx, my = love.mouse.getPosition()
	if client then
		love.graphics.setFont(fonts.f12)
		love.graphics.print(chat, 50, ssy/6)
		local cursor = ''
		if typing and (love.timer.getTime()%1 < 0.5) then
			cursor = '|'
		end
		love.graphics.print(message .. cursor, 30, ssy*2/3)
	else
		if my < ssy/3 then
			love.graphics.setColor(120, 180, 200)
		else
			love.graphics.setColor(160, 180, 200)
		end
		love.graphics.rectangle('fill', 0, 0, ssx, ssy/3)
		love.graphics.setColor(0, 0, 0)
		love.graphics.setFont(fonts.f24)
		local txt = 'Server'
		love.graphics.print(txt, ssx/2 - fonts.f24:getWidth(txt)/2, ssy/6)
		
		if my > ssy/3 and my < ssy*2/3 then
			love.graphics.setColor(120, 180, 200)
		else
			love.graphics.setColor(160, 180, 200)
		end
		love.graphics.rectangle('fill', 0, ssy/3, ssx, ssy/3)
		love.graphics.setColor(0, 0, 0)
		love.graphics.setFont(fonts.f24)
		local txt = 'Client'
		love.graphics.print(txt, ssx/2 - fonts.f24:getWidth(txt)/2, ssy/2)
	end
end

function love.quit()
	if client then
		client:sendRPC('disconnect')
	end
	if server then
		server:sendRPC('closed')
	end
end
