#!/usr/bin/env ruby
require_relative 'output_helper'
require 'fileutils'

class MetadataCleaner
  require 'fileutils'

  def initialize
    @output_helper = OutputHelper.new
    @output_helper.clear
    @output_helper.welcome_message
  end

  def start
    initialize_directories
    destroy_non_video_files!
    clean_mkv_files
    clean_mp4_files
    find_and_move_remaining_video_files
    run_antivirus_scan
  end

  def initialize_directories
    @source       = get_or_create_dir(:source,      "/home/chris/Downloads")
    @destination  = get_or_create_dir(:destination, "/home/chris/Desktop/movies")
    @infected     = get_or_create_dir(:infected,    "/home/chris/Desktop/virus")
    flatten_source_directory
  end

  # Flatten directory so all files are in parent/source folder
  def flatten_source_directory
    system("find #{@source} -mindepth 2 -type f -exec mv -i '{}' #{@source} ';'")
  end

  def get_or_create_dir(dir_type, default_dir)
    puts "=> Create directory for #{dir_type} files:"
    puts "=> To use the default directory (#{default_dir}), just press 'Enter'"
    puts "=> To use a different directory, please enter full path, then press 'Enter'"
    directory_path = gets.chomp
    
    if directory_path == ""
      directory_path = default_dir
    else
      directory_path
    end

    # If the directory doesn't already exist, create it
    unless File.exists?(directory_path)
      FileUtils.mkdir_p(directory_path)
    end

    puts "=> Directory for #{dir_type} files: #{directory_path}"
    directory_path
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

  def get_files(filetype)
    Dir["#{@source}/*#{filetype}"]
  end

  # Converts mkv to mp4 in place
  def convert_mkv_to_mp4(mkv_file)
    mp4_name = clean_mp4_name(mkv_file)
    system("ffmpeg -i '#{mkv_file}' -vcodec copy -acodec copy '#{mp4_name}'")
  end

  # Creates new metadataless copy of file in a different directory
  # System command: ses ffmpeg tool to create a copy of the file 
  # with most unnecessary metadata wiped from file
  def create_clean_file(file)
    name = clean_file_name(file)
    system("ffmpeg -i '#{file}' -map_metadata -1 -c:v copy -c:a copy #{@destination}/'#{name}'")
  end

  # Creates .mp4 version of filename
  def clean_mp4_name(file)
    regex = /(.mkv)$/
    'converted_' + file.gsub(regex, '') + '.mp4'
  end

  # TODO: Probably need to just tack the forward slash onto @source
  def clean_file_name(file)
    path = @source + "/"
    file.gsub(path, 'clean_')
  end

  # May need to expand on whats considered a video file since
  # any filetype not in the regex gets destroyed
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
      puts "=> #{video_files.count} video files remaining:"
      
      video_files.each do |file|
        puts "=> #{file}"
      end

      puts "=> Move files to #{@destination} as is? Enter 'yes' or 'no'"
      move = gets.chomp
      if move == "yes"
        move_files_to_destination!(video_files)
      else
        puts "=> Files left in #{@source}."
      end
    else
      puts "=> No remaining video files."
    end
  end

  # Tag files as "dirty" but move them to destination anyway
  # Should mostly be .avi files
  def move_files_to_destination(files_array)
    files_array.each do |file|
      destination = "#{@destinaton}/'dirty_#{file}'"
      system("mv #{file} #{destination}")
      destroy_dirty_file!(file)
    end
    puts "=> #{files_array.count} files copied to #{destination} and original files destroyed"
  end

  def is_sample_file(file)
    regex = /(sample)/i
    file.match?(regex)
  end

  # Removes a directory!
  # TODO: move to Trash instead
  def destroy_directory!(directory)
    FileUtils.remove_dir(directory)
  end  

  # TODO: move to Trash instead
  def destroy_dirty_file!(file)
    FileUtils.rm(file)
  end

  # Get rid of all the junk files
  # Remove any sample files- may be problematic if a movie
  # name contains word 'sample'
  def destroy_non_video_files!
    files = get_files("*")
    
    files.each do |file|
      if is_sample_file(file)
        destroy_dirty_file!(file)
      elsif is_video_file?(file)
        next  
      elsif File.directory?(file)
        destroy_directory!(file)
      else
        destroy_dirty_file!(file)
      end
    end
  end

  # Prints list of infected files as well as moving them to separate directory
  def run_antivirus_scan
    @output_helper.run_antivirus
    system("clamscan -i --move=#{@infected} #{@destination}")
  end
end
