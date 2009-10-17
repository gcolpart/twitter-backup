#!/usr/bin/perl -w

use strict;
use warnings;
use diagnostics;

use Net::Twitter;

# Initialize Twitter connections
my $nt = Net::Twitter->new(
	traits   => [qw/API::REST/],
	username => 'MYUSER',
	password => 'MYPASS'
);
if( not defined($nt) or $@ ) {
	die "Could not create Twitter connection! " . $@ . "\n";
}

# Read last id
open(IDFILE, "backup/lastid") or die "Write error lastid! $!\n";
chomp(my $high_water = <IDFILE>);
close(IDFILE);

# Open output file
open(BAKFILE, ">>backup/twitter-current") or die "Write error log file! $!\n";
binmode BAKFILE, ":utf8";

# Open lastid file
open(IDFILE, ">backup/lastid") or die "Write error lastid! $!\n";

my $firstid = '';
my $lastid = '';
my $returns = 200;
my $countimported = 0;

eval {

	my $statuses = $nt->friends_timeline({ since_id => $high_water, count => $returns });

        #for my $status ( @$statuses ) {
        for my $status ( sort { $a->{id} <=> $b->{id}; } @$statuses ) {
            if ( $firstid eq '') { $firstid = $status->{'id'}; }
            $lastid = $status->{'id'};
            print BAKFILE "$status->{created_at} <$status->{user}{screen_name}> $status->{text} [$status->{id}]\n";
	    $countimported++;
        }
    };

# Write last id
if ($lastid ne '' ) { print IDFILE $lastid; }
else { print IDFILE $high_water; }

close(BAKFILE);
close(IDFILE);

# Print report
print "$countimported Tweets imported in this run (begin from $firstid, end to $lastid).\n"; 
