node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'nodejs'
    Chef::Log.debug("Skipping deploy::nodejs application #{application} as it is not a node.js app")
    next
  end

  if node[:deploy][application][:nodejs][:run_script] == ""
    Chef::Log.debug("XXX Skipping deploy::nodejs-opsworks for #{application} because we have no run_script specified")
    next
  elsif not node[:opsworks][:instance][:layers][0].start_with?(application)
    Chef::Log.debug("XXX Skipping deploy::nodejs-opsworks for #{application} because incompatible layer")
    next
  end

  template "#{deploy[:deploy_to]}/shared/config/opsworks.js" do
    cookbook 'opsworks_nodejs'
    source 'opsworks.js.erb'
    mode '0660'
    owner deploy[:user]
    group deploy[:group]
    variables(:database => deploy[:database], :memcached => deploy[:memcached], :layers => node[:opsworks][:layers])
  end
end
