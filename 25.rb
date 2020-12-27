#!/usr/bin/env ruby
# t(n,LS): m=1 ; LS.times m <- m * n % 20201227
# C: PKc = t(7,LSc)
# D: PKd = t(7,LSd)
# LSc is the loop secret for the card which is CONSTANT
# LSd is the loop secret for the door which changes at each transform
#
# C -> D   PKc
# D -> C   PKd
# C: ECc = t(PKd,LSc)
# D: ECd = t(PKc,LSd)
# EC = ECc = ECd

def transform(s,ls)
	m = 1
	ls.times do 
		m = (m * s) % 20201227
	end
	m
end

def loop_size(pk, s=7)
	t = 1
	ls = 0
	while t != pk
		t = (t * s) % 20201227
		ls = ls + 1
	end
	ls
end

[
	17807724, 11,
	5764801, 8	
].each_slice(2) do |pk, els|
	ls = loop_size(pk)
	raise "Wrong loop size for pk=#{pk}: #{ls} instead of #{els}" unless ls == els
end
eek = 14897079
[
	17807724, 8,
	5764801, 11	
].each_slice(2) do |pk, ls|
	ek = transform(pk, ls)
	raise "Wrong encryption key #{ek} instead of #{eek}" unless ek == eek
end



# Question 1: What encryption key is the handshake trying to establish?
pks=[8252394, 6269621]
lss=pks.map{|pk| loop_size(pk)}
ek = transform(pks.first, lss.last)
puts "The encryption key is #{ek}"
