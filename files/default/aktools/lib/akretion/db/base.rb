# encoding: utf-8

require "rubygems"
require 'thor'
require 'open4'

module Akretion
  module Db

    def self.find_file(file, tmp_path="~/.tmp")
      if file.end_with?(".tar")
        `mkdir -p #{tmp_path}`
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

    class CLI < ::Backup::CLI

      desc 'load file role [name]', "Load a file into a new database (also see load_s3)
      example1: ak-db load path/file.sql db_user
      example2: ak-db load backups_folder db_user
      example3: ak-db load erp_dev@foo.erp.akretion.com/home/erp_dev/erp/staging/backups db_user"
      def load(file, role, name=nil, db_name=nil, prefix="dev_", tmp_path="~/.tmp")
        res = Akretion::Db.find_file(file, tmp_path)
        sql_file = res[0]
        unless name
          name = "#{prefix}#{sql_file.split("/").last.gsub(".sql", "").gsub("test_", "").gsub("prod_", "").gsub(prefix, "")}"
          if file.index(/_20[0-9][0-9]/) && !name.index(/_20[0-9][0-9]/)
            i = file.index(/_20[0-9][0-9]/)
            stamp = file[i + 1 .. i + 13]
            name = "#{name}_#{stamp}"
          end
        end
        `createdb #{name} --username=#{role}`
        `psql #{name} < #{sql_file} --username=#{role}`
      end


      desc 'load_s3 db_user', "Load backup from Amazon s3"
      def load_s3(db_user="vagrant")
        unless ::File.exist?("#{::File.expand_path("~")}/.s3cfg")
          puts "s3cmd configuration file ~/.s3cfg not found!"
          puts "Please you should first configure s3cmd with the following command:\ns3cmd --configure"
          exit
        end

        puts "Enter bucket name:"
        bucket = $stdin.gets.chomp!
        puts "last available daily backups are:"
        puts "s3cmd ls s3://#{bucket}/backups/prod_daily/"
        archives = `s3cmd ls s3://#{bucket}/backups/prod_daily/`
        puts archives
        puts "\nEnter name of the backup you want to restore"
        #TODO deal with splitted backups
        last_archive = archives.strip().split("\n").last.gsub("DIR   ", "").strip()
        puts "default:\n #{last_archive}\nType Enter to use this file, else specify the backup file"

        archive = $stdin.gets.chomp!
        archive = last_archive if archive.strip() == ""
        `mkdir -p ~/.tmp`
        stamp = archive.split("/").last[0..12]
        cmd = "s3cmd --progress get #{archive}prod_daily.tar ~/.tmp/prod_daily_#{stamp}.tar --force 2>&1"
        status = Open4.popen4(cmd) do |pid, stdin, stdout, stderr|
          stdout.each {|line| puts line }
        end
        invoke :load, ["~/.tmp/prod_daily_#{stamp}.tar", db_user]
      end

    end
  end
end
