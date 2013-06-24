#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require 'thor'
require 'open4'

module AkTools
  module CLI
    class Utility < Thor
      include Thor::Actions

      desc 'clone remote target', "copy server"
      def clone(remote, target)
        `rsync -az #{remote} #{target}`
      end

      desc 'pull'
      def pull()
      end

      desc 'push'
      def push()
      end

    end
  end
end
