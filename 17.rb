#!/usr/bin/env ruby
class Life3d
	HD1 = 0.upto(26).map{|n| sprintf("%03d", n.to_s(3).to_i)}.select{|s| s!="111"}.map{|s| s.split('').map{|v| v.to_i-1}}

	def initialize(s)

		@cubes={}

		lines = s.lines.map{|l| l.chomp}
		ny = lines.count
		nx = lines.first.size
		nz = 1

		@xmin = 0; @xmax = nx - 1
		@ymin = 0; @ymax = ny - 1
		@zmin = 0; @zmax = 0
		z=0
		lines.each_with_index do |l, y|
			l.chomp.split('').each_with_index do |c,x|
				@cubes[[x, y, z]] = c=='#'
			end
		end
	end

	def evolve
		activate = []
		deactivate = []
		(@xmin-1).upto(@xmax+1) do |x|
			(@ymin-1).upto(@ymax+1) do |y|
				(@zmin-1).upto(@zmax+1) do |z|
					c = 0
					HD1.each do |dx,dy,dz|
						c = c + (@cubes[[x+dx,y+dy,z+dz]] ? 1 : 0)
					end
					if @cubes[[x,y,z]]
						deactivate << [x,y,z] unless (c==2 || c==3)
					else
						activate << [x,y,z] if c == 3
					end
				end
			end
		end
		deactivate.each do |c|
			@cubes[c] = false
		end
		activate.each do |c|
			@cubes[c] = true
		end

		self.set_boundaries
		# TODO: garbage collect inactive the cells that are more than 2 away from last active
		acc = @cubes.count{|k,v| v}
		acc
	end

	def set_boundaries
		ac = @cubes.select{|c,v| v}
		x,y,z = ac.first[0]
		@xmin = @xmax = x
		@ymin = @ymax = y
		@zmin = @zmax = z
		ac.each do |c, v|
				x,y,z = c
				@xmin = [x,@xmin].min
				@ymin = [y,@ymin].min
				@zmin = [z,@zmin].min
				@xmax = [x,@xmax].max
				@ymax = [y,@ymax].max
				@zmax = [z,@zmax].max
		end
	end

	def to_s
		s = ""
		@zmin.upto @zmax do |z|
			s << "z=#{z}\n"
			@ymin.upto @ymax do |y|
				@xmin.upto @xmax  do |x|
					s << (@cubes[[x,y,z]] ? '#' : '.')
				end
				s << "\n"
			end
			s << "\n"
		end
		s
	end
end

# I am too lazy to generalize Life3d. Just cloning and adapting to 4d.
class Life4d
	HD1 = 0.upto(3**4-1).map{|n| sprintf("%04d", n.to_s(3).to_i)}.select{|s| s!="1111"}.map{|s| s.split('').map{|v| v.to_i-1}}
	def initialize(s)

		@cubes={}

		lines = s.lines.map{|l| l.chomp}
		ny = lines.count
		nx = lines.first.size
		nz = 1

		z=0; w=0;
		lines.each_with_index do |l, y|
			l.chomp.split('').each_with_index do |c,x|
				@cubes[[x, y, z, w]] = c=='#'
			end
		end
		self.set_boundaries
	end

	def evolve
		activate = []
		deactivate = []
		(@xmin-1).upto(@xmax+1) do |x|
			(@ymin-1).upto(@ymax+1) do |y|
				(@zmin-1).upto(@zmax+1) do |z|
					(@wmin-1).upto(@wmax+1) do |w|
						c = 0
						HD1.each do |dx,dy,dz,dw|
							c = c + (@cubes[[x+dx,y+dy,z+dz,w+dw]] ? 1 : 0)
						end
						if @cubes[[x,y,z,w]]
							deactivate << [x,y,z,w] unless (c==2 || c==3)
						else
							activate << [x,y,z,w] if c == 3
						end
					end
				end
			end
		end
		deactivate.each do |c|
			@cubes[c] = false
		end
		activate.each do |c|
			@cubes[c] = true
		end

		self.set_boundaries
		# TODO: garbage collect inactive the cells that are more than 2 away from last active
		acc = @cubes.count{|k,v| v}
		acc
	end

	def set_boundaries
		ac = @cubes.select{|c,v| v}
		x,y,z,w = ac.first[0]
		@xmin = @xmax = x
		@ymin = @ymax = y
		@zmin = @zmax = z
		@wmin = @wmax = w
		ac.each do |c, v|
				x,y,z,w = c
				@xmin = [x,@xmin].min
				@ymin = [y,@ymin].min
				@zmin = [z,@zmin].min
				@wmin = [w,@wmin].min
				@xmax = [x,@xmax].max
				@ymax = [y,@ymax].max
				@zmax = [z,@zmax].max
				@wmax = [w,@wmax].max
		end
	end

	def to_s
		s = ""
		@wmin.upto @wmax do |w|
			@zmin.upto @zmax do |z|
				s << "z=#{z}, w=#{w}\n"
				@ymin.upto @ymax do |y|
					@xmin.upto @xmax  do |x|
						s << (@cubes[[x,y,z,w]] ? '#' : '.')
					end
					s << "\n"
				end
				s << "\n"
			end
		end
		s
	end
end




test1 = """\
.#.
..#
###
"""
tres1 = """\
z=-1
#..
..#
.#.

z=0
#.#
.##
.#.

z=1
#..
..#
.#.

"""

g = Life3d.new(test1)

c = g.evolve
unless tres1 == g.to_s
	puts "expecting: "
	puts tres1
	puts "Obtained: "
	puts g.to_s
	raise "Test 1a fails" 
end
5.times {|i| c = g.evolve}
raise "Test 1b fails: final count is #{c} instead of #{112}" unless c == 112

tres2 = """\
z=-1, w=-1
#..
..#
.#.

z=0, w=-1
#..
..#
.#.

z=1, w=-1
#..
..#
.#.

z=-1, w=0
#..
..#
.#.

z=0, w=0
#.#
.##
.#.

z=1, w=0
#..
..#
.#.

z=-1, w=1
#..
..#
.#.

z=0, w=1
#..
..#
.#.

z=1, w=1
#..
..#
.#.

"""
g = Life4d.new(test1)
g.evolve()
unless tres2 == g.to_s
	puts "expecting: "
	puts tres2
	puts "Obtained: "
	puts g.to_s
	raise "Test 1b fails" 
end


# Question 1: 
# How many cubes are left in the active state after the sixth cycle?
g = Life3d.new(File.read("input/17.txt"))
c = 0
6.times {|i| c = g.evolve}
puts "After 6 cycles we have #{c} active cubes"


# Question 2:
# Starting with your given initial configuration, simulate six cycles in a 
# 4-dimensional space. 
# How many cubes are left in the active state after the sixth cycle?
g = Life4d.new(File.read("input/17.txt"))
c = 0
6.times {|i| c = g.evolve}
puts "After 6 cycles we have #{c} active cubes"
