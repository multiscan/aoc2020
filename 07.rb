#!/usr/bin/env ruby

class BagRule
	attr_reader :color, :content
	RE0=/(\w+ \w+) bags contain( no other bags.|( (\d+) (\w+ \w+) bags?[.,])+)$/
	RE1=/^ (\d+) (\w+ \w+) /

	def initialize(l)
		m0 = RE0.match(l)
		raise "cannot match rule line #{l}" if m0.nil?
		@color = m0[1]
		if m0[2] == " no other bags."
			@content = {}
		else
			@content = m0[2].chop.split(",").map do |p|
				m1 = RE1.match(p)
				[m1[2], m1[1].to_i]
			end.to_h
		end
	end

	def content_colors
		@content.keys
	end

	def empty?
		@content.empty?
	end

	def can_contain?(c)
		@content.key?(c)
	end 
end

class BagsRulesGraph
	attr_reader :colors
	def initialize(s)
		@graph = {}
		s.lines.each do |l|
			r = BagRule.new(l)
			@graph[r.color] = r
		end
		@colors = @graph.keys
	end

	# Depth First Search
	def contains?(container_color, content_color)
		stack = [container_color]

		loop do
		    curr = stack.pop
		    return false if curr == nil
		    return true if curr == content_color
		    @graph[curr].content_colors.each do |c|
		    	stack = stack << c
		    end
		end
	end

	def who_contains?(target_color)
		clist=[]
		@graph.keys.each{|c| clist << c if c!=target_color and self.contains?(c, target_color)}
		clist
	end

	def deep_count_content(mycolor)
		b = @graph[mycolor]
		return 0 if b.empty?
		b.content.to_a.inject(0) do |sum, c|
			sum + c[1] * (1+self.deep_count_content(c[0]))
		end
	end
end

# [color 0 modifier] [color 0] bags contain [amount 1] [color 1 modifier] [color 1], [amount 2] [color 2 modifier] [color 2] bags.
t1="""light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.
dark red bags contain 3 muted yellow bags, 1 faded blue bags, 6 dotted black bags.
"""

b=BagRule.new "dark orange bags contain 3 bright white bags, 4 muted yellow bags."
b.can_contain?("bright white") or raise "b should contain bright white"
b.can_contain?("vibrant plum") and raise "b should not contain vibrant plum"

b=BagRule.new "dotted black bags contain no other bags."
b.empty? or raise "b should be empty"

r=BagsRulesGraph.new(t1)
[
	"light red", "shiny gold", true,
	"light red", "dark olive", true,
	"muted yellow", "dark orange", false,
	"dotted black", "dark orange", false
].each_slice(3) do |s|
	r.contains?(s[0], s[1]) == s[2] or raise "#{s[0]} should #{s[2] ? '' : 'NOT '}contain #{s[1]}"
end

[
	'light red', [],
	'bright white', ['dark orange', 'light red'],
	'faded blue', ["bright white", "dark olive", "dark orange", "dark red", "light red", "muted yellow", "shiny gold", "vibrant plum"],
].each_slice(2) do |s|
	r.who_contains?(s[0]).sort == s[1] or raise "Failed contains? test for #{s[0]}"
end


t2="""shiny gold bags contain 2 dark red bags.
dark red bags contain 2 dark orange bags.
dark orange bags contain 2 dark yellow bags.
dark yellow bags contain 2 dark green bags.
dark green bags contain 2 dark blue bags.
dark blue bags contain 2 dark violet bags.
dark violet bags contain no other bags.
"""
r=BagsRulesGraph.new(t2)

[
	'dark violet', 0,
	'dark blue', 2,
	'shiny gold', 126,	
].each_slice(2) do |s|
	c = r.deep_count_content(s[0])
	c == s[1] or raise "#{s[0]} must contain #{s[1]} bags. We get #{c}."
end

# ------------------------------------------------------------------------------

# Question 1: How many bag colors can eventually contain at least one shiny gold bag? 
r = BagsRulesGraph.new(File.read('input/07.txt'))
r.colors.count == 594 or raise "Unexpected number of colors from input file"
r.colors.sort.uniq.count == 594 or raise "There must be repeated colors. This is unexpected!"
a1 = r.who_contains?("shiny gold")
puts "#{a1.count} bags can contain a shiny gold one"

# Question 2: How many individual bags are required inside your single shiny gold bag?
a2 = r.deep_count_content("shiny gold")
puts "A shiny gold bag must contain #{a2} other bags"
