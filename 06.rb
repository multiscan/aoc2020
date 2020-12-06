#!/usr/bin/env ruby

def groups(s)
	s.split("\n\n")
end

def any_yes(g)
	g.gsub("\n", "").split("").uniq.count
end

def all_yes(g)
	ind_ans = g.lines.map{|l| l.chomp.split("")}
	ind_ans.inject(ind_ans.first) {|intsec, ia| intsec & ia}.count
end

t = """abc

a
b
c

ab
ac

a
a
a
a

b
"""
et = [3, 3, 3, 1, 1]
rt = groups(t).map{|g| any_yes(g)}
unless et == rt
	puts "Test 1 failed. Expected #{et.join(', ')} returned #{rt.join(', ')}"
	exit
end

et = [3, 0, 1, 1, 1]
rt = groups(t).map{|g| all_yes(g)}
unless et == rt
	puts "Test 2 failed. Expected #{et.join(', ')} returned #{rt.join(', ')}"
	exit
end

gg = groups(File.read("input/06.txt"))

# Question 1: For each group, count the number of questions to which anyone 
#             answered "yes". What is the sum of those counts?
cc = gg.map{|g| any_yes(g)}
sum = cc.inject(0){|sum, c| sum+c}
puts "Sum of any yes counts: #{sum}"

# Question 2: For each group, count the number of questions to which everyone 
#             answered "yes". What is the sum of those counts?
cc = gg.map{|g| all_yes(g)}
sum = cc.inject(0){|sum, c| sum+c}
puts "Sum of all yes counts: #{sum}"
