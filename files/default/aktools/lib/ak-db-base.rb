#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require 'thor'

module AkTools
  def self.find_file(file, tmp_path="/tmp")
    if file.end_with?(".tar")
      `mkdir #{tmp_path}`
      result = `tar -xvf #{file} -C #{tmp_path}`
      result.split("\n").each do |line|
        if line.end_with?(".sql.gz")
          puts "gunzip #{tmp_path}/#{line} --force"
          `gunzip #{tmp_path}/#{line} --force`
          return "#{tmp_path}/#{line.gsub(".gz", "")}", file
        elsif line.end_with?(".sql")
          return "#{tmp_path}/#{line}", file
        end
      end
    elsif file.end_with?(".sql")
      return file, file
    else
      if file.index("@")
        user_host = file.split("/")[0]
        path = file.gsub(user_host, "")
        list = `ssh #{user_host} 'ls -t #{path}'`
        puts "found the following archives:\n #{list}"
        puts "downloading the last one: #{list.split(" ")[0]}; this may take a while..."
        puts "scp -rC #{user_host}:#{path}/#{list.split(" ")[0]} #{tmp_path}/bk"
        `scp -rC #{user_host}:#{path}/#{list.split(" ")[0]} #{tmp_path}/bk`
        folder = "#{tmp_path}/bk"
      else
        list = `ls -t #{file}`
        folder = "#{file}/#{list.split(" ")[0]}"
      end
      return find_file(folder, tmp_path)
    end
  end
  
  module CLI
    class Utility < Thor
      include Thor::Actions

      desc 'load file role [name]', "Load a file into a new database"
      def load(file, role, name=nil, db_name=nil, prefix=nil, tmp_path="/tmp")
        file = AkTools.find_file(file, tmp_path)[0]
        unless name
          if db_name
            name = "#{prefix}#{db_name.gsub("test", "").gsub("prod", "").gsub(prefix, "")}_#{file[0..-4]}"
          else
            name = file.split("/").last.gsub(".sql", "")
          end
        end
        `createdb #{name} --username=#{role}`
        `psql #{name} < #{file} --username=#{role}`
      end
    end
  end
end
