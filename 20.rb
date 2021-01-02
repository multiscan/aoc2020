#!/usr/bin/env ruby

class Tile
	attr_reader :id, :image, :imagewb, :flip
	ROT = [
		 1,  0, 
         0,  1,
         0, -1,
         1,  0,
        -1,  0, 
         0, -1, 
         0,  1,
        -1,  0,
        -1,  0,
         0,  1,
         0,  1,
         1,  0,
         1,  0,
         0, -1,
         0, -1,
        -1,  0,
    ]
	def self.from_string(ss)
		ss.split("\n\n").map do |tdata|
			Tile.new(tdata)
		end
	end
	def initialize(tdata)
		tl = tdata.lines.map{|l| l.chomp}
		@id=/([0-9]+)/.match(tl.first)[1].to_i

		# image to be used does not include the border
		@payload = tl[2..-2].map{|l| l[1..-2]}
		@payloadwb = tl[1..-1]

		dl=tl[1..].map do |l|
			l.gsub('.', '0').gsub('#', '1')
		end

		# TODO: compute edges using rotations instead of manually 
		# the various edges turning CW starting from North. 
		# Low-case letters are read in reverse order
		e_N = dl.first.to_i(2)
		e_n = dl.first.reverse.to_i(2)
		e_E = dl.map{|l| l[-1]}.join('').to_i(2)
		e_e = dl.map{|l| l[-1]}.join('').reverse.to_i(2)
		e_S = dl.last.to_i(2)
		e_s = dl.last.reverse.to_i(2)
		e_W = dl.map{|l| l[0]}.join('').to_i(2)
		e_w = dl.map{|l| l[0]}.join('').reverse.to_i(2)

		@e = []
		#          N E S W
		@e << e_N
		@e << e_E
		@e << e_S
		@e << e_W
        #          E s W n    Rot 90
		@e << e_E
		@e << e_s
		@e << e_W
		@e << e_n
        #          s w n e    rot 180
		@e << e_s
		@e << e_w
		@e << e_n
		@e << e_e
        #          w N e S    rot 270
		@e << e_w
		@e << e_N
		@e << e_e
		@e << e_S
		#          n W s E    Flip H
		@e << e_n
		@e << e_W
		@e << e_s
		@e << e_E
        #          W S E N    Flip H * rot 90
		@e << e_W
		@e << e_S
		@e << e_E
		@e << e_N
        #          S e N w    Flip V = Flip H * rot 180
		@e << e_S
		@e << e_e
		@e << e_N
		@e << e_w
		#          e n w s    Flip V + Rot 90 = Flip H * rot 270
		@e << e_e
		@e << e_n
		@e << e_w
		@e << e_s

		# Side edges
		@se = []
		@flip = nil
		@placed = false
		@image = nil
	end

	# all the edges including external ones
	def all_edges
		@e.uniq
	end

	# 0 == N, 1==E, 2==S, 3==W
	# specific edge once the tile is oriented
	def edge(i,flip=@flip)
		raise "Flip must be set when asking for a specific edge" if flip.nil?
		ee = @e[flip..(flip+3)][i]
	end

	def corner?
		@se.count == 4
	end

	def side?
		!@se.empty?
	end

	def compute_image(f=@flip)
		img = []
		rot = Tile::ROT[f..f+3]
		tra = rot.map{|r| r==-1 ? 7 : 0}
		8.times do |y|
			img << []
			8.times do |x|
				xx = (rot[0] * x + rot[1] * y + 8 + tra[0] + tra[1]) % 8
				yy = (rot[2] * x + rot[3] * y + 8 + tra[2] + tra[3]) % 8
				img[y] << @payload[yy][xx]
			end
		end
		img
	end

	def side_edge!(e)
		@se << e
	end

	def place(le,te,offset=0)
		return false if @placed
		(0..7).to_a.map{|f| ((f+offset)*4)%32}.each do |f|
			t = @e[f]
			l = @e[f+3]
			okt = te.nil? && @se.include?(t) || t==te
			okl = le.nil? && @se.include?(l) || l==le
			if okt && okl
				@flip = f
				@placed = true
				@image = self.compute_image
				return true
			end
		end
		return false
	end
end

