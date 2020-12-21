#!/usr/bin/env ruby

def compute1(s)
	res = 0
	op = "+"
	t = s.gsub(' ', '').split('')
	i=0
	while i<t.count
		v = t[i]
		case v
		when /[0-9]/
			res = eval("#{res} #{op} #{v}")
		when /[+*]/
			op = v
		when "("
			pc = 1
			se = ""
			while pc > 0 #  && i<t.count
				i = i + 1
				w = t[i]
				if w == ")"
					pc = pc - 1
					se << w if pc > 0
				else
					se << w
					pc = pc + 1 if w == "("
				end
			end
			ser = compute1(se)
			res = eval("#{res} #{op} #{ser}")
		end
		i = i + 1
	end
	return res
end

test1 = [
	"1 + 2 * 3 + 4 * 5 + 6", 71,
	"1 + (2 * 3) + (4 * (5 + 6))", 51,
	"2 * 3 + (4 * 5)", 26,
	"5 + (8 * 3 + 9 + 3 * 4 * 3)", 437,
	"5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))", 12240,
	"((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2", 13632,
].each_slice(2) do |s, e|
	r = compute1(s) 
	raise "Test fail: #{s} -> #{r} / #{e}" unless e == r
end



GROUPSE=/\(([\d +*]+)\)/
ADDSE=/\d+\s?\+\s?\d+/
def compute2(s)
	ss = s.clone
	while m = GROUPSE.match(ss)
		rr = compute2(m[1])
		ss = ss.sub(m[0], rr.to_s)
	end
	while m = ADDSE.match(ss)
		ss = ss.sub(m[0], eval(m[0]).to_s)
	end
	eval(ss)
end

test2 = [
	"1 + 2 * 3 + 4 * 5 + 6", 231,
	"1 + (2 * 3) + (4 * (5 + 6))", 51,
	"2 * 3 + (4 * 5)", 46,
	"5 + (8 * 3 + 9 + 3 * 4 * 3)", 1445,
	"5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))", 669060,
	"((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2", 23340,
].each_slice(2) do |s, e|
	r = compute2(s) 
	raise "Test fail: #{s} -> #{r} / #{e}" unless e == r
end

# Question 1: Evaluate the expression on each line of the homework; 
#             What is the sum of the resulting values?
sum = File.read("input/18.txt").lines.inject(0) do |s,l|
	s = s + compute1(l.chomp) 
end
puts "Sum of resulting values of all lines: #{sum}"



# Question 2: What do you get if you add up the results of evaluating the 
#             homework problems using these new rules?
sum = File.read("input/18.txt").lines.inject(0) do |s,l|
	s = s + compute2(l.chomp) 
end
puts "Sum of resulting values of all lines with new rules: #{sum}"

