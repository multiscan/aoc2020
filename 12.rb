#!/usr/bin/env ruby
class Ship1
	MOVES = {   
		#        A  F  E  N
		"E" => [ 0, 0, 1, 0],
		"W" => [ 0, 0,-1, 0],
		"N" => [ 0, 0, 0, 1],
		"S" => [ 0, 0, 0,-1],
		"L" => [ 1, 0, 0, 0],
		"R" => [-1, 0, 0, 0],
		"F" => [ 0, 1, 0, 0]
	}
	ANGLES = {
		"E" => 0,
		"N" => 90,
		"W" => 180,
		"S" => 270,
	}

	def initialize(current_direction="E")
		@pos = [0,0]
		@cd = ANGLES[current_direction]
	end

	def move(s)
		directive = s[0]
		amount = s[1..].to_i
		a, f, e, n = MOVES[directive]
		if a != 0
			@cd = @cd + a*amount
			return
		end
		if f !=0
			cdrad = @cd * Math::PI / 180.0
			@pos[0] = @pos[0] + f * amount * Math.cos(cdrad)
			@pos[1] = @pos[1] + f * amount * Math.sin(cdrad)
		else
			@pos[0] = @pos[0] + e * amount
			@pos[1] = @pos[1] + n * amount
		end 
	end

	def moves(ss)
		ss.lines.each do |l|
			self.move(l.chomp)
		end
	end

	def man_dist
		(@pos[0].abs + @pos[1].abs).round
	end

	def to_s
		"Current position: #{@pos[0]}, #{@pos[1]} / Manhattan distance: #{self.man_dist} / heading: #{@cd}"
	end
end

class Ship2
	MOVES = {
		"E" => [ 1, 0],
		"W" => [-1, 0],
		"N" => [ 0, 1],
		"S" => [ 0,-1]
	}
	ROTATIONS = {
		  0 => [ 1, 0,
		         0, 1],
		 90 => [ 0,-1,
		         1, 0],
		180 => [-1, 0,
		         0,-1],
		270 => [ 0, 1,
		        -1, 0]
	}

	def initialize(current_direction="E")
		@pos = [0,0]
		@wp_rel_pos = [10,1]
	end

	def move(s)
		directive = s[0]
		amount = s[1..].to_i
		if directive == "F" # move the sheep amount times toward the waypoint
			@pos = [
				@pos[0] + amount * @wp_rel_pos[0],
				@pos[1] + amount * @wp_rel_pos[1]
			]
		else
			if directive == "R"
				directive = "L"
				amount = (amount + 180)%360
			end
			if directive == "L" # rotate the waypoint around the ship
				rot = ROTATIONS[amount]
				@wp_rel_pos = [
					@wp_rel_pos[0] * rot[0] + @wp_rel_pos[1] * rot[1],
					@wp_rel_pos[0] * rot[2] + @wp_rel_pos[1] * rot[3],
				]
			else # move the waypoint
				@wp_rel_pos[0] = @wp_rel_pos[0] + amount * MOVES[directive][0]
				@wp_rel_pos[1] = @wp_rel_pos[1] + amount * MOVES[directive][1]
			end
		end
	end

	def moves(ss)
		ss.lines.each do |l|
			begin
				self.move(l.chomp)
			rescue
				puts "Error with move #{l.chomp}"
			end
		end
	end

	def man_dist
		@pos[0].abs + @pos[1].abs
	end

	def to_s
		"Current position: #{@pos[0]}, #{@pos[1]} / Manhattan distance: #{self.man_dist} / waypoint at (#{@wp_rel_pos[0]}, #{@wp_rel_pos[1]})"
	end

end

t1 = """\
F10
N3
F7
R90
F11"""

s1=Ship1.new()
puts s1.to_s
s1.moves(t1)
d=s1.man_dist
raise "Test 1: wrong manhattan distance #{d} instead of 25" unless d == 25

s2=Ship2.new()
s2.moves(t1)
d=s2.man_dist
raise "Test 2: wrong manhattan distance #{d} instead of 286" unless d == 286


# Question 1: What is the Manhattan distance between that location and the 
#             ship's starting position?
s3=Ship1.new()
s3.moves(File.read("input/12.txt"))
puts "Manhattan distance = #{s3.man_dist}"

# Question 2: Figure out where the navigation instructions actually lead. What 
#             is the Manhattan distance between that location and the ship's 
#             starting position?
# TODO this gave the wrong result but I couldn't figure out why yet
s4=Ship2.new()
s4.moves(File.read("input/12.txt"))
puts "Manhattan distance = #{s4.man_dist}"
