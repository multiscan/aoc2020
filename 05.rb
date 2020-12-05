#!/usr/bin/env ruby

class Seat
	attr_reader :s, :r, :c
	def initialize(s)
		@s = s
		raise "Invalid seat string #{s}" unless s =~ /^[FB]{7}[LR]{3}$/
		@r = s[0..6].gsub("F", "0").gsub("B", "1").to_i(2)
		@c = s[7..9].gsub("L", "0").gsub("R", "1").to_i(2)
	end
	def sid
		@sid ||= 8 * @r + @c
	end
end

def string_to_sid(s)
	string_to_seat(s)[2]
end

t1 = [
	"FBFBBFFRLR", 44, 5, 357,
    "BFFFBBFRRR", 70, 7, 567,
    "FFFBBBFRRR", 14, 7, 119,
    "BBFFBBFRLL", 102, 4, 820,
].each_slice(4).to_a

t1.each do |e|
	s = Seat.new(e.shift)
	r = [s.r, s.c, s.sid]
	unless r == e
		rs = r.join(", ")
		es = e.join(", ")
		puts "error: expecting #{es} received #{rs}"
		exit
	end
end

ss = File.readlines("input/05.txt").map{|l| l.chomp}
puts "There are #{ss.count} seat strings"

seats = ss.map{|s| Seat.new(s)}.sort{|a,b| a.sid <=> b.sid}

# Question 1: What is the highest seat ID on a boarding pass?
ls = seats.last
puts "The highest seat ID is #{ls.sid}"

# Question 2: Your seat wasn't at the very front or back, though; 
#             the seats with IDs +1 and -1 from yours will be in your list. 

# skip the front row
first_row = seats.first.r
i=0
while seats[i].r == first_row
	i = i + 1
end

lid = seats[i].sid + 1
i=i+1
while((nid=seats[i].sid)==lid)
  lid=nid+1
  i=i+1
end
puts "My seat ID is #{lid}" 
