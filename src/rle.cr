module RLE
  VERSION = "0.1.0"
  
  def self.compress(data : Bytes) : Bytes
    buffer = IO::Memory.new(data.size)
    i = 0
    while i < data.size
      value = data[i]
      count = count_repeating(data, i)
      
      buffer.write_byte(value)
      buffer.write_bytes(count.to_u16, IO::ByteFormat::LittleEndian)
      i += count
    end
    buffer.to_slice
  end

  def self.decompress(compressed : Bytes, original_size : Int64) : Bytes
    buffer = IO::Memory.new(original_size)
    i = 0
    while i < compressed.size
      value = compressed[i]
      i += 1
      count = IO::ByteFormat::LittleEndian.decode(UInt16, compressed[i, 2])
      i += 2
      
      buffer.write(Bytes.new(count.to_i32, value))
    end
    buffer.to_slice
  end

  private def self.count_repeating(data : Bytes, start : Int32) : Int32
    count = 0
    value = data[start]
    while start < data.size && data[start] == value && count < UInt16::MAX
      count += 1
      start += 1
    end
    count
  end
end