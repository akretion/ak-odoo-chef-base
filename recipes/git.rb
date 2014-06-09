package "git"

class ::Chef::Resource::Scm
  def branch_hint(arg=nil)
    set_or_return(
          :branch_hint,
          arg,
          :kind_of => String
    )
  end
end


# 1) monkey-patch Chef Git Provider
# to raise the default ShellOut timeout setting
# because this repo can take over 10min
# to clone from github.com
#
# 2) make it possible to do a shallow clone of a non master branch
class ::Chef::Provider::Git
  def clone
    converge_by("clone from #{@new_resource.repository} into #{@new_resource.destination}") do
      remote = @new_resource.remote

      args = []
      args << "-o #{remote}" unless remote == 'origin'
      args << "--depth #{@new_resource.depth}" if @new_resource.depth

      # NOTE, with the following we however won't be able to specify a commit on a non master branch
      # unless we do that kind of thing may be http://stackoverflow.com/questions/2706797/finding-what-branch-a-commit-came-from
      # so for now we use the force_branch attribute to make this explicit
      if @new_resource.branch_hint
        args << "-b #{@new_resource.branch_hint}"
      else
        args << "-b #{@new_resource.revision}" if @new_resource.revision && !sha_hash?(@new_resource.revision) && @new_resource.revision != 'HEAD'
      end

      Chef::Log.info "#{@new_resource} cloning repo #{@new_resource.repository} to #{@new_resource.destination}"

      clone_cmd = "git clone #{args.join(' ')} \"#{@new_resource.repository}\" \"#{@new_resource.destination}\""
      shell_out!(clone_cmd, run_options(:log_level => :info, :timeout => 10000))
    end
  end
end
