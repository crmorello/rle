require "./spec_helper"

describe RLE do
  describe ".compress" do
    it "handles all zeros" do
      data = Bytes[0, 0, 0, 0]
      compressed = RLE.compress(data)
      compressed.should eq Bytes[0, 4, 0] # [flag, count_le, count_be]
    end

    it "handles no zeros" do
      data = Bytes[1, 2, 3]
      compressed = RLE.compress(data)
      compressed.should eq Bytes[3, 1, 2, 3] # [length, values...]
    end

    it "handles alternating zeros" do
      data = Bytes[0, 1, 0, 2]
      compressed = RLE.compress(data)
      compressed.should eq Bytes[0, 1, 0, 1, 1, 0, 1, 0, 1, 2]
    end

    it "handles large zero sequences" do
      data = Bytes.new(1000, 0)
      compressed = RLE.compress(data)
      compressed.size.should eq 3 # [flag, count_le, count_be]
    end

    it "handles mixed data" do
      data = Bytes[1, 2, 0, 0, 0, 3, 4]
      compressed = RLE.compress(data)
      compressed.should eq Bytes[2, 1, 2, 0, 3, 0, 2, 3, 4]
    end

    it "respects UInt16::MAX for zero counts" do
      data = Bytes.new(70000, 0)
      compressed = RLE.compress(data)
      compressed.size.should be > 3 # Should split into multiple zero sequences
    end

    it "respects 255 limit for non-zero sequences" do
      data = Bytes.new(300, 1)
      compressed = RLE.compress(data)
      compressed.size.should be > 2 # Should split into multiple sequences
    end
  end
end
