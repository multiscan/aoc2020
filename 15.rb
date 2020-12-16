#!/usr/bin/env ruby

class MemoryGame
	attr_reader :log
	def initialize(s)
		@nn = {}
		@log = s.split(",").map{|n| n.to_i}
		@log[..-1].each_with_index do |n, i| 
			@nn[n] = i+1
		end
		@last = @log[-1]
		@gen  = @log.count
	end

	def run(target_gen=2020)
		while @gen < target_gen do 
			prev = @nn[@last]
			@nn[@last] = @gen
			if prev.nil?
				@last = 0
			else
				@last = @gen - prev
			end
			@log << @last
			@gen = @gen + 1
		end
	end
end

t0 = "0,3,6"
e0 = [0, 3, 6, 0, 3, 3, 1, 0, 4, 0]
mg = MemoryGame.new("0,3,6")
mg.run(10)
assert "Test 0 failed: #{mg.log}" unless mg.log == e0

t1 = [
	"1,3,2", 1,
    "2,1,3", 10,
    "1,2,3", 27,
    "2,3,1", 78,
    "3,2,1", 438,
    "3,1,2", 1836,
].each_slice(2) do |t, e|
	mg = MemoryGame.new(t)
	mg.run(2020)
	r = mg.log.last
	assert "Test 1 failed for t='#{t}': #{r} instead of #{e}" unless r == e
	puts "#{t} -> #{r} / #{e}"
end

# Question 1: Given your starting numbers, what will be the 2020th number spoken?
mg = MemoryGame.new("19,0,5,1,10,13")
mg.run(2020)
r = mg.log.last
puts "The 2020th number spoken is #{r}."

# t2 = [
#     "0,3,6", 175594,
#     "1,3,2", 2578,
#     "2,1,3", 3544142,
#     "1,2,3", 261214,
#     "2,3,1", 6895259,
#     "3,2,1", 18,
#     "3,1,2", 362,
# ].each_slice(2) do |t, e|
# 	mg = MemoryGame.new(t)
# 	mg.run(30000000)
# 	r = mg.log.last
# 	assert "Test 1 failed for t='#{t}': #{r} instead of #{e}" unless r == e
# 	puts "#{t} -> #{r} / #{e}"
# end


# Question 2: Given your starting numbers, what will be the 30000000th number spoken?
mg = MemoryGame.new("19,0,5,1,10,13")
mg.run(30000000)
r = mg.log.last
puts "The 30000000th number spoken is #{r}."
