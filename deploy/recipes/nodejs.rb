include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'nodejs'
    Chef::Log.debug("Skipping deploy::nodejs for application #{application} as it is not a node.js app")
    next
  end

  if node[:deploy][application][:nodejs][:run_script] == ""
    Chef::Log.debug("XXX Skipping deploy::nodejs for #{application} because we have no run_script specified")
    next
  elsif node[:opsworks][:instance][:layers][0].index(application) != 0
    Chef::Log.debug("XXX Skipping deploy::nodejs for #{application} because incompatible layer")
    next
  else
    Chef::Log.debug("XXX Deploying the app: #{application} with run_script: #{node[:deploy][application][:nodejs][:run_script]}")
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  opsworks_nodejs do
    deploy_data deploy
    app application
  end

  application_environment_file do
    user deploy[:user]
    group deploy[:group]
    path ::File.join(deploy[:deploy_to], "shared")
    environment_variables deploy[:environment_variables]
  end

  ruby_block "restart node.js application #{application}" do
    block do
      Chef::Log.info("restart node.js via: #{node[:deploy][application][:nodejs][:restart_command]}")
      Chef::Log.info(`#{node[:deploy][application][:nodejs][:restart_command]}`)
      $? == 0
    end
  end
end
