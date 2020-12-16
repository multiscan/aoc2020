#!/usr/bin/env ruby
class Integer
	def to_bin_s(l=36)
		s = self.to_s(2)
		"0" * (l-s.length) + s
	end
end


class BitmaskProgram
	def initialize(s)
		@lines = s.lines.map{|l| l.chomp}
		# @memory = Array.new(36).fill(0)
		# Looks like memory is quite sparse, let's use an hash instead
		@memory = {}
	end

	# mask will change the value before it is written to memory:
	# 0 or 1 overwrites the corresponding bit in the value
	# X leaves the bit in the value unchanged 
	def run
		bitmask_or = 0
		bitmask_and = 2**36 - 1
		@lines.each do |l|
			if l.start_with?("mask")
				m = l.split(" ")[2]
				bitmask_or = m.gsub("X", "0").to_i(2)
				bitmask_and = m.gsub("X", "1").to_i(2)
			elsif m = /mem\[(\d+)\]\s+=\s(\d+)/.match(l)
				addr = m[1].to_i
				value = m[2].to_i
				mvalue = value & bitmask_and | bitmask_or
				@memory[addr] = mvalue
			end
		end
	end

	# mask will change the address
	# 0 -> the corresponding memory address bit is unchanged
	# 1 -> the corresponding memory address bit is overwritten with 1
	# X -> the corresponding memory address bit is floating. The address will
	#      be replicated for all possible values
	# b & 0 | 0 = 0    => for setting a bit put the bit in both and and or mask
	# b & 1 | 1 = 1
	# b & 1 | 0 = b    => for keeping a bit put 1 in and and 0 in or mask
	def gen_float_masks(m)

    bm = []
    base_and = m.gsub(/0/, "1")
    base_or  = m.gsub(/0/, "0")

    nx = m.count("X")
    nm = 2**nx
    nm.times do |i|
      bi = i.to_bin_s(nx)
      a = base_and.clone
      o = base_or.clone
      nx.times do |j|
        a.sub!("X", bi[j])
        o.sub!("X", bi[j])
      end
      bm << [
        a.to_i(2),
        o.to_i(2),
      ]
    end
    bm
  end

	def run_v2
		addr_bit_masks = []
		@lines.each do |l|
			if l.start_with?("mask")
				m = l.split(" ")[2]
				addr_bit_masks = gen_float_masks(m)
			elsif m = /mem\[(\d+)\]\s+=\s(\d+)/.match(l)
				baddr = m[1].to_i
				value = m[2].to_i
				addr_bit_masks.each do |bm_and, bm_or|
					addr = baddr & bm_and | bm_or
					@memory[addr] = value
				end
			end
		end
	end

	def memory_sum
		@memory.values.reduce(:+)
	end

end

testp1 = """\
mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0
"""
e = 165
bp = BitmaskProgram.new(testp1)
bp.run
r = bp.memory_sum
raise "Test 1 fails. Sum = #{r} instead of #{e}" unless r == e


testp2 = """\
mask = 000000000000000000000000000000X1001X
mem[42] = 100
mask = 00000000000000000000000000000000X0XX
mem[26] = 1
"""
e = 208 
bp = BitmaskProgram.new(testp2)
bp.run_v2
r = bp.memory_sum
raise "Test 2 fails. Sum = #{r} instead of #{e}" unless r == e







# Question 1: Execute the initialization program. 
#             What is the sum of all values left in memory after it completes?
bp = BitmaskProgram.new(File.read("input/14.txt"))
bp.run
r = bp.memory_sum
puts "Sum of memory after program run is #{r}"


# Question 2: Execute the initialization program using an emulator 
#             for a version 2 decoder chip. 
#             What is the sum of all values left in memory after it completes?
bp = BitmaskProgram.new(File.read("input/14.txt"))
bp.run_v2
r = bp.memory_sum
puts "Sum of memory after program run with v2 rules is #{r}"



