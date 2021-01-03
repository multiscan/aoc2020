#!/usr/bin/env ruby

class TileFlipper
	DIR=[ [ 0, 1],  # NE  0
	      [ 1, 0],  # E   1
	      [ 1,-1],  # SE  2
	      [ 0,-1],  # SW  3
	      [-1, 0],  # W   4
	      [-1, 1],  # NW  5
	]

	def initialize(s)
		ss = s.gsub("ne", "0").gsub("se", "2").gsub("e", "1")
		      .gsub("sw", "3").gsub("nw", "5").gsub("w", "4")
		input_tiles = ss.lines.map{|l| l.chomp}.map do |l|
			l.split('').map{|i| DIR[i.to_i]}
			           .inject([0,0]){|d,p| [d[0]+p[0], d[1]+p[1]]}
		end
		flip_counts ||= input_tiles.group_by{|x| x}.map{|k,v| [k,v.count] }.to_h
		# We only keep black tiles.
		@tiles = flip_counts.select{|k,v| v%2 == 1}.to_h
	end

	def black?(v)
		v%2 == 1
	end
	def black_count
		@tiles.count{|k,v| v%2 == 1}
	end

	def count_nn(k, extra=nil)

		DIR.inject(0) do |c,d|
			p = [k[0]+d[0], k[1]+d[1]]
			t = @tiles[p]
			if t.nil?
				extra << p unless extra.nil?
				c
			else
				c + ( black?(t) ?  1 : 0 )
			end
		end
	end

	def evolve
		extra=[]
		flip=[]
		@tiles.each do |k,v|
			nn = count_nn(k, extra)
			if black?(v)
				flip << k if (nn == 0 || nn > 2)
			else
				flip << k if nn == 2
			end
		end
		extra.sort.uniq.each do |k|
			@tiles[k] = 0
			nn = count_nn(k)
			flip << k if nn == 2
		end
		flip.each do |k|
			@tiles[k] = @tiles[k] + 1
		end
 	end
end

test1=File.read("input/24_test1.txt")
tf = TileFlipper.new(test1)
bc = tf.black_count
raise "Test 1 fails: got #{bc} black tiles instead of 10" unless bc == 10

e = """\
Day 1: 15
Day 2: 12
Day 3: 25
Day 4: 14
Day 5: 23
Day 6: 28
Day 7: 41
Day 8: 37
Day 9: 49
Day 10: 37
Day 20: 132
Day 30: 259
Day 40: 406
Day 50: 566
Day 60: 788
Day 70: 1106
Day 80: 1373
Day 90: 1844
Day 100: 2208
"""

r = ""
100.times do |i| 
	tf.evolve
	r << "Day #{i+1}: #{tf.black_count}\n" if i<10 || (i+1)%10==0
end 
raise "Test 2 fails. Got: \n#{r}" unless e == r




# Question 1: how many tiles are left with the black side up?
tf = TileFlipper.new(File.read("input/24.txt"))
bc = tf.black_count
puts "After all of the instructions have been followed there are #{bc} black tiles"


# Question 2: How many tiles will be black after 100 days?
100.times do |i|
	tf.evolve
end
bc=tf.black_count
puts "After 100 days there are #{bc} tiles"