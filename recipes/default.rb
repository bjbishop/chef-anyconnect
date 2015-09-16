me = node['current_user']
home = ::File.join(::Dir.home(me))

remote_file "Cisco Anyconnect vpnsetup.dmg" do
  action :create
  path ::File.join(Chef::Config[:file_cache_path], "vpnsetup.dmg")
  source "https://vpn.pearson.com/CACHE/stc/2/binaries/vpnsetup.dmg"
  owner me
  mode "0700"
  checksum "508b8432d1ad2167e536accda2ab462e938876ba4b47d6bfc71b7a96962662c6"
  retries 3
  retry_delay 10
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
