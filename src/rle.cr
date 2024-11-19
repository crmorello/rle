# Simple RLE module that is meant to handle data with large swaths of 0s
module RLE
  VERSION = "0.1.0"

  def self.compress(data : Bytes) : Bytes
    buffer = IO::Memory.new(data.size // 2) # Preallocate buffer
    i = 0
    
    while i < data.size
      if data[i] == 0
        count = count_zeros(data, i)
        buffer.write_byte(0_u8)
        buffer.write_bytes(count.to_u16, IO::ByteFormat::LittleEndian)
        i += count
      else
        length = count_nonzeros(data, i)
        buffer.write_byte(length.to_u8)
        buffer.write(data[i, length])
        i += length
      end
    end
    
    buffer.to_slice
  end

  private def self.count_zeros(data : Bytes, start : Int32) : Int32
    count = 0
    while start < data.size && data[start] == 0 && count < UInt16::MAX
      count += 1
      start += 1
    end
    count
  end

  private def self.count_nonzeros(data : Bytes, start : Int32) : Int32
    count = 0
    while start < data.size && data[start] != 0 && count < 255
      count += 1
      start += 1
    end
    count
  end
end
