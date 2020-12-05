#!/usr/bin/env ruby

def validate_year(d, least, most)
	return false unless d=~/^[0-9]{4}$/
	v=d.to_i
	v>=least && v<=most
end

# birth year: at least 1920 and at most 2002
def validate_byr(d)
	validate_year(d, 1920, 2002)
end

# issue year: at least 2010 and at most 2020
def validate_iyr(d)
	validate_year(d, 2010, 2020)
end

# expiration year: at least 2020 and at most 2030
def validate_eyr(d)
	validate_year(d, 2020, 2030)
end

# height: at least 150cm/59in and at most 193cm/76in
def validate_hgt(d)
	m=/^([0-9]+)(cm|in)/.match(d)
	return false if m.nil?
	v=m[1].to_i
	m[2]=="cm" && v>=150 && v<=193 || m[2]=="in" && v>=59 && v<=76
end

# hair color: a # followed by exactly six characters 0-9 or a-f
def validate_hcl(d)
	d =~ /^#[0-9a-f]{6}$/
end

# eye color: exactly one of: amb blu brn gry grn hzl oth
def validate_ecl(d)
	d =~ /^(amb|blu|brn|gry|grn|hzl|oth)$/
end

# passport id: a nine-digit number, including leading zeroes.
def validate_pid(d)
	d =~ /^[0-9]{9}$/
end

# cid is optional
def validate_cid(d)
	true
end

# Question 2: records must also validate rules on values
# this assumes that passport were already validated by valid1 
def valid2(passport)
	passport.split(" ").each do |f|
	  k,v = f.split(":")
	  return false unless self.method("validate_#{k}").call(v)
	end
	return true
end

# Question 1: valid passport have all the following fields: 
#             byr ecl eyr hcl hgt iyr pid
def valid1(passport)
	fields=passport
	      .gsub(/:[^ ]*/, '')
	      .split(" ")
	      .delete_if{|f| f=="cid"}
	      .sort.join(" ")
	fields == "byr ecl eyr hcl hgt iyr pid"
end

def load_passports(s) 
	s.split(/^$/).map{|p| p.gsub("\n", " ").gsub(/^ /, "")}
end

def process_passports(passports)
	n_total = passports.count 

	valid_passports1 = passports.select{|p| valid1(p)}
	n_valid1 = valid_passports1.count
	puts "n_valid1: #{n_valid1} / #{n_total}"


	valid_passports2 = valid_passports1.select{|p| valid2(p)}
	n_valid2 = valid_passports2.count
	puts "n_valid2: #{n_valid2} / #{n_valid1}"
end

# ------------------------------------------------------------------------------

test_fields = [
	"byr invalid 20002",
	"byr invalid 02",
	"byr invalid xx2",
	"byr valid 2002",
	"byr invalid 2003",
	"hgt valid 60in",
	"hgt valid 190cm",
	"hgt invalid 190in",
	"hgt invalid 190",
	"hcl valid #123abc",
	"hcl invalid #123abz",
	"hcl invalid 123abc",
	"ecl valid brn",
	"ecl invalid wat",
	"pid valid 000000001",
	"pid invalid 0123456789",
]
puts "Test0: record validators. There should be no output."
test_fields.each do |l|
	k, r, d = l.split(" ")
	v = self.method("validate_#{k}").call(d) ? "valid" : "invalid"
	puts "#{k} = #{d} should be #{r} and results #{v}" unless v == r
end

test_invalid = """
eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023
pid:3556412378 byr:2007
"""

test_valid = """
pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
"""


puts "Test1: there should be 4+0 invalid passports"
process_passports(load_passports(test_invalid))

puts "Test2: there should be 4+4 valid passports"
process_passports(load_passports(test_valid))

puts "Ok. Now the real data"
process_passports(load_passports(File.read("input/04.txt")))







