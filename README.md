![image](https://github.com/user-attachments/assets/58421885-bf80-489b-843a-f957a13aa8c9)



# libdml

Simple direct TCP messages for Godot.

* Auto send messages.
* Auto close connections.
* Fast for Server responses.

```gdscript
extends Node

var server = DML_Server.new()
var client = DML_Client.new()

func _ready() -> void:
	server.proxy_connected.connect(func(proxy):
		print("Client connected"))
	
	server.proxy_disconnected.connect(func(proxy):
		print("Client disconnected"))
	
	server.listen(8081)
	server.direct_message = "testing".to_utf8_buffer()
	server.direct_disconnect = true				#AUTO DISCONNECT ON TAKE CONNECTION
	
	client.available_packet.connect(func(packet : PackedByteArray):
		print(packet.get_string_from_utf8()))
		
	client.find("127.0.0.1", 8081)

func _process(delta: float) -> void:
	server.poll()
	client.poll()

func _exit_tree() -> void:
	client.close()
	server.close()

```

Console:

```
Client connected
Client disconnected
testing
```
