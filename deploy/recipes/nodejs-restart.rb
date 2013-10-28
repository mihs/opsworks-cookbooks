include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'nodejs'
    Chef::Log.debug("Skipping deploy::nodejs-restart for application #{application} as it is not a node.js app")
    next
  end

  if node[:deploy][application][:nodejs][:run_script] == ""
    Chef::Log.debug("XXX Skipping deploy::nodejs-restart for #{application} because we have no run_script specified")
    next
  elsif not node[:opsworks][:instance][:layers][0].start_with?(application)
    Chef::Log.debug("XXX Skipping deploy::nodejs-restart for #{application} because incompatible layer")
    next
  else
    Chef::Log.debug("XXX Deploying-restart the app: #{application} with run_script: #{node[:deploy][application][:nodejs][:run_script]}")
  end

  ruby_block "restart node.js application #{application}" do
    block do
      Chef::Log.info("restart node.js via: #{node[:deploy][application][:nodejs][:restart_command]}")
      Chef::Log.info(`#{node[:deploy][application][:nodejs][:restart_command]}`)
      $? == 0
    end
  end

end
