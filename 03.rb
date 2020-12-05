#!/usr/bin/env ruby

class TreeCounter
	def initialize(lines)
		@ll = lines
		@nr = @ll.size
		@nc = @ll.first.size
	end

	def count(dc, dr)
		r=0; c=0; nt=0
		while r<@nr
			nt = nt + 1 if @ll[r][c] == '#'
			r = r + dr
			c = ( c + dc ) % @nc
		end
		nt
	end
end

t1 = [
  "..##.......",
  "#...#...#..",
  ".#....#..#.",
  "..#.#...#.#",
  ".#...##..#.",
  "..#.##.....",
  ".#.#.#....#",
  ".#........#",
  "#.##...#...",
  "#...##....#",
  ".#..#...#.#",
]
ts = [
	3, 1, 7,   # right, down, number of trees
	1, 1, 2,
	5, 1, 3,
	7, 1, 4,
	1, 2, 2,
]
tc = TreeCounter.new(t1)
ts.each_slice(3) do |l|
	r, d, e = l
	c = tc.count(r, d)
	unless c == e
		puts "Error: for test data t1, right #{r}, down #{d} should count #{e} trees but #{c} were found"
	end
end

ll=File.readlines("input/03.txt").map{|l| l.chomp}
tc = TreeCounter.new(ll)

# Question 1: Starting at the top-left corner of your map and following a slope 
#             of right 3 and down 1, how many trees would you encounter?
r = tc.count(3, 1)
puts "For right 3 down 1 the number of trees is #{r}"

# Question 2: What do you get if you multiply together the number of trees 
#             encountered on each of the listed slopes?
slopes = [
	1, 1,     # right, down
	3, 1,
	5, 1,
	7, 1,
	1, 2,
].each_slice(2).to_a

nt = slopes.inject(1) { |prod, s| prod * tc.count(s[0], s[1]) }
puts "Product: #{nt}"
