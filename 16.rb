#!/usr/bin/env ruby
class Rule
	attr_reader :name
	RRE = /^([a-z ]+): (\d+-\d+) or (\d+-\d+)$/
	def initialize(s)
		m = RRE.match(s)
		if m
			@name = m[1]
			@r1 = m[2].split("-").map{|v| v.to_i}
			@r2 = m[3].split("-").map{|v| v.to_i}
		else
			raise "Invalid rule #{s}"
		end
	end

	def validates?(t)
		@r1[0] <= t && t <= @r1[1] || @r2[0] <= t && t <= @r2[1]
	end
end

class ValueSet
	def initialize(s)
		@values = s.split(",").map{|c| c.to_i}
	end
end

class TicketDecoder
	def initialize(s)
		s_rules, s_my, s_nb = s.split("\n\n")
		@rules = s_rules.lines.map{|l| Rule.new(l)}
		@myval = s_my.lines.last.split(",").map{|c| c.to_i}
		@nbval = []
		s_nb.lines[1..].each do |l|
			@nbval << l.split(",").map{|c| c.to_i}
		end
	end

	def is_value_compatible_with_at_least_one_rule?(v)
		@rules.each do |r| 
			return true if r.validates?(v) 
		end
		false
	end
	# sum of nearby ticket values that are incompatible with all rules
	def scanning_error_rate()
		@nbval.flatten.select do |v| 
			not is_value_compatible_with_at_least_one_rule?(v)
		end.reduce(:+) || 0
	end

	def discard_nearby_ticket_with_scan_errors!()
		@nbval.select! do |vals|
			! vals.any? {|v| !is_value_compatible_with_at_least_one_rule?(v)}
		end
	end

	def find_rules_indexing
		discard_nearby_ticket_with_scan_errors!
		# puts "No. tickets after discarding scan errors: #{@nbval.count}"

		# bit matrix rules x values that 
		# is true if the rule validates the given value for all the tickets
		nv = @nbval.first.count
		cmpmatrix = @rules.map do |r|
			cm = Array.new(nv).fill(false)
			# cm = Array.new(nv).fill(0)
			nv.times do |i|
				cm[i] = ! @nbval.any?{|vals| !r.validates?(vals[i])}
				# cm[i] = @nbval.count{|vals| r.validates?(vals[i])}
			end
			cm
		end
		# cmpmatrix.each_with_index do |rule, i|
		# 	is=printf("%2d ", i)
		# 	puts rule.map{|v| v ? 1 : 0}.join(" ")
		# end

		# it would have been faster to produce directly this one
		pathgraph=[]
		cmpmatrix.each_with_index do |rule, i|
			cn = []
			rule.each_with_index do |node, j|
				cn << j if node
			end
			pathgraph << cn
		end
		# pathgraph.each_with_index do |rule, i|
		# 	is=printf("%2d ", i)
		# 	puts rule.map{|v| printf("%3d", v)}.join(" ")
		# end
		# if there is a line with only one index we can
		# remove that index from all the other lines 
		# (something like beleif propagation)
		# if pathgraph.any? {|line| line.count==1}
		single_vals=[]
		while line = pathgraph.find {|l| l.count==1 and !single_vals.include?(l.first)}
			v = line.first
			single_vals << v
			pathgraph.each do |l|
				l.delete(v) unless l.count == 1
			end
		end
		# pathgraph.each_with_index do |rule, i|
		# 	is=printf("%2d ", i)
		# end
		# check if we are lucky!
		if !pathgraph.any?{|l| l.count > 1}
			value_index = pathgraph.map{|l| l.first}
			return value_index
		end
	end

	def sum_of_departure_values
		idx = find_rules_indexing
		prod = 1
		@rules.select{|r| r.name =~ /departure/}.each_with_index do |r, i|
			prod = prod * @myval[idx[i]]
		end
		prod
	end

end

test1="""\
class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12
"""
e = 71
td = TicketDecoder.new(test1)
r = td.scanning_error_rate()
raise "Test 1 failed: #{r} instead of #{e}" unless e == r


# Question 1: Consider the validity of the nearby tickets you scanned. 
#             What is your ticket scanning error rate?
td = TicketDecoder.new(File.read("input/16.txt"))
r = td.scanning_error_rate()
puts "Scanning error rate: #{r}"


test2="""\
class: 0-1 or 4-19
row: 0-5 or 8-19
seat: 0-13 or 16-19

your ticket:
11,12,13

nearby tickets:
3,9,18
15,1,5
5,14,9
"""
td = TicketDecoder.new(test2)
r = td.scanning_error_rate()

# Question 2: look for the six fields on your ticket that start with the word 
#           departure. What do you get if you multiply those six values together?
td = TicketDecoder.new(File.read("input/16.txt"))
r = td.sum_of_departure_values
puts "Product of the 6 departure values: #{r}"
