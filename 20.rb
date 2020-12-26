#!/usr/bin/env ruby

class Tile
	attr_reader :id
	def self.from_string(ss)
		ss.split("\n\n").map do |tdata|
			Tile.new(tdata)
		end
	end
	def initialize(tdata)
		tl = tdata.lines.map{|l| l.chomp}
		@id=/([0-9]+)/.match(tl.first)[1].to_i
		@dl=tl[1..].map do |l|
			l.gsub('.', '0').gsub('#', '1')
		end
		@se = [] # CW
		@se << @dl.first.to_i(2)
		@se << @dl.map{|l| l[-1]}.join('').to_i(2)
		@se << @dl.last.reverse.to_i(2)
		@se << @dl.map{|l| l[0]}.join('').reverse.to_i(2)
		@re = [] # CCW
		@re << @dl.first.reverse.to_i(2)
		@re << @dl.map{|l| l[0]}.join('').to_i(2)
		@re << @dl.last.to_i(2)
		@re << @dl.map{|l| l[-1]}.join('').reverse.to_i(2)
	end
	def edges
		@se + @re
	end
	def to_s
		s = "\n"
	    s << "Tile #{@id}: #{@edges.join(' ')}\n"
		s << @dl.join("\n") << "\n"
	end
	def match?(t)
		edges.any?{|e| t.edges.include?(e)}
	end
end

class Puzzle
	def self.from_file(fname)
		Puzzle.new(File.read(fname))
	end
	def initialize(ss)
		@tiles = Tile.from_string(ss)
		@all_edges = @tiles.map{|t| t.edges}.flatten.sort
		@edge_counts = @all_edges.group_by{|x| x}.map{|k,v| [k,v.count] }.to_h
		@size = Math.sqrt(@tiles.count).to_i 
		puts "single edges: #{@edge_counts.values.count(1)}"
		puts "double edges: #{@edge_counts.values.count(2)}"
		puts "total  edges: #{@all_edges.count}"
		puts "number of tiles: #{@tiles.count}   puzzle size: #{@size}x#{@size}"
		# @tiles.each { |t| puts t.to_s }
	end
	def corner_tiles(tt=@tiles)
		# @tiles.each do |t| 
		# 	ec = t.edges.map{|e| "#{e}:#{@edge_counts[e]}"}.join(" ")
		# 	puts "#{t.id} -> #{ec}"
		# end
		tt.select do |t|
			t.edges.count {|e| @edge_counts[e]==1} == 4	
		end
	end
	def arrange
		ct = self.corner_tiles.first
		puts "First tile is #{ct.id}"
		rem = @tiles.dup
		rem.delete(ct)
		while rem.count > 0
			nt = rem.find{|t| ct.match?(t) }
			puts "Next  tile is #{nt.id}"
			rem.delete(nt)
		end
	end
	def ne(e)
		@edge_counts[e]
	end
end

puz=Puzzle.from_file("input/20_test.txt")
ct = puz.corner_tiles.map{|t| t.id}.sort 
unless ct == [1171, 1951, 2971, 3079]
	raise "Test1: corner tiles do not match: #{ct} vs [1171, 1951, 2971, 3079]"
end

ct = puz.corner_tiles
ct.each do |t|
	ewc = t.edges.map{|e| "#{e} (#{puz.ne(e)})"}
	puts "#{t.id}: #{ewc}"
end


# Question 1: What do you get if you multiply together the IDs of the four corner tiles?
puz=Puzzle.from_file("input/20.txt")
ct=puz.corner_tiles.map{|t| t.id}.sort
ctprod = ct.reduce(:*)
puts "ct = #{ct}  => product: #{ctprod}"

# puz.arrange

# 1951    2311    3079
# 2729    1427    2473
# 2971    1489    1171



