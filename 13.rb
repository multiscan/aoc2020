#!/usr/bin/env ruby

class BusSchedule
	def initialize(s)
		ll = s.lines
		@t0 = ll[0].to_i
		@bus = ll[1].split(",").select{|v| v!="x"}.map{|v| v.to_i}
		@buswi = ll[1].split(",").each_with_index.select{|v,i| v!="x"}.map{|v,i| [v.to_i, i]}.to_a
	end

	def first_bus
		bus_next_pass = @bus.map{|t| t*(@t0/t) + t}
		first_bus_at, first_bus_id = bus_next_pass.each_with_index.min
		first_bus_number = @bus[first_bus_id]
		{
			now: @t0,
			first_bus_at: first_bus_at,
			wait_time: first_bus_at - @t0,
			bus_number: first_bus_number,
			bus_x_wait: first_bus_number * (first_bus_at - @t0)
		}
	end

	def magic_alignement_slow()
		first_bus_period = @buswi[0][0]
		other_bus = @buswi[1..]
		t=0
		loop do 
			t = t + first_bus_period
			ok = true
			other_bus.each do |p,i|
				ok = ok && ( (t+i)%p == 0 )
				break unless ok
			end
			break if ok
		end
		t
	end

	def magic_alignement1()
		magic_alignement0(@buswi[0][0], @buswi[1..])
	end


	# once t = n * b0 = m * b1 - i1 we need to add to t a multiple of b0
	#      t + x * b0 = m * b1 + l * b1 - i1  
	#      the smallest x  | x * b0 = l * b1 
	#      is the one for which x * b0 is the lcm(b0, b1)  
	def magic_alignement()
		dt = @buswi[0][0]
		okb = [@buswi[0]]

		remb = @buswi[1..].clone
		t=0
		loop do 
			t = t + dt
			okb=[]
			remb.each do |p,i|
				if (t+i)%p == 0
					dt = dt.lcm(p)
					okb << [p,i]
				end
			end
			remb = remb - okb
			break if remb.empty?
		end
		t
	end

end

test1 = """\
939
7,13,x,x,59,x,31,19\
"""
bs = BusSchedule.new(test1)
r  = bs.first_bus()[:bus_x_wait]
raise "Test 1 failed. #{f}." unless r == 295

ma_tests = [
    "17,x,13,19", 3417,
    "67,7,59,61", 754018,
    "67,x,7,59,61", 779210,
    "67,7,x,59,61", 1261476,
    "1789,37,47,1889", 1202161486,
].each_slice(2) do |l|
	t, e = l
	bs = BusSchedule.new("0\n#{t}")
	r = bs.magic_alignement_slow()
	raise "Test 2 failed (slow). Got #{r} instead of #{e}" unless r == e
	r = bs.magic_alignement()
	raise "Test 2 failed. Got #{r} instead of #{e}" unless r == e
end


# Question 1: What is the ID of the earliest bus you can take to the airport 
#             multiplied by the number of minutes you'll need to wait for 
#             that bus?
bs = BusSchedule.new(File.read("input/13.txt"))
r  = bs.first_bus()[:bus_x_wait]
puts "Question 1 answer: #{r}"

# Question 2: What is the earliest timestamp such that all of the listed bus IDs 
#             depart at offsets matching their positions in the list?
# That is for which n the following is valid
# t=n * bus[0] && (t+i)%bus[i]==0 foreach i where bus[i]!="x"
# but i must be the index or the original list that was including "x"
bs = BusSchedule.new(File.read("input/13.txt"))
t = bs.magic_alignement()
puts "Magick alignement happens at #{t}"

