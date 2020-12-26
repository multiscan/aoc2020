#!/usr/bin/env ruby

class CupGame
	def initialize(s,size=s.length)
		@ncups = size
		@cups = Array.new(@ncups)
		base = s.split('').map{|c| c.to_i - 1}
		base.first(base.count-1).each_with_index do |c, i|
			@cups[c] = base[i+1]
		end
		@cc = base.first
		if @ncups > base.count
			@cups[base.last] = base.count
			base.count.upto(@ncups-2) do |j|
				@cups[j] = j+1
			end
			@cups[@ncups-1] = @cc
		else
			@cups[base.last] = @cc
		end
		@mvn = 0
		# p @cups
		# puts base.map{|c| c+1}.join(' ')
		# @cups.each_with_index {|c,i| printf("%d->%d ", i+1, c+1)}; puts
	end

	def cups_s
		r = []
		c = @cc
		[@ncups, 20].min.times do |j|
			r << c+1
			c = @cups[c]
		end
		return r.join(" ")
	end

	def move
		# cc = current cup label
		# c1 = cc.next ; c3=cc.next.next.next ; d=cc-1 while d != c1,c2,c3
		# remove 3 cups: cc.next = c3.next
		# append after destination: c3.next=d.next ; d.next=c1
		@mvn = @mvn + 1

# puts 
# puts "-- move #{@mvn} -- cc = #{@cc+1}"
# puts "cups: " << cups_s
		c1 = @cups[@cc]
		c2 = @cups[c1]
		c3 = @cups[c2]
# puts "pick up: " << [c1, c2, c3].map{|c| c+1}.join(', ')
		d = (@cc - 1) % @ncups
		while [c1,c2,c3].include?(d)
			d = (d - 1) % @ncups
		end
# puts "destination: #{d+1}"

		# remove 3 cups:
		@cups[@cc] = @cups[c3]
		# append after destination
		@cups[c3] = @cups[d]
		@cups[d] = c1

		@cc = @cups[@cc]
	end

	# def cups_after_1_s
	# 	s = ""
	# 	c = @cups[0]
	# 	while c!=0
	# 		s << (c+1).to_s
	# 		c = @cups[c]
	# 	end
	# 	return s
	# end
	def cups_after_1_s(n=@ncups-1)
		cups_after_1(n).join('')
	end

	def cups_after_1(n=2)
		r=[]
		c = @cups[0]
		n.times do 
			r << c+1
			c = @cups[c]
		end
		r
	end

end

cg = CupGame.new("389125467")
100.times{|j| cg.move}
r = cg.cups_after_1_s
raise "Test 1 fails: r=#{r} instead of 67384529" unless r == "67384529"
ca1 = cg.cups_after_1
raise "Test 1 fails: #{ca1} instead of [6,7]" unless ca1 == [6,7]

# Question 1: Using your labeling, simulate 100 moves. 
#             What are the labels on the cups after cup 1?
cg = CupGame.new("284573961")
100.times{|j| cg.move}
r = cg.cups_after_1_s
puts "Cups labels after cup 1 and 100 moves: #{r}"


# Question 2: With 1000000 cups and 10000000 moves
#             Determine which two cups will end up immediately clockwise of cup 1.
#             What do you get if you multiply their labels together?
cg = CupGame.new("284573961", 1000000)
10000000.times do |j|
	cg.move
end
r = cg.cups_after_1
puts "Two Cups labels after cup 1 and 10000000 moves: #{r[0]} x #{r[1]} = #{r[0]*r[1]}"


