# How to Use


# Dependencies
- clamAV


# movies.rb readme
- exiftool <filename>
  - Check that the metadata has been correctly cleaned

# TODO
- Make this executable, which allows a cleanup of all the hardcoded paths
- Cleanup hardcoded paths
  - Allow custom source, destination, and infected files folders
- Restructure as command line utility to take options and arguments
  - Really shouldn't destroy so many files, should make that an argument
- Ability to clean files in place (in plex directory)
  - Should not be able to destroy any files
  - Should work one file at a time (create clean/delete dirty) to stay safe on storage
- Add ability to clean .avi
- Improve output for move_files_to_destination so its easier to read 
- Better display
  - Show all directories and their files
  - Show current files being manipulated
- Validate all manipulations
  - Success/failure
- A way to exit program gracefully
