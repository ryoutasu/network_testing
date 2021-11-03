enet = require "enet"

enethost = nil
hostevent = nil
clientpeer = nil

function love.load(args)

	-- establish host for receiving msg
	enethost = enet.host_create("localhost:6750")
	
	-- establish a connection to host on same PC
	enetclient = enet.host_create()
        clientpeer = enetclient:connect("localhost:6750")

end

function love.update(dt)
	ServerListen()
	ClientSend()
end

function love.draw()
end

function ServerListen()

	hostevent = enethost:service(100)
	
	if hostevent then
		print("Server detected message type: " .. hostevent.type)
		if hostevent.type == "connect" then
			print(hostevent.peer, "connected.")
		end
		if hostevent.type == "receive" then
			print("Received message: ", hostevent.data, hostevent.peer)
		end
	end
end

function ClientSend()
	enetclient:service(100)
	clientpeer:send("Hi")
end