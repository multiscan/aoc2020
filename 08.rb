#!/usr/bin/env ruby

class Program
	attr_reader :acc
	def initialize(src)
		lre = /^(nop|acc|jmp) ([-+][0-9]+)$/
		@acc = 0
		@prg = src.lines().map do |l|
			m = lre.match(l)
		end.compact.map { |m| {i: m[1], s: m[2].to_i, v: false} }
		@nl = @prg.count
	end

	def run
		pc=0
		@acc=0
		unseen=Array.new(@nl+1).fill(true)
		while(pc<@nl && unseen[pc])
			unseen[pc] = false
			l = @prg[pc]
			case l[:i]
			when "nop"
				pc = pc + 1
			when "acc"
				@acc = @acc + l[:s]
				pc = pc + 1
			when "jmp"
				pc = pc + l[:s]
			end
		end
		return pc == @nl
	end

	def nop_jmp_exchange_debug
		ids = @prg.each_index.select{|i| @prg[i][:i] == 'nop'}
		ids.each do |i|
			@prg[i][:i] = 'jmp'
			if run
				puts "Debugged program by replacing nop with jmp at line #{i+1}"
				return true
			else
				@prg[i][:i] = 'nop'
			end
		end

		ids = @prg.each_index.select{|i| @prg[i][:i] == 'jmp'}
		ids.each do |i|
			@prg[i][:i] = 'nop'
			if run
				puts "Debugged program by replacing jmp with nop at line #{i+1}"
				return true
			else
				@prg[i][:i] = 'jmp'
			end
		end
		return false
	end
end

test_p1 = """
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
"""

p = Program.new(test_p1)
if p.run
	raise "Program expected to fail"
else
	e = 5
	unless p.acc == e 
		raise "Incorrect accumulator value before infinite loop {p.acc} instead of #{e}" 
	end
end

if p.nop_jmp_exchange_debug()
	e = 8
	unless p.acc == e
		raise "Incorrect accumulator value at program end #{p.acc} instead of #{e}" 
	end
else
	raise "Program could not be debugged"
end

# Question 1: Immediately before any instruction is executed a second time, what value is in the accumulator?
p = Program.new(File.read("input/08.txt"))
if p.run
	raise "Program expected to fail"
else
	puts "Accumulator before infinite loop: #{p.acc}"
end

# Question 2: replacing a jmp with a nop or viceversa will make the program run till the end
if p.nop_jmp_exchange_debug()
	puts "Accumulator after debugged program finish: #{p.acc}"
end