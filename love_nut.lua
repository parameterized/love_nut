
local socket = require 'socket'

local nut = {}

local server = {}
server.__index = server
server.rpc = {
	connect = function(self, t, clientid)
		print(clientid .. ' connected')
		self.clients[clientid] = {}
	end,
	disconnect = function(self, t, clientid)
		print(clientid .. ' disconnected')
		self.clients[clientid] = nil
	end
}

function server.new(opts)
	local t = {
		port = 1357,
		updateRate = 1/20
	}
	opts = opts or {}
	for k, v in pairs(opts) do t[k] = v end
	t.updateTimer = 0
	t.udp = socket.udp()
	t.udp:settimeout(0)
	t.udp:setsockname('*', t.port)
	t.clients = {}
	return setmetatable(t, server)
end

function server:addRPCs(t)
	for name, rpc in pairs(t) do
		self.rpc[name] = rpc
	end
end

function server:update(dt)
	self.updateTimer = self.updateTimer + dt
	if self.updateTimer > self.updateRate then
		self.updateTimer = self.updateTimer - self.updateRate
		repeat
			local data, msg_or_ip, port_or_nil = self.udp:receivefrom()
			if data then
				print('server received: ' .. data)
				local clientid = msg_or_ip .. ':' .. tostring(port_or_nil)
				local cmd, cmdParams = data:match('^(%S*) (.*)$')
				local rpc = self.rpc[cmd]
				if rpc then
					rpc(self, cmdParams, clientid)
				end
			elseif not (msg_or_ip == 'timeout') then 
				print('Network error: ' .. tostring(msg_or_ip))
			end
		until not data
	end
end

function server:sendRPC(cmd, cmdParams, clientid)
	cmdParams = cmdParams or '$'
	local dg = cmd .. ' ' .. cmdParams
	if clientid then
		local ip, port = clientid:match("^(.-):(%d+)$")
		self.udp:sendto(dg, ip, tonumber(port))
	else
		for clientid, _ in pairs(self.clients) do
			print('in send all')
			local ip, port = clientid:match("^(.-):(%d+)$")
			self.udp:sendto(dg, ip, tonumber(port))
		end
	end
end

setmetatable(server, {__call = function(_, ...) return server.new(...) end})

local client = {}
client.__index = client
client.rpc = {}

function client.new(opts)
	local t = {
		updateRate = 1/20
	}
	opts = opts or {}
	for k, v in pairs(opts) do t[k] = v end
	t.updateTimer = 0
	t.udp = socket.udp()
	t.udp:settimeout(0)
	return setmetatable(t, client)
end

function client:connect(ip, port)
	print('connecting to ' .. ip .. ':' .. tostring(port))
	self.udp:setpeername(ip, port)
	return self:sendRPC('connect')
end

function client:addRPCs(t)
	for name, rpc in pairs(t) do
		self.rpc[name] = rpc
	end
end

function client:update(dt)
	self.updateTimer = self.updateTimer + dt
	if self.updateTimer > self.updateRate then
		self.updateTimer = self.updateTimer - self.updateRate
		repeat
			local data, msg = self.udp:receive()
			if data then
				print('client received: ' .. data)
				local cmd, cmdParams = data:match('^(%S*) (.*)$')
				local rpc = self.rpc[cmd]
				if rpc then
					rpc(self, cmdParams)
				end
			elseif not (msg == 'timeout') then 
				print('Network error: ' .. tostring(msg))
			end
		until not data
	end
end

function client:sendRPC(cmd, cmdParams)
	cmdParams = cmdParams or '$'
	local dg = cmd .. ' ' .. cmdParams
	return self.udp:send(dg)
end

setmetatable(client, {__call = function(_, ...) return client.new(...) end})

nut.server = server
nut.client = client

return nut