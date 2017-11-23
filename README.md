# LoveNUT
Love2D Networking (UDP/TCP) (tcp in progress)
Lua networking library designed for Love2D games

*Supports Love 0.10.2*

## Simple functional example

```lua
local nut = require 'love_nut'

chat = '--Chat:\n'
server = nut.server{port=1357}
client = nut.client()
client:connect('localhost', 1357)

server:addRPCs{
  chat_msg = function(self, t, clientid)
    self:send{cmd='chat_msg', val=t.val}
    print(self.clients[clientid])
  end
}

client:addRPCs{
  chat_msg = function(self, t)
    chat = chat .. t.val .. '\n'
  end
}

function love.update(dt)
  server:update(dt)
  client:update(dt)
end

function love.keypressed(k)
  if k == 'space' then
    client:send{cmd='chat_msg', val='message'}
  end
end

function love.draw()
  love.graphics.print(chat, 20, 20)
end
```