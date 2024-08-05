class_name DML_Client extends RefCounted

signal available_packet(packet : PackedByteArray)

var stream : PacketPeerStream

var auto_message	: PackedByteArray
var auto_disconnect : bool

func _init() -> void:
	return

func find(address : String, port : int) -> void:
	stream = PacketPeerStream.new()
	stream.stream_peer = StreamPeerTCP.new()
	
	(stream.stream_peer as StreamPeerTCP).connect_to_host(address, port)

func poll() -> void:
	if stream:
		(stream.stream_peer as StreamPeerTCP).poll()
		
		match (stream.stream_peer as StreamPeerTCP).get_status():
			StreamPeerTCP.Status.STATUS_CONNECTED:
				if auto_message and auto_message.size() > 0:
					stream.put_packet(auto_message)
				
				if stream.get_available_packet_count() > 0:
					available_packet.emit(stream.get_packet())
				
					if auto_disconnect:
						close()

func close() -> void:
	if stream:
		(stream.stream_peer as StreamPeerTCP).disconnect_from_host()
