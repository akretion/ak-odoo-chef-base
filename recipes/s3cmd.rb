#S3 utilities:
package "libxml2-dev"
package "libxslt1-dev"
package "s3cmd" #do
#  notifies :run, "execute[patch-S3-progressbar]", :immediately #TODO adapt ak-db command just for simple S3 retrieval
#end

#execute "patch-S3-progressbar" do #hacky workaround I found so that using it in Ruby displays the transfer progresses
#  command """sed -i 's/def update(self, current_position = -1, delta_position = -1):/def update(self, current_position = -1, delta_position = -1):\\n                sys.stdout.write(chr(10))/' /usr/share/s3cmd/S3/Progress.py"""
#  action :nothing
#end
