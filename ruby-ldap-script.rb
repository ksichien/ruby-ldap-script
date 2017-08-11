#!/usr/bin/env ruby
require 'net/ldap'

@fname = ARGV[0].downcase
@lname = ARGV[1].downcase
SERVERHOSTNAME = "ldap.example.com"
SERVERLDAP = "dc=example,dc=com"
SERVERADMIN = "cn=admin"
SERVERPASSWORD = "password"
EMAIL = "example.com"
GROUPOU = "ou=Groups"
USEROU = "ou=Users"
USERDN = "uid=#{@fname}.#{@lname},#{USEROU},#{SERVERLDAP}"

def genldap
  ldap = Net::LDAP.new :host => SERVERHOSTNAME,
       :port => 636,
       :encryption => :simple_tls,
       :base => SERVERLDAP,
       :auth => {
             :method => :simple,
             :username => "#{SERVERADMIN},#{SERVERLDAP}",
             :password => SERVERPASSWORD
  }
end

def genpwd
  pwd = SecureRandom.urlsafe_base64(20)
  hashpwd = pwd.crypt('$6$' + SecureRandom.random_number(36 ** 8).to_s(36))
  pwdarray = [pwd, hashpwd]
end

def add
  ldap = genldap
  grouparray = File.open(ARGV[3], 'r') { |groups| groups.readlines }
  grouparray.each do |g|
    path = ""
    ldapgroups = g.split(",")
    if ldapgroups[1].nil?
      path = ldapgroups[0].chomp
    else
      path << ldapgroups[0]
      ldapunits = ldapgroups.drop(1)
      ldapunits.each do |l|
        path << ",ou=#{l.chomp}"
      end
    end
    attrdn = "cn=#{path},#{GROUPOU},#{SERVERLDAP}"
    ldap.add_attribute attrdn, :member, USERDN)
    puts "Operation add #{@fname}.#{@lname} to #{attrdn} result: #{ldap.get_operation_result.message}"
  end
end

def create
  ldap = genldap
  pwd = genpwd

  attr = {
    :objectclass => ["inetOrgPerson"],
    :uid => "#{@fname}.#{@lname}",
    :cn => "#{@fname.capitalize} #{@lname.capitalize}",
    :sn => "#{@lname.capitalize}",
    :mail => "#{@fname}.#{@lname}@#{EMAIL}"
  }

  ldap.add(dn: USERDN, attributes: attr)
  puts "Operation create #{@fname}.#{@lname} result: #{ldap.get_operation_result.message}"

  ldap.add_attribute USERDN, :userPassword, "{CRYPT}#{pwd[1]}"
  puts "Operation set password result: #{ldap.get_operation_result.message}"

  unless ARGV[3].nil?
    add
  end

  puts "Username: #{@fname}.#{@lname}"
  puts "Password: #{pwd[0]}"
  puts "Hashed Password: #{pwd[1]}"
end

def search
  ldap = genldap
  puts "#{@fname}.#{@lname} is a member of the following groups:"
  filter = Net::LDAP::Filter.eq("member", USERDN)
  ldap.search( :base => SERVERLDAP, :filter => filter, :return_result => true ) do |entry|
    puts "dn: #{entry.dn}"
  end
end

case ARGV[2]
  when "a"
    add
  when "c"
    create
  when "s"
    search
  else
    puts "Bad or insufficient number of arguments provided, exiting."
end
