#!/usr/bin/env ruby
require "set"

class Food
  attr_reader :ingredients, :allergenes
  def initialize(s)
  	i,a = s.gsub(/[,)(]/, '').split(" contains ")
  	@ingredients = i.split(' ')
  	@allergenes = a.split(' ')
  end
end

class AllergeneDetector
	attr_reader :foods, :all_ingredients, :all_allergenes
	def initialize(s)
		@foods = s.lines.map do |l|
			Food.new(l.chomp)
		end
		@all_ingredients = foods.inject([]){|s, f| s + f.ingredients}.uniq
		@all_allergenes  = foods.inject([]){|s, f| s + f.allergenes}.uniq
	end

	# for every allergene, list the intersection of the ingredients 
	# contained in all foods with that allergene. That is the list of 
	# ingredients that appear in all the foods with the given allergene
	def ingredients_by_allergene
		@iba ||= begin
			iba={}
			@foods.each do |f|
				f.allergenes.each do |a|
					if iba.key?(a)
						iba[a] = iba[a] & f.ingredients
					else
						iba[a] = f.ingredients
					end
				end
			end
			iba
		end
	end

	# list the ingredients that do not appear in any of the allergene list 
	def possible_allergene_free_ingredients
		@pafi ||= begin
			iba = ingredients_by_allergene
			@all_ingredients.filter do |i|
				iba.all? {|a,ii| !ii.include?(i)}
			end
		end
	end

	# since one allergene is contained in one and only one ingredient
	# we need to reduce @iba lists to a single ingredient
	def possible_dangerous_ingredients
		@pdi ||= begin
			iba = ingredients_by_allergene.to_a
			singles = []
			while singles.count < @all_allergenes.count
				iba.each do |a,il|
					if il.count == 1
						singles << il.first
					end
				end
				singles.uniq!
				iba.map! do |e|
					a,il=e
					il.count == 1 ? [a,il] : [a, il - singles]
				end
			end
			iba.sort {|a,b| a[0] <=> b[0]}.map{|a,il| il.first}
		end
	end

	def pafi_total_appearence_count
		pafi = self.possible_allergene_free_ingredients
		na = 0
		@foods.each do |f|
			pafi.each do |i|
				na = na + 1 if f.ingredients.include?(i)
			end
		end
		na
	end

end



test1="""\
mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
trh fvjkl sbzzf mxmxvkd (contains dairy)
sqjhc fvjkl (contains soy)
sqjhc mxmxvkd sbzzf (contains fish)
"""
#     *     *  *     *
#    kf mx nh    sq          D F
# fv    mx    sb    tr       D
# fv             sq              S
#       mx    sb sq            F

ad = AllergeneDetector.new(test1)
paf = ad.possible_allergene_free_ingredients
raise "Error in finding possibly allergene free ingredients: #{paf}" unless paf ==  ["kfcds", "nhms", "trh", "sbzzf"]
npaf = ad.pafi_total_appearence_count()
raise "Error counting how many time paf ingredients appear: #{npaf} instead of 5" unless npaf == 5

pdi = ad.possible_dangerous_ingredients.join(",")
raise "Error in dangerous ingredient list #{pdi}" unless pdi == "mxmxvkd,sqjhc,fvjkl"

# Question 1: Determine which ingredients cannot possibly contain any of the 
# allergens in your list. How many times do any of those ingredients appear?
ad = AllergeneDetector.new(File.read("input/21.txt"))
npaf = ad.pafi_total_appearence_count()
puts "Possibly allergene free ingredients appear #{npaf} times"

pdi = ad.possible_dangerous_ingredients.join(",")
puts "Canonical dangerous ingredient list: #{pdi}"