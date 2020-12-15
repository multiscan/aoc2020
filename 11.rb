#!/usr/bin/env ruby

class Seat
	attr_reader :status
	def initialize(s,adj)
		@status = s
		@adjacent = []
		@next_status = '?'
		@r=nil
		@c=nil
		@at_most_before_leaving = adj ? 3 : 4
	end
	def reset
		@adjacent = []
		@next_status = '?'
	end
	def set_position(k)
		@k = k
	end
	def position()
		@k
	end
	def <<(seat)
		@adjacent << seat
	end
	def occupied?
		@status == '#'
	end
	def occupied_adjacent()
		@adjacent.count{|s| s.occupied?}
	end
	def prepare_next_gen
		oa = self.occupied_adjacent() 
		if !self.occupied? && oa == 0
			@next_status = '#'
		elsif self.occupied? && oa > @at_most_before_leaving
			@next_status = 'L'
		else
			@next_status = @status
		end
	end
	def evolve
		@status = @next_status
	end
	def to_s
		"#{@r},#{@c} : #{@status} nn=#{occupied_adjacent()}/#{@adjacent.count} -> #{@next_status}"
	end
	def changing?
		@status != @next_status
	end
end

class SeatPredictor
	attr_reader :seats, :grid, :ngen
	def initialize(s, adj=true)
		original_grid = s.lines.map{|l| l.chomp}
		ognr = original_grid.count
		ognc = original_grid.first.length
		@ngen = 0

		@seats = []
		@period = ognc+2
		@grid = Array.new( (ognr+2)*(ognc+2) ).fill(-1)

		original_grid.each_with_index do |row, i|
			ii = i + 1
			row.split('').each_with_index do |s, j|
				jj = j + 1

				kk = ii * @period + jj
				if s == "."
					@grid[kk] = nil
				else
					ss = Seat.new(s,adj)
					ss.set_position(kk)
					@grid[kk] = @seats.count
					@seats << ss
				end
			end
		end
		set_targets(adj)
	end

	def set_targets(adj=true)

		others=[
			[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]
		].map{|v| v[0]*@period + v[1]}

		@seats.each do |s|
			s.reset
			k = s.position
			if adj
				others.each do |dk|
					os = @grid[k + dk]
					if os and os>=0
						s << @seats[os]
					end
				end
			else
				others.each do |dk|
					kk = k + dk					
					while ( (os=@grid[kk]).nil? )
						kk = kk + dk
					end
					if os>=0
						s << @seats[os]
					end
				end
			end
		end
	end

	def evolve
		@seats.each do |s| 
			s.prepare_next_gen
		end
		if @seats.count{|s| s.changing?} > 0
			@seats.each do |s| 
				s.evolve
			end
			@ngen = @ngen + 1
			return true
		else
			return false
		end
	end

	def to_s(long=false)
		s = @grid.map do |r| 
			r.nil? ? "." : (r<0 ? nil : (@seats[r].occupied? ? '#' : 'L'))
		end.compact.each_slice(@period-2).to_a.map{|l| l.join('')}.join("\n")
		if long
			s = s + "\nOccupancy: #{self.count_occupied} / #{@seats.count}"
		end
		return s
	end

	def seat_at(r,c)
		k = (r+1)*@period + c + 1
		g = @grid[k]
		return g ? @seats[g] : g
	end

	def count_occupied
		no=0
		@seats.each {|s| no = no + 1 if s.occupied? }
		# @seats.count{|s| s.occupied?}
		no
	end
end

test_grid = """\
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL"""

tests_adj=[]
tests_adj << """\
#.##.##.##
#######.##
#.#.#..#..
####.##.##
#.##.##.##
#.#####.##
..#.#.....
##########
#.######.#
#.#####.##"""

tests_adj << """\
#.LL.L#.##
#LLLLLL.L#
L.L.L..L..
#LLL.LL.L#
#.LL.LL.LL
#.LLLL#.##
..L.L.....
#LLLLLLLL#
#.LLLLLL.L
#.#LLLL.##"""

tests_adj << """\
#.##.L#.##
#L###LL.L#
L.#.#..#..
#L##.##.L#
#.##.LL.LL
#.###L#.##
..#.#.....
#L######L#
#.LL###L.L
#.#L###.##"""

tests_adj << """\
#.#L.L#.##
#LLL#LL.L#
L.L.L..#..
#LLL.##.L#
#.LL.LL.LL
#.LL#L#.##
..L.L.....
#L#LLLL#L#
#.LLLLLL.L
#.#L#L#.##"""

tests_adj << """\
#.#L.L#.##
#LLL#LL.L#
L.#.L..#..
#L##.##.L#
#.#L.LL.LL
#.#L#L#.##
..L.L.....
#L#L##L#L#
#.LLLLLL.L
#.#L#L#.##"""

tests_na = []
tests_na << """\
#.##.##.##
#######.##
#.#.#..#..
####.##.##
#.##.##.##
#.#####.##
..#.#.....
##########
#.######.#
#.#####.##"""

tests_na << """\
#.LL.LL.L#
#LLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLL#
#.LLLLLL.L
#.LLLLL.L#"""

tests_na << """\
#.L#.##.L#
#L#####.LL
L.#.#..#..
##L#.##.##
#.##.#L.##
#.#####.#L
..#.#.....
LLL####LL#
#.L#####.L
#.L####.L#"""

tests_na << """\
#.L#.L#.L#
#LLLLLL.LL
L.L.L..#..
##LL.LL.L#
L.LL.LL.L#
#.LLLLL.LL
..L.L.....
LLLLLLLLL#
#.LLLLL#.L
#.L#LL#.L#"""

tests_na << """\
#.L#.L#.L#
#LLLLLL.LL
L.L.L..#..
##L#.#L.L#
L.L#.#L.L#
#.L####.LL
..#.#.....
LLL###LLL#
#.LLLLL#.L
#.L#LL#.L#"""

tests_na << """\
#.L#.L#.L#
#LLLLLL.LL
L.L.L..#..
##L#.#L.L#
L.L#.LL.L#
#.LLLL#.LL
..#.L.....
LLL###LLL#
#.LLLLL#.L
#.L#LL#.L#"""

sp = SeatPredictor.new(test_grid, true)
sp.to_s == test_grid or raise "Test 1 iteration 0 failed"
tests_adj.each_with_index do |t, i|
	sp.evolve
	sp.to_s == t or raise "Test 1 iteration #{i} failed"
end
no = sp.count_occupied
raise "Test 1: wrong final number of occupied seats: #{no} instead of 37" unless no==37 


sp = SeatPredictor.new(test_grid, false)
sp.to_s == test_grid or raise "Test 2 iteration 0 failed"
tests_na.each_with_index do |t, i|
	sp.evolve
	sp.to_s == t or raise "Test 2 iteration #{i} failed"
end
no = sp.count_occupied
raise "Test 2: wrong final number of occupied seats: #{no} instead of 26" unless no==26

# Question 1:
# Simulate your seating area by applying the seating rules 
# repeatedly until no seats change state. 
# How many seats end up occupied?
sp = SeatPredictor.new(File.read("input/11.txt"), true)
begin 
	de=sp.evolve()
end while de
puts "Evolution ran for #{sp.ngen} generations."
puts "Number of occupied seats is: #{sp.count_occupied}"


# Question 2:
sp = SeatPredictor.new(File.read("input/11.txt"), false)
begin 
	de=sp.evolve()
end while de
puts "Evolution ran for #{sp.ngen} generations."
puts "Number of occupied seats is: #{sp.count_occupied}"

