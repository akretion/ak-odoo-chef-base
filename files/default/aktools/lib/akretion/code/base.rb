# encoding: utf-8

require "rubygems"
require 'thor'
require 'etc'

module Akretion
  module Code

    class << self

      def is_server_dir(path)
        if ::File.directory?(path)
          entries = Dir.new(path).entries()
          entries.index('src') && entries.index('config')
        else
          false
        end
      end
      
      def get_server_path_from_path(path=Dir.pwd)
        if is_server_dir(path)
          return path
        elsif path != "/"
          get_server_path_from_path(File.expand_path("..", path))
        else
          return false
        end
      end

      def get_cmd_user
        Etc.getpwuid(Process.uid).name
      end
      
      def get_server_path
        path = get_server_path_from_path()
        if path
          return path
        else
          user = get_cmd_user
          if ::File.directory?("/home/#{user}/erp")
            Dir.new("/home/#{user}/erp").entries().each do |dir|
              return "/home/#{user}/erp/#{dir}" if is_server_dir("/home/#{user}/erp/#{dir}")
            end
          end
          return "/home/erp_super/erp/prod"
        end
      end
      
      def get_src_components(path=get_server_path())
        Dir.new("#{path}/src").entries().select do |item|
          ::File.directory?("#{path}/src/#{item}") && item != "." && item != ".."
        end
      end
      
      def get_branches(path=get_server_path())
        get_src_components(path).select do |item|
          ::File.directory?("#{path}/src/#{item}/.bzr") || ::File.directory?("#{path}/src/#{item}/.git")
        end
      end
      
      def extract_addons_dir(path)
        Dir.new(path).entries.each do |item_l1|
          if item_l1 != "." && item_l1 != ".."
            if ::File.exists?("#{path}/#{item_l1}/__openerp__.py")
              return [path.split("/").last]
            elsif ::File.directory?("#{path}/#{item_l1}")
              Dir.new("#{path}/#{item_l1}").entries.each do |item_l2|
                if ::File.exists?("#{path}/#{item_l1}/#{item_l2}/__openerp__.py")
                  return ["#{path.split('/').last}/#{item_l1}"]
                end
              end
            end
          end
        end
        return false
      end
      
      def get_addons_path(path=get_server_path())
        entries = get_src_components(path)
        addons = []
        entries.each do |dir|
          dirs = extract_addons_dir("#{path}/src/#{dir}")
          addons += dirs if dirs
        end
        
        #now re-ordering to ensure we can override modules:
        if addons.index("web")
          addons.delete("web")
          addons += ["web"]
        end
        if addons.index("addons")
          addons.delete("addons")
          addons += ["addons"]
        end
        custom_index = false
        addons.each_with_index do |addon, i|
          if addon.start_with?("custom_")
            custom_index = i
          end
        end
        if custom_index
          custom = addons[custom_index]
          addons.delete_at(custom_index)
          addons = [custom] + addons
        end
        addons
      end

    end


    class CLI < Thor
      include Thor::Actions

      desc 'clone remote target', "copy server"
      def clone(remote, target)
        `mkdir #{target}`
        system "rsync -az #{remote}/src #{target}"
        `mkdir #{target}/config`
        `rsync -az #{remote}/config/server.conf #{target}/config`
      end

      desc 'pull', 'pull'
      def pull()
        path = Code.get_server_path()
        branches = Code.get_branches(path)
        puts "src branches are #{branches.join(', ')}"
        branches.each do |branch|
          if ::File.directory?("#{path}/src/#{branch}/.bzr")
            puts "\npulling #{path}/src/#{branch}"
            system "bzr pull #{path}/src/#{branch}"
          elsif ::File.directory?("#{path}/src/#{branch}/.git")
            puts "\npulling #{path}/src/#{branch}"
            system "git pull #{path}/src/#{branch}"
          end
        end
      end

      desc 'push', 'push'
      def push()
        puts "TODO"
      end

      desc 'serve', 'serve'
      def serve(*opts)
        path = Code.get_server_path()
        puts "assuming server located at #{path}"
        addons_path = Code.get_addons_path(path).map{|i| "#{path}/src/#{i}"}.join(",")
        puts  "#{path}/src/server/openerp-server --addons-path=#{addons_path} -c #{path}/config/server.conf #{opts.join(" ")}"
        exec "#{path}/src/server/openerp-server --addons-path=#{addons_path} -c #{path}/config/server.conf #{opts.join(" ")}"
      end
      
      desc 'debug', 'debug'
      def debug(*opts)
        serve(opts.join(" ") + " --debug")
      end
      
      desc 'console', 'interactive console'
      def console
        puts "TODO"
        #TODO cf http://bazaar.launchpad.net/~anybox/anybox.recipe.openerp/trunk/view/head:/anybox/recipe/openerp/startup.py
      end
      
      desc 'addons_path', 'addons_path'
      method_option :complete, :type => :boolean, :aliases => "-c"
      def addons_path
        addons = Code.get_addons_path
        if options[:complete]
          path = Code.get_server_path()
          puts addons.map{|i| "#{path}/src/#{i}"}.join(",")
        else
          puts addons
        end
      end

    end
  end
end
