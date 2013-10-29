include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'nodejs'
    Chef::Log.debug("Skipping deploy::nodejs-undeploy for application #{application} as it is not a node.js app")
    next
  end

  if node[:deploy][application][:nodejs][:run_script] == ""
    Chef::Log.debug("XXX Skipping deploy::nodejs-undeploy for #{application} because we have no run_script specified")
    next
  elsif not node[:opsworks][:instance][:layers][0].start_with?(application)
    Chef::Log.debug("XXX Skipping deploy::nodejs-undeploy for #{application} because incompatible layer")
    next
  end

  ruby_block "stop node.js application #{application}" do
    block do
      Chef::Log.info("stop node.js via: #{node[:deploy][application][:nodejs][:stop_command]}")
      Chef::Log.info(`#{node[:deploy][application][:nodejs][:stop_command]}`)
      $? == 0
    end
  end

  file "#{node[:monit][:conf_dir]}/node_web_app-#{application}.monitrc" do
    action :delete
    only_if do
      ::File.exists?("#{node[:monit][:conf_dir]}/node_web_app-#{application}.monitrc")
    end
  end

  directory "#{deploy[:deploy_to]}" do
    recursive true
    action :delete

    only_if do
      ::File.exists?("#{deploy[:deploy_to]}")
    end
  end
end
