#!/usr/bin/env ruby
def log(s)
	puts s 
end

class Player
	attr_reader :id, :deck, :last
	def initialize(s)
		if s.class == String
			ll = s.lines.map{|l| l.chomp}
			m = /Player (\d+):/.match(ll.first)
			@id = m[1].to_i
			# @deck is a queue
			@deck = ll[1..].map{|l| l.to_i}
		else
			@id = s[:id]
			@deck = s[:deck]
		end
		@last = nil
	end
	def draw
		@last = @deck.shift
	end
	def collect(c)
		@deck +=  c.sort.reverse
	end
	def collect_ordered(c)
		@deck += c
	end
	def ncards
		@deck.count
	end
	def deck_s
		@deck.join(", ")
	end
	def score
		s = 0
		@deck.reverse.each_with_index {|c, i| s = s + c * (i+1)}
		s
	end
end

# I have used arrays instead of two vars because I bet that question two
# was about multiple players... I was wrong :-( 
class CombatGame
	attr_reader :round
	def initialize(s)
		ps = s.split("\n\n")
		@players = s.split("\n\n").map{|ss| Player.new(ss)}
		@round = 0
	end
	def play
		while (w = self.winner).nil?
			@round = @round + 1
			c = @players.map {|p| p.draw}
			iwin = c.compact.each_with_index.max[1]
			@players[iwin].collect(c)
		end
		return w
	end
	def gameover?
		@players.count {|p| p.ncards > 0} == 1
	end
	def winner
		if self.gameover?
			@players.find{|p| p.ncards > 0}
		else
			nil 
		end
	end
	def player(i)
		return @players[i]
	end
end


class RecursiveCombatGame
	attr_reader :round
	def self.gameid
		@gamecount ||= 0
		@gamecount = @gamecount + 1
		return @gamecount
	end

	def initialize(s)
		if s.class == String
			ps = s.split("\n\n")
			@players = s.split("\n\n").map{|ss| Player.new(ss)}
		else
			@players = s.map{|ss| Player.new(ss)}
		end
		@game = self.class.gameid
		@round = 0
	end

	def play
		@deckhistory = @players.map{|p| []}
		while (w = self.winner).nil?
			@round = @round + 1

			c = @players.map {|p| p.draw}
			if @players.all?{|p| p.last <= p.ncards }
				newg=[]
				@players.each_with_index do |p,i|
					newg << {
						id: i+1,
						deck: p.deck[0..p.last-1]
					}
				end
				rcg = RecursiveCombatGame.new(newg)
				rcg_winner = rcg.play
				winner = @players[ rcg_winner.id - 1 ]
				winner.collect_ordered([winner.last] + (c-[winner.last]))
			else
				winner = @players[c.compact.each_with_index.max[1]]
				winner.collect(c)
			end
		end
		return w
	end
	def winner
		# if there was a previous round in this game that had exactly the 
		# same cards in the same order in the same players' decks, the game 
		# instantly ends in a win for player 1
		@players.each_with_index.each do |p,i|
			return @players[0] if @deckhistory[i].include?(p.deck)
			@deckhistory[i] << p.deck.clone
		end
		if @players.count {|p| p.ncards > 0} == 1
			return @players.find{|p| p.ncards > 0}
		end
		nil 
	end

	def gameover?
		@players.count {|p| p.ncards > 0} == 1
	end




end

test1="""\
Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10
"""

sc = CombatGame.new(test1)
wp = sc.play
raise "Test 1 fails: winner expected to be player 2 but is #{wp.id}" unless wp.id == 2
raise "Test 1 fails: winner score expected to be 306 but is #{wp.score}" unless wp.score == 306

sc = RecursiveCombatGame.new(test1)
wp = sc.play
raise "Test 2 fails: winner expected to be player 2 but is #{wp.id}" unless wp.id == 2
raise "Test 2 fails: winner score expected to be 291 but is #{wp.score}" unless wp.score == 291

# Question 1: What is the winning player's score?
sc = CombatGame.new(File.read("input/22.txt"))
wp = sc.play
puts "Player #{wp.id} wins after #{sc.round} rounds with the score of #{wp.score}"


# Question 1: What is the winning player's score?
sc = RecursiveCombatGame.new(File.read("input/22.txt"))
wp = sc.play
puts "Player #{wp.id} wins after #{sc.round} rounds with the score of #{wp.score}"
