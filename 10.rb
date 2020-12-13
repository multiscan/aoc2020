#!/usr/bin/env ruby

class AdapterGraph
	attr_reader :ss, :ns, :dg
	def self.from_file(fn)
		s = File.read(fn).lines.map{|l| l.chomp.to_i }
		return self.new(s)
	end

	def initialize(s)
		@ss = [0] + s.sort
		@ss << @ss.last + 3
		@ns = @ss.count
		@dg = self.possible_connections_graph()
	end

	def possible_connections_graph()
		dg=Array.new(@ns)
		for i in 0..@ss.count-2
			vjmax = @ss[i] + 3
			dg[i] = [i+1]
			j = i+2
			while j<@ns and @ss[j] <= vjmax
				dg[i] = dg[i] << j
				j = j + 1
			end
		end
		dg[@ss.count-1] = []
		# dg.each_with_index do |edges, i|
		# 	s="#{i}:#{@ss[i]} -> "
		# 	edges.each {|j| s << "  #{j}:#{@ss[j]}"}
		# 	puts s
		# end
		dg
	end

	# This is counting all possible paths between two nodes
	def count_possible_chains(source=0, destination=@ns-1)
		@counts = Array(@ns).fill(nil)
		return recursive_count_possible_chains(source, destination)
	end

	def recursive_count_possible_chains (source, destination) 
		return 1 if source == destination
		return 0 if @dg[source].empty?
		@dg[source].inject(0){|c, s| c + (@counts[s] ||= recursive_count_possible_chains(s,destination))}
	end

	def all_chainable?
		v0=@ss.first
		@ss[1..].each do |v1|
			if v1-v0 > 3
				puts "#{v0} and #{v1} are not chaniable"
				return false
			end 
			v0 = v1
		end
		true
	end
	def chain_dv
		dvv = {}
		v0=@ss.first
		@ss[1..].each do |v1|
			dv=v1-v0
			dvv[dv] = (dvv[dv] || 0) + 1
			v0 = v1
		end
		dvv
	end
end

t1 = [16, 10, 15, 5, 1, 11, 7, 19, 6, 12, 4]

t2 = [
	28, 33, 18, 42, 31, 14, 46, 20, 48, 47, 24, 23, 49, 45, 19, 38,
	39, 11, 1, 32, 25, 35, 8, 17, 7, 9, 4, 2, 34, 10, 3
]

# Test with first test set
ag = AdapterGraph.new(t1)
raise "Test 1 not chainable" unless ag.all_chainable?
cdv = ag.chain_dv()
raise "Test 1: wrong chain_dv: #{cdv} " if cdv[1] != 7 or cdv[3] != 5
c = ag.count_possible_chains()
raise "Test 1: wrong number of possible chains: #{c} instead of 8" unless c == 8


# exit
# raise "Wrong prod13 for test 1: expected #{}"
# puts "chain_dv(t1) = #{ag.chain_dv()}"

# exit

# Test with second test set
ag = AdapterGraph.new(t2)
raise "Test 2 not chainable" unless ag.all_chainable?
cdv = ag.chain_dv()
raise "Test 2: wrong chain_dv: #{cdv} " if cdv[1] != 22 or cdv[3] != 10
c = ag.count_possible_chains()
raise "Test 1: wrong number of possible chains: #{c} instead of 8" unless c == 19208


# Question 1: 
# Find a chain that uses all of your adapters to connect the charging outlet 
# to your device's built-in adapter and count the joltage differences between 
# the charging outlet, the adapters, and your device. 
# What is the number of 1-jolt dv multiplied by the number of 3-jolt dv ?
ag = AdapterGraph.from_file("input/10.txt")
rs = ag.all_chainable? ? "yes" : "no"
puts "Real adapters are chainable ? #{rs}"
cdv = ag.chain_dv()
puts "chain_dv = #{cdv}"
prod13 = cdv[1] * cdv[3]
puts "n. of dv[1] * n. of dv[3] = #{prod13}"

# Question 2:
# What is the total number of distinct ways you can arrange the adapters to
# connect the charging outlet to your device?
c = ag.count_possible_chains()
puts "Number of possible arrangements is #{c}"