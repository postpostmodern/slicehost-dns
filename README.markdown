# Slicehost DNS Script

I found the SliceManager to be a little time consuming when creating multiple DNS records for multiple domains. This ruby script interfaces with Slicehost's API to add the basic DNS records for a domain.

If you need DNS entries other than (or instead of) those that come with the script (see below), it should be fairly easy to open the script and modify the records to your liking.

# Installation

* There's just a single file (slicedns.rb). Get it.
* Get an API key from your SliceManager at: https://manage.slicehost.com/api/
* Open the script and replace "your\_api\_key\_goes\_here" with your API key.
* Save the script.
* Make sure the script is executable by you: `chmod 744 slicedns.rb`
* Run the script (see 'Usage' below).

# Usage

    ./slicedns.rb slice_name domain.com.

There are two required arguments for the script. The first is the name of your slice. The second is the domain name (with trailing period [.]).

The script will create a zone with the DNS records shown below. It will ask you if you want to also create the Google Apps records.

If the zone already exists, you will be prompted to Cancel or Overwrite the existing records. ___Choosing overwrite will delete the whole zone (including any custom records you have previously set up) and start from scratch.___

# DNS Records Created

The following records will be created in the example.com. zone:

    example.com.    A       [your slice's IP]
    *.example.com.  A       [your slice's IP]
                            
    example.com.    NS      ns1.slicehost.com.
    example.com.    NS      ns2.slicehost.com.
    example.com.    NS      ns3.slicehost.com.
                            
If you respond with Y to "Add records for Google Apps? [Yn]" the following will also be created:
                            
    example.com.    MX      10 ASPMX.L.GOOGLE.COM.
    example.com.    MX      20 ALT1.ASPMX.L.GOOGLE.COM.
    example.com.    MX      20 ALT2.ASPMX.L.GOOGLE.COM.
    example.com.    MX      30 ASPMX2.GOOGLEMAIL.COM.
    example.com.    MX      30 ASPMX3.GOOGLEMAIL.COM.
    example.com.    MX      30 ASPMX4.GOOGLEMAIL.COM.
    example.com.    MX      30 ASPMX5.GOOGLEMAIL.COM.
                            
    mail            CNAME   ghs.google.com.
    start           CNAME   ghs.google.com.
    docs            CNAME   ghs.google.com.
    calendar        CNAME   ghs.google.com.
    