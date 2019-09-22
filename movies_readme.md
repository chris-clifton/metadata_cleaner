# movies.rb readme
- exiftool <filename>

# Problem
  - Need to write a program that parses a directory of different movie files
  - Each movie should be stripped of all metadata, except for it's filename, and moved to a "clean" directory
  - Original file should be destroyed
  - To preserve HDD space, a file should be cleaned, then destroyed before starting next file

# Algorithm
  - Iterate over directory, collecting movies in different arrays by filetype
    - Types: .mkv, .mp4
    - Get filetype

  - Copy all MKV's to MP4's

  - For each filetype array
    - For each movie in filetype array
      - Hold filename (will be used in system command)
      - Run system command to strip metadata
      - Place file in new clean directory
  
    - .mp4's
      - System command: `ffmpeg -i 'Mid90s (2018).mp4' -map_metadata -1 -c:v copy -c:a copy 'mid90s.mp4'`

    - .mkv's