Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/xenial64'
  config.vm.network 'private_network', ip: '192.168.42.13'
  config.vm.provision 'shell', inline: 'sudo apt-get install -qq python-minimal'
  config.vm.provision :ansible,
    playbook: 'ansible/main.yml',
    raw_arguments: %w(--become),
    extra_vars: {
      static_app_dir: '/vagrant',
      static_app_name: 'blog'
    }
end
