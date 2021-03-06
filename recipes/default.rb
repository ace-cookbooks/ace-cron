node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping deploy::rails application #{application} as it is not an Rails app")
    next
  end

  cookbook_file 'usr-local-bin.sh' do
    path '/etc/profile.d/usr-local-bin.sh'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end

  execute 'bundle binstubs whenever railties' do
    user deploy[:user]
    group deploy[:group]
    environment(deploy[:environment])
    cwd deploy[:current_path]
    command "#{deploy[:bundler_binary]} binstubs whenever railties"
  end

  execute 'bundle exec whenever -w' do
    user deploy[:user]
    group deploy[:group]
    environment(deploy[:environment])
    cwd deploy[:current_path]
    command "#{deploy[:bundler_binary]} exec whenever -w -s 'path=#{deploy[:current_path]}'"
  end
end
