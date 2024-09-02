class_name MultiplayerUtil


static func get_compressed_data(data: Variant) -> PackedByteArray:
	return var_to_bytes(data).compress(FileAccess.COMPRESSION_GZIP)


static func get_decompressed_data(data: PackedByteArray) -> Variant:
	return bytes_to_var(data.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))
