
# LoveNUT
Love2D Networking (UDP/TCP)

Lua networking library designed for Love2D games (not exclusively, should work on anything with LuaSocket)

*Supports Love 11.1.0*

## Example usage
```lua
local nut = require 'love_nut'

chat = '--Chat:\n'
server = nut.server{port=1357}
client = nut.client()
client:connect('127.0.0.1', 1357)

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

function love.quit()
  server:close()
  client:close()
end
```

# Documentation
* [NUT][nut]
	* [Properties][nut-properties]
		* [logMessages][nut-properties-logMessages]
		* [logErrors][nut-properties-logErrors]
	* [Methods][nut-methods]
		* [log][nut-methods-log]
		* [logError][nut-methods-logError]
		* [getIP][nut-methods-getIP]
* [Client][client]
    * [Properties][client-properties]
	    * [updateRate][client-properties-updateRate]
	    * [rpcs][client-properties-rpcs]
	* [Methods][client-methods]
		* [connect][client-methods-connect]
		* [addRPCs][client-methods-addRPCs]
		* [update][client-methods-update]
		* [sendRPC][client-methods-sendRPC]
		* [close][client-methods-close]
* [Server][server]
	* [Properties][server-properties]
		* [port][server-properties-port]
		* [updateRate][server-properties-updateRate]
		* [rpcs][server-properties-rpcs]
	* [Methods][server-methods]
		* [addRPCs][server-methods-addRPCs]
		* [accept][server-methods-accept]
		* [update][server-methods-update]
		* [sendRPC][server-methods-sendRPC]
		* [close][server-methods-close]

## <a id="nut"/> NUT
```lua
nut = require 'love_nut'
```

### <a id="nut-properties"/> Properties
<a id="nut-properties-logMessages">logMessages</a>
**default: false**
display logged messages

<a id="nut-properties-logErrors">logErrors</a>
**default: true**
display logged errors

### <a id="nut-methods"/> Methods
<a id="nut-methods-log">.log(msg)</a>
log a normal message
```lua
nut.log('message')
```

<a id="nut-methods-logError">.logError(err)</a>
log an error message
```lua
nut.log('error')
```

<a id="nut-methods-getIP">.getIP()</a>
get (local) ip (should return public the future)
```lua
ip = nut.getIP()
```

## <a id="client"/> Client
```lua
client = nut.client()
```
```lua
client = nut.client{updateRate=1/20}
```

### <a id="client-properties"/> Properties
<a id="client-properties-updateRate">updateRate</a>
default: 1/20
set client update rate

<a id="client-properties-rpcs">rpcs</a>
default: {}
table of rpcs - use :addRPCs(t)

### <a id="client-methods"/> Methods
<a id="client-methods-connect">:connect(ip, port)</a>
connect to a server
```lua
client:connect(ip, port)
```

<a id="client-methods-addRPCs">:addRPCs(t)</a>
add remote procedure call functions
```lua
client:addRPCs{
  rpc_name = function(self, data)
    -- process data
  end
}
```

:connect(ip, port)
:addRPCs(t)
:update(dt)
:sendRPC(cmd, cmdParams)
:close()

## <a id="server"/> Server
`server = nut.server{port=1357}`
`server = nut.server{port=1357, updateRate=1/20}`

### <a id="server-properties"/> Properties
port - 1357 (set when creating server)
updateRate - 1/20
rpcs - {}

### <a id="server-methods"/> Methods
:addRPCs(t)
:accept()
:update(dt)
:sendRPC(cmd, cmdParams, clientId)
:close()


[nut]: #nut
[nut-properties]: #nut-properties
[nut-properties-logMessages]: #nut-properties-logMessages
[nut-properties-logErrors]: #nut-properties-logErrors
[nut-methods]: #nut-methods
[nut-methods-log]: #nut-methods-log
[nut-methods-logError]: #nut-methods-logError
[nut-methods-getIP]: #nut-methods-getIP
[client]: #client
[client-properties]: #client-properties
[client-properties-updateRate]: #client-properties-updateRate
[client-properties-rpcs]: #client-properties-rpcs
[client-methods]: #client-methods
[client-methods-connect]: #client-methods-connect
[client-methods-addRPCs]: #client-methods-addRPCs
[client-methods-update]: #client-methods-update
[client-methods-sendRPC]: #client-methods-sendRPC
[client-methods-close]: #client-methods-close
[server]: #server
[server-properties]: #server-properties
[server-properties-port]: #server-properties-port
[server-properties-updateRate]: #server-properties-updateRate
[server-properties-rpcs]: #server-properties-rpcs
[server-methods]: #server-methods
[server-methods-addRPCs]: #server-methods-addRPCs
[server-methods-accept]: #server-methods-accept
[server-methods-update]: #server-methods-update
[server-methods-sendRPC]: #server-methods-sendRPC
[server-methods-close]: #server-methods-close
