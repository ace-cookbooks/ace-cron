node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping deploy::rails application #{application} as it is not an Rails app")
    next
  end

  cron_node_key = node[:opsworks][:layers]['workers'][:instances].keys.sort.first
  cron_node = node[:opsworks][:layers]['workers'][:instances][cron_node_key]
  if cron_node.nil?
    Chef::Log.info("No cron_node elected")
  else
    Chef::Log.info("Elected #{cron_node_key} as cron_node")
  end

  execute 'bundle binstubs whenever' do
    user deploy[:user]
    group deploy[:group]
    environment(deploy[:environment])
    cwd deploy[:current_path]
    command "#{deploy[:bundler_binary]} binstubs whenever"
  end

  if cron_node && cron_node[:hostname] == node[:opsworks][:instance][:hostname] # I'm special!
    Chef::Log.info("Assuming cron_node role")
    # cron
    execute 'bundle exec whenever -w' do
      user deploy[:user]
      group deploy[:group]
      environment(deploy[:environment])
      cwd deploy[:current_path]
      command "#{deploy[:bundler_binary]} exec whenever -w"
    end
  else
    Chef::Log.info("Not the cron_node: Removing deploy's crontab")
    # delete cron
    execute 'bundle exec whenever -c' do
      user deploy[:user]
      group deploy[:group]
      environment(deploy[:environment])
      cwd deploy[:current_path]
      command "#{deploy[:bundler_binary]} exec whenever -c"
    end
  end
end
