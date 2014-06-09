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
    class ErpCodebase < Chef::Provider

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
        @scm_provider.run_action(:sync)
        cp = ConfigParser.new("#{@new_resource.destination}/buildout.cfg")
      end

    end
  end
end
