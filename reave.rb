# Usage:
# git log | ruby git_commit_parser.rb
# https://gist.github.com/881641
# By: Jason Amster
# jayamster@gmail.com

require 'rubygems'
require 'pp'
require 'rubygems'
require 'zip/zipfilesystem'
require 'fileutils'

def execute(command, directory = ".")
  directory = ARGV.first unless ARGV.empty?
  `cd #{directory}; #{command}`
end


class ZipThemAll
  attr_accessor :list_of_file_paths, :zip_file_path

  def initialize( zip_file_path, list_of_file_paths )
    @zip_file_path = zip_file_path
    list_of_file_paths = [list_of_file_paths] if list_of_file_paths.class == String
    @list_of_file_paths = list_of_file_paths
  end

  def zip
    zip_file = Zip::ZipFile.open(self.zip_file_path, Zip::ZipFile::CREATE)

    self.zip_em_all( zip_file, @list_of_file_paths )
    zip_file.close
  end

  def zip_em_all( zip_file, file_list, sub_directory="." )    
    file_path = sub_directory
    file_list.each do | file_path |
      if File.exists?file_path
        if File.directory?( file_path )
          file_directory_list = []
          file_directory_list = Dir.entries( file_path )
          file_directory_list.delete(".")
          file_directory_list.delete("..")
          file_directory_list = file_directory_list.inject([]) do | result, path |
            result << file_path + "/" + path
            result
          end
          self.zip_em_all( zip_file, file_directory_list, (sub_directory == nil ? '.' : sub_directory) + "/" + File.basename(file_path) )
        else
          file_name = File.basename( file_path )
          if sub_directory != nil
            if zip_file.find_entry( sub_directory ) == nil
              dir = zip_file.mkdir( sub_directory )
            end
            file_name = sub_directory + "/" + file_name
          end
          if zip_file.find_entry( file_name )
            zip_file.replace( file_name, file_path )
          else
            zip_file.add( file_name, file_path)
          end
        end
      else
        puts "Warning: file #{file_path} does not exist"
      end
    end
  end
end


#find the modified folders
logs = execute "git show --pretty=\"format:\" --name-only HEAD"
logs = logs.split("\n")
logs.shift

logs.delete_if{|log| !log.to_s.include? '/'}

logs = logs.map do |log|
  if log.to_s.include? '/'
    l = log.split("/")
    l.pop
    folder = l
    log = folder.shift
  else
    log = nil
  end
  
end

#iterate the UNIQUE folders and create .ZIP files
logs.uniq.map do |folder|
  pp folder
  if folder.to_s.include? '/'
    archive = folder.split("/")
    archive = archive.pop
  else
    archive = folder
  end
  zip_them_all = ZipThemAll.new(archive + ".zip", folder)
  zip_them_all.zip
end