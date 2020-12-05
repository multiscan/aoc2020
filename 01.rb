#!/usr/bin/env ruby

# Question 1: find two numbers adding up to 2020 in the given list
aa=File.readlines("input/01.txt").map{|l| l.to_i}.sort
b=0
aa.each do |a|
	b = 2020 - a
	break if aa.include?(b)
end
a=2020-b
puts "a=#{a} b=#{b}"
puts "a+b = #{a+b}"
puts "a*b = #{a*b}"

# Question 2: find three numbers adding up to 2020 in the given list
a=0
b=0
c=0
found=false
i=0
while (!found)
	a=aa[i]
	j=i+1
	while(!found)
		b = aa[j]
		s = a + b
		break if s > 2020
		c = 2020 - s
		found = aa.include?(c)
		j = j + 1
	end
	i = i + 1
end
puts "a=#{a} b=#{b} c=#{c}"
puts "a+b+c = #{a+b+c}"
puts "a*b*c = #{a*b*c}"

