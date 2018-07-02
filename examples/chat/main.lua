-- remove if love_nut.lua is in current dir
package.path = '../../?.lua;' .. package.path

nut = require 'love_nut'
nut.logMessages = true

ssx = love.graphics.getWidth()
ssy = love.graphics.getHeight()

love.keyboard.setKeyRepeat(true)

fonts = {
	f12 = love.graphics.newFont(12),
	f24 = love.graphics.newFont(24)
}

function love.load()
	chat = '--Chat:\n'
	message = ''
	typing = false
end

function startServer()
	server = nut.server()
	server:addRPCs{
		chat_msg = function(self, data, clientId)
			self:sendRPC('chat_msg', data)
		end,
		-- override default connect/disconnect (include default code)
		connect = function(self, data, clientId)
			self:sendRPC('chat_msg', clientId .. ' connected')

			nut.log(clientId .. ' connected')
		end,
		disconnect = function(self, data, clientId)
			self:sendRPC('chat_msg', clientId .. ' disconnected')

			self.clients[clientId] = nil
			nut.log(clientId .. ' disconnected')
		end
	}
	server:start()
end

function startClient()
	client = nut.client()
	client:addRPCs{
		chat_msg = function(self, data)
			chat = chat .. data .. '\n'
		end,
		closed = function(self, data)
			chat = chat .. 'Server Closed'
		end
	}
	client:connect('127.0.0.1', 1357)
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
		startServer()
		startClient()
	elseif not client and y < ssy*2/3 then
		startClient()
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0.8, 0.8, 0.8)
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
			love.graphics.setColor(0.5, 0.8, 0.7)
		else
			love.graphics.setColor(0.6, 0.7, 0.8)
		end
		love.graphics.rectangle('fill', 0, 0, ssx, ssy/3)
		love.graphics.setColor(0, 0, 0)
		love.graphics.setFont(fonts.f24)
		local txt = 'Server'
		love.graphics.print(txt, ssx/2 - fonts.f24:getWidth(txt)/2, ssy/6)

		if my > ssy/3 and my < ssy*2/3 then
			love.graphics.setColor(0.5, 0.7, 0.8)
		else
			love.graphics.setColor(0.6, 0.7, 0.8)
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
		client:close()
	end
	if server then
		server:sendRPC('closed')
		server:close()
	end
end
