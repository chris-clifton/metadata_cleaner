class OutputHelper

  def test_message
    p "=> Test message from output helper"
  end

  def welcome_message
    puts "Welcome to Movie Metadata Cleaning Utility"
    puts "=> Press 'Enter' to continue..."
    gets.chomp
  end

  def run_antivirus
    puts "=> Running clamscan anti-virus..."
  end

  def display_directory_detail

  end


  # Clear all output from screen
  def clear
    system('clear') || system('cls')
  end
end