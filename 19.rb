#!/usr/bin/env ruby

class RuleSet
	def initialize(s, overrides={})
		@r={}
		s.lines.each do |l|
		   i, rr = l.chomp.split(": ", 2)
		   @r[i] = rr.gsub(/"([a-z]+)"/, '\1')
		end
	    @r.merge!(overrides)
		cont = true
		while cont
			cont = false
			@r.each do |k, rr|
				rr.gsub!(/\d+/) do |i| 
					cont = true
					"(#{@r[i]})"
				end
			end
		end
		@r.each {|k,rr| rr.gsub!(/ +/, '')}
	end
	def match(s, i="0")
		Regexp.new("^#{@r[i]}$").match(s)
	end

	def to_s(title=nil)
		s=title ? "#{title}:\n" : ""
		@r.each do |k,v|
			s << "#{k}: #{v}\n"
		end
		s
	end
end


test1="""\
0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: \"a\"
5: \"b\"

ababbb 1
bababa 0
abbbab 1
aaabbb 0
aaaabbb 0
"""
rules, messages = test1.split("\n\n")
rs = RuleSet.new(rules)
nm = messages.lines.map{|l| l.chomp}.each do |l|
	m, e = l.split(" ")
	r = rs.match(m) ? 1 : 0
	# puts "#{l} -> #{r}"
	raise "Test 1 for #{m} fails: #{r} instead of #{e}" unless r == e.to_i
end



test2="""\
42: 9 14 | 10 1
9: 14 27 | 1 26
10: 23 14 | 28 1
1: \"a\"
11: 42 31
5: 1 14 | 15 1
19: 14 1 | 14 14
12: 24 14 | 19 1
16: 15 1 | 14 14
31: 14 17 | 1 13
6: 14 14 | 1 14
2: 1 24 | 14 4
0: 8 11
13: 14 3 | 1 12
15: 1 | 14
17: 14 2 | 1 7
23: 25 1 | 22 14
28: 16 1
4: 1 1
20: 14 14 | 1 15
3: 5 14 | 16 1
27: 1 6 | 14 18
14: \"b\"
21: 14 1 | 1 14
25: 1 1 | 1 14
22: 14 14
8: 42
26: 14 22 | 1 20
18: 15 15
7: 14 5 | 1 21
24: 14 1

abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
bbabbbbaabaabba
babbbbaabbbbbabbbbbbaabaaabaaa
aaabbbbbbaaaabaababaabababbabaaabbababababaaa
bbbbbbbaaaabbbbaaabbabaaa
bbbababbbbaaaaaaaabbababaaababaabab
ababaaaaaabaaab
ababaaaaabbbaba
baabbaaaabbaaaababbaababb
abbbbabbbbaaaababbbbbbaaaababb
aaaaabbaabaaaaababaa
aaaabbaaaabbaaa
aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
babaaabbbaaabaababbaabababaaab
aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba

bbabbbbaabaabba
ababaaaaaabaaab
ababaaaaabbbaba

bbabbbbaabaabba
babbbbaabbbbbabbbbbbaabaaabaaa
aaabbbbbbaaaabaababaabababbabaaabbababababaaa
bbbbbbbaaaabbbbaaabbabaaa
bbbababbbbaaaaaaaabbababaaababaabab
ababaaaaaabaaab
ababaaaaabbbaba
baabbaaaabbaaaababbaababb
abbbbabbbbaaaababbbbbbaaaababb
aaaaabbaabaaaaababaa
aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba
"""
rules, messages, ok1, ok2 = test2.split("\n\n")
messages = messages.lines.map{|l| l.chomp}
ok1 = ok1.lines.map{|l| l.chomp}
ok2 = ok2.lines.map{|l| l.chomp}

rs = RuleSet.new(rules)
messages.each do |m|
	e = ok1.include?(m) ? 1 : 0
	r = rs.match(m) ? 1 : 0
	raise "Test 2.1 for #{m} fails: #{r} instead of #{e}" unless r == e
end

# Note that this test pass but replacement for 11 is not correct
rs = RuleSet.new(rules, {"8" => "(42)+", "11" => "(42)+(31)+"})
messages.each do |m|
	e = ok2.include?(m) ? 1 : 0
	r = rs.match(m) ? 1 : 0
	raise "Test 2.2 for #{m} fails: #{r} instead of #{e}" unless r == e
end

# Question 1: How many messages completely match rule 0 ?
rules, messages = File.read("input/19.txt").split("\n\n")
rs = RuleSet.new(rules)
messages = messages.lines.map{|l| l.chomp}
nm = messages.map{|m| rs.match(m) ? true : false}.count(true)
puts "There are #{nm}/#{messages.count} messages matching rule 0"

# Question 2: After updating rules 8 and 11, 
#             how many messages completely match rule 0?
# Update is 
#   8: 42 | 42 8
#   11: 42 31 | 42 11 31

# The following one (returning 312) fails because rule 11 is more stringent
# than "(42)+(31)+" because 42 ad 31 have tobe repeated the SAME number of times
rs = RuleSet.new(rules, {"8" => "(42)+", "11" => "(42)+(31)+"})
nm = messages.map{|m| rs.match(m) ? true : false}.count(true)
puts "There are #{nm}/#{messages.count} messages matching rule 0 after the update"

# There is for sure a better way but this one works ;) 
# To be sure I have added more (42 31)? than needed. How many are needed can be
# determined by adding until the number of matches stops increasing 
rs = RuleSet.new(rules, {"8" => "(42)+", "11" => "(42)(42 (42 (42 (42 (42 (42 31)? 31)? 31)? 31)? 31)? 31)?(31)"})
nm = messages.map{|m| rs.match(m) ? true : false}.count(true)
puts "There are #{nm}/#{messages.count} messages matching rule 0 after the update"
