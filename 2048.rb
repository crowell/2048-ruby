#! /usr/bin/env ruby
require 'io/console'
require 'colorize'

@board = [[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]] # 4x4 array of board

def color_num num
	snum = '%4.4s' % num
	retnum = ""
	case num
	when 0
		retnum = "    "
	when 2
		retnum = snum.red	
	when 4
		retnum = snum.light_red
	when 8
		retnum = snum.yellow
	when 16
		retnum = snum.green
	when 32
		retnum = snum.light_green
	when 64
		retnum = snum.light_cyan
	when 128
		retnum = snum.cyan
	when 256
		retnum = snum.blue
	when 512
		retnum = snum.light_blue
	when 1024
		retnum = snum.light_magenta
	when 2048
		retnum = snum.magenta
	else
		abort "error"
	end
	return retnum.underline
end

def check_win
	return @board.flatten.max == 2048
end

def print_board
	puts " ___________________"
	(0..3).each{|ii|
		print '|'
		(0..3).each{|jj|
			n = @board[ii][jj]
			print color_num n
			print '|'
		}
		puts ""
	}
	puts ""
end

def new_piece
	piece = rand(1..2) * 2 # generate either 2 or 4
	xx = rand(0..3)
	yy = rand(0..3)
	(0..3).each{|ii|
		(0..3).each{|jj|
			x1 = (xx + ii) % 4
			y1 = (yy + jj) % 4
			if @board[x1][y1] == 0
				@board[x1][y1] = piece
				return true
			end
		}
	}
	return false
end

def get_input
	input = ''
	dirs = ['w', 'a', 's', 'd']
	while not dirs.include?(input) do
		input = STDIN.getch 
		if input == "\e" 
			abort "escaped" 
		end 
	end 
	return input 
end 

def shift_left line
	l2 = Array.new
	line.each{|ii|
		if not ii == 0
			l2.push ii
		end
	}
	while not l2.size == 4
		l2.push 0
	end
	return l2
end

def move_left
	tempBoard = Marshal.load(Marshal.dump(@board))
	(0..3).each{|ii| 
		(0..3).each{|jj| 
			(jj..2).each{|kk| 
				if @board[ii][kk + 1] == 0 
					next
				elsif @board[ii][jj] == @board[ii][kk + 1]
					@board[ii][jj] = @board[ii][jj] * 2
					@board[ii][kk + 1] = 0
				end
				break
			}
		}
		@board[ii] = shift_left @board[ii]
	}
	if @board == tempBoard
		return false
	else
		return true
	end
end

def move_right
	@board.each{|a|a.reverse!}
	work = move_left
	@board.each{|a|a.reverse!}
	return work
end

def move_down
	@board = @board.transpose.map &:reverse
	work = move_left
	@board = @board.transpose.map &:reverse
	@board = @board.transpose.map &:reverse
	@board = @board.transpose.map &:reverse
	return work
end

def move_up
	@board = @board.transpose.map &:reverse
	@board = @board.transpose.map &:reverse
	@board = @board.transpose.map &:reverse
	work = move_left
	@board = @board.transpose.map &:reverse
	return work
end

def check_lose
	tempBoard = Marshal.load(Marshal.dump(@board))
	t = move_right
	if t == false
		t = move_left
		if t == false
			t = move_up
			if t == false
				t = move_down
				if t == false
					@board = Marshal.load(Marshal.dump(tempBoard))
					return true
				end
			end
		end
	end
	@board = Marshal.load(Marshal.dump(tempBoard))
	return false
end

puts "move with wasd"
2.times{
	new_piece
}
print_board
win = true
while not check_win do
	dir = get_input
	#do movement
	case dir
	when 'a'
		work = move_left
	when 'd'
		work = move_right
	when 's'
		work = move_down
	when 'w'
		work = move_up
	end
	if work	== true
		new_piece
	end
	system("clear")
	print_board
	if check_lose
		win = false
		break
	end
end

if win
	puts "*<:-) WINNER!"
else
	puts ":-( maybe next time"
end
