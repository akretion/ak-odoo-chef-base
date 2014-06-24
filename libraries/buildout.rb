require 'chef/exceptions'
require 'chef/log'
require 'chef/provider'
require 'chef/mixin/shell_out'
require 'fileutils'
require_relative 'configparser'

# we don't define the provider as a classical LWRP but more as a HWRP
# because we want to inherit from the standard Chef::Provider
# and because we want the associated resource to inherit from Chef::Resource::Scm
# as explained here http://tech.yipit.com/2013/05/09/advanced-chef-writing-heavy-weight-resource-providers-hwrp/
class Chef
  class Provider
    class Buildout < Chef::Provider

      include ::Chef::Mixin::ShellOut
      #include Chef::DSL::Recipe
      #include Chef::Mixin::FromFile

      attr_reader :scm_provider

      def initialize(new_resource, run_context)
        super(new_resource, run_context)

        # will resolve to either git, bzr, hg or svn based on resource attributes,
        # and will create a resource corresponding to that provider
        @scm_provider = new_resource.scm_provider.new(new_resource, run_context)
      end

      def load_current_resource
        @scm_provider.load_current_resource
      end

      def action_sync
        if @new_resource.repository
          @scm_provider.action_sync()
        else
          boostrap_template_folder()
        end

        unless ::File.exist? "#{@new_resource.destination}/bootstrap.py"
          user = @new_resource.user
          grp = @new_resource.group
          send :cookbook_file, "#{@new_resource.destination}/bootstrap.py" do
            source "buildout/bootstrap.py"
            owner user
            group grp
          end.run_action :create
        end

        bootstrap_python_env()
        # NOTE we can eventually read a buildout config with the following code:
        # cp = ConfigParser.new("#{@new_resource.destination}/buildout.cfg")
        run_buildout()
      end

      def bootstrap_python_env
        # TODO deal with possible virtualenv
        system "cd #{@new_resource.destination} && su #{@new_resource.user} -c 'python bootstrap.py'" unless ::File.exist?("#{@new_resource.destination}/bin")
      end

      def run_buildout
        system "cd #{@new_resource.destination} && su #{@new_resource.user} -c 'python bin/buildout'"
      end

      def boostrap_template_folder
        user = @new_resource.user
        grp = @new_resource.group

        send :directory, @new_resource.destination do
          owner user
          group grp
        end.run_action :create

        send :cookbook_file, "#{@new_resource.destination}/buildout.base.80.cfg" do
          source "buildout/buildout.base.80.cfg"
          owner user
          group grp
        end.run_action :create

        send :template, "#{@new_resource.destination}/buildout.cfg" do
          owner user
          group grp
          mode 00777
          source "buildout.cfg.erb"
        end.run_action :create
      end

    end
  end
end
