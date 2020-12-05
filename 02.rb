#!/usr/bin/env ruby

class PasswordLine
	attr_reader :l, :a, :b, :c, :p
	def initialize(line)
		@l = line
		as, bs, @c, @p = line.chomp.split(/[ :-]+/)
		@a = as.to_i
		@b = bs.to_i
	end

# Question 1: only password that contains the given letter a number of time 
#             in the range are valid. Count the number of valid passwords
	def valid1?
		n = @p.count(@c)
		a <= n && n <= b
	end

	def valid2?
		pa = @p[@a - 1]
		pb = @p[@b - 1]
		(pa == @c) ^ (pb == @c)
	end
end

def b2v(b)
	b ? "valid" : "invalid"
end

t1 = [
  "1-3 a: abcde", true,
  "1-3 b: cdefg", false,
  "2-9 c: ccccccccc", true,
].each_slice(2) do |t|
	l, e = t
	pl = PasswordLine.new(l)
	unless r=pl.valid1? == e
		puts "Error: password line #{l} should be #{b2v(e)} but was evaluated as #{b2v(r)}"
		exit
	end
end

t2 = [
  "1-3 a: abcde", true,
  "1-3 b: cdefg", false,
  "2-9 c: ccccccccc", false,
].each_slice(2) do |t|
	l, e = t
	pl = PasswordLine.new(l)
	unless r=pl.valid2? == e
		puts "Error: password line #{l} should be #{b2v(e)} but was evaluated as #{b2v(r)}"
		exit
	end
end
	
ll=File.readlines("input/02.txt").map{|l| PasswordLine.new(l)}

# Question 1: only password that contains the given letter a number of time 
#             in the range are valid. Count the number of valid passwords
nv=ll.map{|l| l.valid1? }.count(true)
puts "Number of valid passwords for Policy 1 is #{nv}"

# Question 2: only passwords that contain exactly 1 time the given letter in 
#             one of the given positions is valid. Count the number of valid p.
nv=ll.map{|l| l.valid2? }.count(true)
puts "Number of valid passwords for Policy 2 is #{nv}"
