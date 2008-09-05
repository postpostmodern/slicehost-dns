#!/usr/bin/env ruby
require 'rubygems'
require 'activeresource'

# Get your API key from your SliceManager here:
# https://manage.slicehost.com/api/
# and put it here:
API_PASSWORD = 'your_api_key_goes_here'

unless ARGV.size == 2 && ARGV[1].end_with?('.')
  puts "Usage: #{__FILE__} slice domain.com."
  exit
end

# Get command line arguments
slice_name = ARGV.shift
zone_name = ARGV.shift

# Make sure you set this thing up
if API_PASSWORD == 'your_api_key_goes_here'
  puts "Open the script in a text editor and put your api key on line 13."
  exit
end

# Address class is required for Slice class 
class Address < String; end

# Define the ActiveResource classes
class Slice < ActiveResource::Base 
  self.site = "https://#{API_PASSWORD}@api.slicehost.com/" 
  def self.find_by_name(name)
    Slice.find(:first, :params => { :name => name })    
  end
end 

class Zone < ActiveResource::Base 
  self.site = "https://#{API_PASSWORD}@api.slicehost.com/" 
  
  def records
    Record.find(:all, :params => { :zone_id => self.id })
  end
  
  def self.exists?(name)
    !Zone.find(:all, :params => { :origin => name }).empty?
  end
  
  def self.find_by_name(name)
    Zone.find(:first, :params => { :origin => name })
  end
end 

class Record < ActiveResource::Base 
  self.site = "https://#{API_PASSWORD}@api.slicehost.com/" 
end

# Method to add a new record based on a hash
def create_record(r, defaults)
  rec = Record.new(defaults.merge(r))
  rec.save
  puts notice(rec)
end

# Prints the record's details
def notice(r)
  ' | ' + r.name.to_s.ljust(30) + 
  ' | ' + r.record_type.to_s.ljust(5) + 
  ' | ' + r.aux.to_s.rjust(4) + 
  ' | ' + r.data.to_s.ljust(34) + 
  ' | '
end

# Find the IP address of the slice
slice = Slice.find_by_name(slice_name)

# Bail if the slice name doesn't work out
if slice.nil?
  puts "\nSlice not found. :( "
  puts "Aborted."
  exit
end

slice_ip = slice.ip_address

# Check if zone exists
if Zone.exists?(zone_name)
  puts "\nA zone for #{zone_name} already exists."
  print "Cancel or Overwrite? [Co] "
  input = STDIN.gets.chomp.strip
  # Respond accordingly
  if input.downcase == 'o'
    Zone.find_by_name(zone_name).destroy
  else
    puts "  Cancelled"
    exit
  end
end


# Create new zone
z = Zone.new(:origin => zone_name, :ttl => 43200)
z.save

# Record definitions 
defaults = { :zone_id => z.id, :ttl => 43200 }

a_records = [
  { :record_type => 'A', :name => zone_name,        :data => slice_ip },
  { :record_type => 'A', :name => "*.#{zone_name}", :data => slice_ip }
]

google_mx = [
  { :record_type => 'MX', :name => zone_name, :aux => 10, :data => 'ASPMX.L.GOOGLE.COM.'      },
  { :record_type => 'MX', :name => zone_name, :aux => 20, :data => 'ALT1.ASPMX.L.GOOGLE.COM.' },
  { :record_type => 'MX', :name => zone_name, :aux => 20, :data => 'ALT2.ASPMX.L.GOOGLE.COM.' },
  { :record_type => 'MX', :name => zone_name, :aux => 30, :data => 'ASPMX2.GOOGLEMAIL.COM.'   },
  { :record_type => 'MX', :name => zone_name, :aux => 30, :data => 'ASPMX3.GOOGLEMAIL.COM.'   },
  { :record_type => 'MX', :name => zone_name, :aux => 30, :data => 'ASPMX4.GOOGLEMAIL.COM.'   },
  { :record_type => 'MX', :name => zone_name, :aux => 30, :data => 'ASPMX5.GOOGLEMAIL.COM.'   }
]

google_cname = [
  { :record_type => 'CNAME', :name => 'mail',     :data => 'ghs.google.com.' },
  { :record_type => 'CNAME', :name => 'start',    :data => 'ghs.google.com.' },
  { :record_type => 'CNAME', :name => 'docs',     :data => 'ghs.google.com.' },
  { :record_type => 'CNAME', :name => 'calendar', :data => 'ghs.google.com.' }
]  

google_srv = [
  { :record_type => 'SRV', :name => "_xmpp-server._tcp.#{zone_name}", :aux => 5, :data => '0 5269 xmpp-server.l.google.com.'},
  { :record_type => 'SRV', :name => "_xmpp-server._tcp.#{zone_name}", :aux => 20, :data => '0 5269 xmpp-server1.l.google.com.'},
  { :record_type => 'SRV', :name => "_xmpp-server._tcp.#{zone_name}", :aux => 20, :data => '0 5269 xmpp-server2.l.google.com.'},
  { :record_type => 'SRV', :name => "_xmpp-server._tcp.#{zone_name}", :aux => 20, :data => '0 5269 xmpp-server3.l.google.com.'},
  { :record_type => 'SRV', :name => "_xmpp-server._tcp.#{zone_name}", :aux => 20, :data => '0 5269 xmpp-server4.l.google.com.'},
  { :record_type => 'SRV', :name => "_jabber._tcp.#{zone_name}", :aux => 5, :data => '0 5269 xmpp-server.l.google.com.'},
  { :record_type => 'SRV', :name => "_jabber._tcp.#{zone_name}", :aux => 20, :data => '0 5269 xmpp-server1.l.google.com.'},
  { :record_type => 'SRV', :name => "_jabber._tcp.#{zone_name}", :aux => 20, :data => '0 5269 xmpp-server2.l.google.com.'},
  { :record_type => 'SRV', :name => "_jabber._tcp.#{zone_name}", :aux => 20, :data => '0 5269 xmpp-server3.l.google.com.'},
  { :record_type => 'SRV', :name => "_jabber._tcp.#{zone_name}", :aux => 20, :data => '0 5269 xmpp-server4.l.google.com.'}
]

ns_records = [
  { :record_type => 'NS', :name => zone_name, :data => 'ns1.slicehost.com.' },
  { :record_type => 'NS', :name => zone_name, :data => 'ns2.slicehost.com.' },
  { :record_type => 'NS', :name => zone_name, :data => 'ns3.slicehost.com.' }
]

# DO IT!!

puts "\nCreating A records..."
a_records.each do |r|
  create_record(r, defaults)
end

puts "\nCreating NS records..."
ns_records.each do |r|
  create_record(r, defaults)
end

# Ask to add Google records
print "\nAdd records for Google Apps? [Yn] "
input = STDIN.gets.chomp.strip

# Respond accordingly
unless input.downcase == "n"
  puts "\nCreating Google MX records..."
  google_mx.each do |r|
    create_record(r, defaults)
  end
  
  puts "\nCreating Google SRV records..."
  google_srv.each do |r|
    create_record(r, defaults)
  end

  puts "\nCreating Google CNAME records..."
  google_cname.each do |r|
    create_record(r, defaults)
  end
end

# Finally, let everyone know we're finished
puts "\nALL DONE!"
