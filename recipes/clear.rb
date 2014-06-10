node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping deploy::rails application #{application} as it is not an Rails app")
    next
  end

  execute 'bundle binstubs whenever' do
    user deploy[:user]
    group deploy[:group]
    environment(deploy[:environment])
    cwd deploy[:current_path]
    command "#{deploy[:bundler_binary]} binstubs whenever"
  end

  # delete cron
  execute 'bundle exec whenever -c' do
    user deploy[:user]
    group deploy[:group]
    environment(deploy[:environment])
    cwd deploy[:current_path]
    command "#{deploy[:bundler_binary]} exec whenever -c"
  end
end
