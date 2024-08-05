class_name DML_Server extends RefCounted

class DML_ProxyClient extends RefCounted:
	var stream : PacketPeerStream
	
	func get_stream() -> StreamPeerTCP:
		if stream and stream.stream_peer is StreamPeerTCP:
			return stream.stream_peer
		return null
	
	func write(data : PackedByteArray) -> void:
		if stream and stream.stream_peer is StreamPeerTCP:
			stream.put_packet(data)


signal proxy_connected		(proxy : DML_ProxyClient)
signal proxy_disconnected	(proxy : DML_ProxyClient)
signal available_packet		(proxy : DML_ProxyClient, packet : PackedByteArray)

var server : TCPServer
var proxys : Array[DML_ProxyClient]

var direct_message : PackedByteArray
var direct_disconnect : bool

func _init() -> void:
	return

func listen(port : int, bind := '*') -> void:
	server = TCPServer.new()
	server.listen(port, bind)

func poll() -> void:
	if server:
		if server.is_listening():
			if server.is_connection_available():
				var proxy = DML_ProxyClient.new()
				proxy.stream = PacketPeerStream.new()
				proxy.stream.stream_peer = server.take_connection()
				proxys.append(proxy)
				
				proxy_connected.emit(proxy)
				
				if direct_message and direct_message.size() > 0:
					proxy.stream.put_packet(direct_message)
				
				if direct_disconnect:
					proxy.get_stream().disconnect_from_host()
			
			for proxy in proxys:
				if proxy.get_stream().get_status() != StreamPeerTCP.STATUS_CONNECTED:
					proxys.erase(proxy)
					proxy_disconnected.emit(proxy)
				
				if proxy.stream.get_available_packet_count() > 0:
					available_packet.emit(proxy, proxy.stream.get_packet())

func close() -> void:
	if server:
		server.stop()
