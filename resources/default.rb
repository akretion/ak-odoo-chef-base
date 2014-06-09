require "chef/resource/scm"

class ::Chef
  class Resource
    class ErpCodebase < ::Chef::Resource::Scm

      def initialize(name, run_context=nil)
        super
        #@revision = 'last:1' if @revision == "HEAD" && provider is bzr
        @resource_name = :erp_codebase
        @scm_provider ||= Chef::Provider::Git
        @additional_remotes = Hash[] # required by git
        @provider = ::Chef::Provider::ErpCodebase
      end

      def is_virtualenv(arg=nil)
        set_or_return(
              :is_virtualenv,
              arg,
              :kind_of => [TrueClass, FalseClass]
        )
      end

      def branch_hint(arg=nil)
        set_or_return(
              :branch_hint,
              arg,
              :kind_of => String
        )
      end

      def scm_provider(arg=nil)
        klass = if arg.kind_of?(String) || arg.kind_of?(Symbol)
                  lookup_provider_constant(arg)
                else
                  arg
                end
        set_or_return(
          :scm_provider,
          klass,
          :kind_of => [ Class ]
        )
      end

      # required by git:
      def additional_remotes(arg=nil)
        set_or_return(
          :additional_remotes,
          arg,
          :kind_of => Hash
        )
      end

      alias :branch :revision
      alias :reference :revision

      alias :repo :repository


    end
  end
end
