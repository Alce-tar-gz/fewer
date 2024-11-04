#!/usr/bin/env ruby

require 'io/console'

def hide_cursor
  print "\e[?25l" # Hide the cursor
end

def highlight_full_width(text)
  terminal_width = `tput cols`.to_i # Get the terminal width
  highlighted_text = "\e[47m\e[30m#{text.center(terminal_width)}\e[0m" # Black text on white background

  puts highlighted_text
end

def clear_screen
  system('clear') || system('cls')
end

def display_lines(lines, start_index, num_lines, filename)
  clear_screen
  highlight_full_width("#{filename}") # Display the filename as header

  # Calculate the end index
  end_index = [start_index + num_lines - 1, lines.size - 1].min

  # Print the lines in the specified range with line numbers
  (start_index..end_index).each do |i|
    line_number = format('%2d', i + 1) # Format line number with leading space for single digits
    gray_line_number = "\e[90m#{line_number}\e[0m" # Gray color for line numbers
    puts "#{gray_line_number} #{lines[i]}"
  end
end

def main
  if ARGV.empty?
    puts "Usage: fewer/few <filename>"
    exit
  end
  
  filename = ARGV[0]
  
  lines = []
  begin
    lines = File.readlines(filename)
  rescue Errno::ENOENT
    puts "Error: File not found."
    exit
  end
  
  hide_cursor

  start_index = 0
  num_lines = IO.console.winsize[0] - 2 # Number of lines that can fit in the terminal

  loop do
    display_lines(lines, start_index, num_lines, filename)
    
    input = STDIN.getch.upcase
    
    case input
    when 'Q'
      break
    when 'J' # Scroll down
      start_index += 1 unless start_index >= lines.size - num_lines
    when 'K' # Scroll up
      start_index -= 1 unless start_index <= 0
    end
  end
end

main if __FILE__ == $PROGRAM_NAME

