#!/usr/bin/env ruby

class Code
	def initialize(txt,wlen)
		@wlen = wlen
		@msg  = txt.lines.map{|l| l.chomp.to_i}
	end
	def is_sum_of_any2(n, a)
		sums = a.map{|i| a.map{|j| i + j}}.flatten.sort
		sums.include?(n)
	end

	# TODO: this is really the slowest possible solution. We should leverage
	# the fact that most of the sums are already known
	def first_invalid
		i = @wlen
		while i<@msg.count
			m = @msg[i]
			return m unless is_sum_of_any2(m, @msg[i-@wlen..i-1])
			i = i + 1
		end
		nil
	end

	def contiguous_that_add_to(n)
		j=0
		i=1
		s=@msg[i]+@msg[j]
		while s!=n && i<@msg.count && j<i
			if s<n
				i = i + 1
				s = s + @msg[i]
			else
				s = s - @msg[j]
				j = j + 1
			end
		end
		if s==n
			@msg[j..i]
		else
			nil
		end
	end

end

tcode="""\
35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576
"""
c = Code.new(tcode, 5)
n = c.first_invalid()
raise "Wrong first_invalid: #{n} instead of 127" unless n == 127 

cc = c.contiguous_that_add_to(n).sort
s = cc[0] + cc[-1]
raise "Wrong contiguous_that_add_to: #{s} instead of 62" unless s == 62

# Question 1:
# find the first number in the list (after the preamble) which is 
# not the sum of two of the 25 numbers before it. 
# What is the first number that does not have this property?
c = Code.new(File.read("input/09.txt"), 25)
n = c.first_invalid()
puts "First invalid is #{n}"

# Question 2:
# In this list, adding up all of the numbers from 15 through 40 produces the 
# invalid number from step 1, 127. (Of course, the contiguous set of numbers 
# in your actual list might be much longer.)
# To find the encryption weakness, add together the smallest and largest number 
# in this contiguous range; in this example, these are 15 and 47, producing 62.
# What is the encryption weakness in your XMAS-encrypted list of numbers?

cc = c.contiguous_that_add_to(n).sort
s = cc[0] + cc[-1]
puts "the encryption weakness is #{s}"