class Puzzle
	def self.from_file(fname)
		Puzzle.new(File.read(fname))
	end
	def initialize(ss)
		@tiles = Tile.from_string(ss)
		@all_edges = @tiles.map{|t| t.all_edges}.flatten.uniq.sort
		@size = Math.sqrt(@tiles.count).to_i 

		@edmap = @all_edges.map{|e| [e,[]]}.to_h
		@tiles.each_with_index do |t,i|
			t.all_edges.uniq.each do |e|
				@edmap[e] << t
			end
		end
		# p @edmap
		@edmap.each do |e,tl|
			if tl.count == 1
				t=tl.first
				t.side_edge!(e)
			end
		end
		@image
	end
	def corner_tiles(tt=@tiles)
		tt.select {|t| t.corner?}
	end
	def arrange(offset=0)
		@grid={}
        t = nil
		@size.times do |y|
			@size.times do |x|
				if y == 0
					te = nil 
				else
					te = @grid[[x,y-1]].edge(2)
				end
				if x == 0
					le = nil
				else
					le = @grid[[x-1,y]].edge(1)
				end
				t = @tiles.find {|t| t.place(le, te, offset)}
				return false unless t
				@grid[[x,y]] = t
			end
		end

		true
	end

	def arrangement_string
		r = ""
		@size.times do |y|
			l = []
			@size.times do |x|
				t = @grid[[x,y]]
				l << "#{t.id}[#{t.flip/4}]" 
			end
			r << l.join(' ') << "\n"
		end
		r
	end

	# This for some reason does not work. Probably due to superposition of monsters
	def count_sea_monsters_in_image(img)
		ll = @size * 8
		seamonster = /..................#..{#{ll-20}}#....##....##....###.{#{ll-20}}.#..#..#..#..#..#.../
		img.flatten.join('').scan(seamonster).size
	end

	def count_sea_monsters_in_image2(img)
		ll = @size * 8
		sm1 = "..................#.".gsub(".", "0").gsub("#", "1").to_i(2)
		sm2 = "#....##....##....###".gsub(".", "0").gsub("#", "1").to_i(2)
		sm3 = ".#..#..#..#..#..#...".gsub(".", "0").gsub("#", "1").to_i(2)
		
		imglines = img.map{|l| l.join('').gsub(".", "0").gsub("#", "1")}
		m = 0
		(0..ll-21).to_a.each do |i|
			il = imglines.map{|l| l[i..i+19].to_i(2)}
			(0..ll-3).to_a.each do |j|
				if ((il[j] & sm1) == sm1) && ((il[j+1] & sm2) == sm2) && ((il[j+2] & sm3) == sm3)
					# puts "fount SM at line #{j} offset #{i}"
					m = m + 1
				end
			end
		end
		m
	end

	def count_sea_monsters
		nmx = 0
		8.times do |irot|
			img = self.image(irot)
			nm = count_sea_monsters_in_image2(img)
			nmx = nm if nm > nmx
		end
		nmx
	end



	def count_pounds
		self.image.flatten.count('#')
	end

	def compute_image
		img=[]
		is = @size*8 
		is.times do |y|
			yt = y / 8
			yy = y % 8
			img[y] = []
			is.times do |x|
				xt = x / 8
				xx = x % 8
				img[y] << @grid[[xt,yt]].image[yy][xx]
			end
		end
		img
	end

	def image(irot=0)
		@image ||= compute_image
		if irot == 0
			@image
		else
			is = @size*8
			rot=Tile::ROT[irot*4..irot*4+3]
			tra = rot.map{|r| r==-1 ? is-1 : 0}
			img = []
			is.times do |y|
				img[y] = []
				is.times do |x|
					xx = (rot[0]*x + rot[1]*y + is + tra[0] + tra[1]) % is
					yy = (rot[2]*x + rot[3]*y + is + tra[2] + tra[3]) % is
					img[y] << @image[yy][xx]
				end
			end
			img
		end
	end


	def imagewb(irot=0)
		@imagewb ||= compute_image_with_border
		if irot == 0
			@imagewb
		else
			is = @size*10
			rot=Tile::ROT[irot*4..irot*4+3]
			tra = rot.map{|r| r==-1 ? is-1 : 0}
			img = []
			is.times do |y|
				img[y] = []
				is.times do |x|
					xx = (rot[0]*x + rot[1]*y + is + tra[0] + tra[1]) % is
					yy = (rot[2]*x + rot[3]*y + is + tra[2] + tra[3]) % is
					# puts "  #{x} -> #{xx}    #{y} -> #{yy}"
					img[y] << @imagewb[yy][xx]
				end
			end
			img
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


eas = """\
1951[6] 2311[6] 3079[0]
2729[6] 1427[6] 2473[7]
2971[6] 1489[6] 1171[4]
"""
puz=Puzzle.from_file("input/20_test.txt")
ok = puz.arrange(5)
as = puz.arrangement_string
raise "Failed arrangement" unless ok && as == eas

nsm = puz.count_sea_monsters
np = puz.count_pounds
wr = np - nsm*15
raise "Wrong number of sea monsters" unless nsm == 2
raise "Wrong water roughness" unless wr == 273

# Question 1: What do you get if you multiply together the IDs of the four corner tiles?
puz=Puzzle.from_file("input/20.txt")
ct=puz.corner_tiles.map{|t| t.id}.sort
ctprod = ct.reduce(:*)
puts "ct = #{ct}  => product: #{ctprod}"

# Question 2: How many # are not part of a sea monster?
puz=Puzzle.from_file("input/20.txt")
ok = puz.arrange
raise "Could not solve puzzle" unless ok
nsm = puz.count_sea_monsters
np = puz.count_pounds
wr = np - nsm*15
puts "Number of sea monsters: #{nsm}"
puts "Water roughness (no. # that are not part of sea monster: #{wr}"
