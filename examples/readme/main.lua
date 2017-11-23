package.path = '../../?.lua;love_nut/?.lua;' .. package.path

local nut = require 'love_nut'

chat = '--Chat:\n'
server = nut.server{port=1357}
client = nut.client()
client:connect('localhost', 1357)

server:addRPCs{
  chat_msg = function(self, data, clientid)
    self:sendRPC('chat_msg', data)
  end
}

client:addRPCs{
  chat_msg = function(self, data)
    chat = chat .. data
  end
}

function love.update(dt)
  server:update(dt)
  client:update(dt)
end

function love.textinput(t)
  client:sendRPC('chat_msg', t)
end

function love.draw()
  love.graphics.print(chat, 20, 20)
end