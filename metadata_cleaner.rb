require 'pry'

class MetadataCleaner

  def initialize
    welcome_message
  end

  def start
    flatten_directory
    set_destination_directory
    clean_mkv_files
    clean_mp4_files
    find_and_move_remaining_video_files
  end

  def get_files(filetype)
    Dir.glob("#{filetype}")
  end

  # Flatten directory so everything is out of folder structure
  def flatten_directory
    current_dir = Dir.pwd
    system("mv #{current_dir}/*/**/*(.D) #{current_dir}")
  end

  def set_destination_directory
    puts "=> Enter directory to move clean files to.  Options: 'movies' and 'tv_shows'"
    dir = nil
    loop do
      dir = gets.chomp
      if dir == "movies"
        @directory = "~/Desktop/movies"
        break
      elsif dir == "tv_shows"
        @directory = "~/Desktop/tv_shows"
        break
      else
        puts "=> Please select either 'movies' or 'tv_shows'."
      end
    end
  end

  def welcome_message
    puts "Welcome to Movie Metadata Cleaning Utility."
    puts "=> Press any key to continue..."
    gets.chomp
  end

  # Converts all mkv files to mp4, destroys original
  def clean_mkv_files
    mkv_files = get_files("*.mkv")

    mkv_files.each do |mkv|
      convert_mkv_to_mp4(mkv)
      destroy_dirty_file!(mkv)
    end
  end

  # Strips metadata, removes old file for every mp4 file
  def clean_mp4_files
    mp4_files = get_files("*.mp4")

    mp4_files.each do |mp4|
      create_clean_file(mp4)
      destroy_dirty_file!(mp4)
    end
  end

  # Converts mkv to mp4 in place
  def convert_mkv_to_mp4(mkv_file)
    mp4_name = clean_mp4_name(mkv_file)
    system("ffmpeg -i '#{mkv_file}' -vcodec copy -acodec copy '#{mp4_name}'")
  end

  # Creates new metadataless copy of file in a different directory
  def create_clean_file(file)
    destination = "#{@directory}/'clean_#{file}'"
    system("ffmpeg -i '#{file}' -map_metadata -1 -c:v copy -c:a copy #{destination}")
  end

  # Creates .mp4 version of filename
  def clean_mp4_name(file)
    regex = /(.mkv)$/
    file.gsub(regex, '') + '.mp4'
  end

  def is_video_file?(file)
    regex = /(.mkv|.mp4|.avi)$/i
    file.match?(regex)
  end

  def find_and_move_remaining_video_files
    all_files = get_files("*")
    video_files = []

    # Separate remaining video files so we can decide what to do with them
    all_files.each do |file|
      video_files << file if is_video_file?(file)
    end

    if video_files.count > 0  
      puts "=> #{video_files.count} video files remaining."
      puts "=> Move files to #{@directory} as is? Enter 'yes' or 'no'."
      move = gets.chomp
      if move == "yes"
        move_files_to_destination!(video_files)
      else
        puts "=> Nothing changed."
      end
    else
      puts "=> No remaining video files."
    end
  end

  def move_files_to_destination(files_array)
    files_array.each do |file|
      destination = "#{@directory}/'dirty_#{file}'"
      system("mv #{file} #{destination}")
      destroy_dirty_file!(file)
    end
    puts "=> Files copied to #{destination} and original files destroyed."
  end

  def destroy_dirty_file!(file)
    FileUtils.rm(file)
  end
end

job = MetadataCleaner.new
job.start