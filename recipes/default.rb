me = node['current_user']
home = ::File.join(::Dir.home(me))

include_recipe "catchall::webdav"

execute "cp #{::File.join(node['webdav']['mount'], 'artifacts', 'vpnsetup.dmg')} #{::File.join(Chef::Config[:file_cache_path], 'vpnsetup.dmg')}" do
  action :run
  creates ::File.join(Chef::Config[:file_cache_path], 'vpnsetup.dmg')
  user node['current_user']
  retries 10
  retry_delay 10
  only_if { ::File.exist?(::File.join(node['webdav']['mount'], "artifacts", "vpnsetup.dmg")) }
end

file ".anyconnect" do
  action :create
  path ::File.join(home, ".anyconnect")
  content '<?xml version="1.0" encoding="UTF-8"?>
<AnyConnectPreferences>
<DefaultUser>bishbr</DefaultUser>
<DefaultSecondUser></DefaultSecondUser>
<ClientCertificateThumbprint>C5B89F53AA6A0934356C788297A67E181BCF6FF1</ClientCertificateThumbprint>
<ServerCertificateThumbprint></ServerCertificateThumbprint>
<DefaultHostName>vpn1.pearson.com</DefaultHostName>
<DefaultHostAddress></DefaultHostAddress>
<DefaultGroup></DefaultGroup>
<ProxyHost></ProxyHost>
<ProxyPort></ProxyPort>
<SDITokenType></SDITokenType>
<ControllablePreferences>
<LocalLanAccess>true</LocalLanAccess></ControllablePreferences>
</AnyConnectPreferences>
'
  owner me
  group me
  mode "0600"
end

file "installed app manifest" do
  action :touch
  path ::File.join(home, "app_manifest.sh")
  owner me
  group me
  mode "0700"
end

bash "Append vpnsetup.dmg to the installed app manifest" do
  action :run
  code "echo open #{::File.join(Chef::Config[:file_cache_path], 'vpnsetup.dmg')} >> #{::File.join(home, 'app_manifest.sh')}"
  not_if "grep vpnsetup.dmg #{::File.join(home, 'app_manifest.sh')}"
end
