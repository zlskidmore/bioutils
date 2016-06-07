#!/usr/bin/perl

################################################################################
################### Declare Packages and initialize variables ##################

# Declare packages
use strict;
use warnings;
use Getopt::Long;

# Initialize variables
my $bam_list;
my $superseded_info;
my $help = 0;

################################################################################
################## Set up help messages ########################################
GetOptions("bam_list=s" => \$bam_list, "superseded_info=s" => \$superseded_info,
           "help!" => \$help) || die "incorrect usage, type --help";

if($help){
    print "Summary: Program is designed to find the new bams for those that
           have been superseded.\n";
    print "Example Usage: perl find_superseded_bam.pl
           --bam_list=file_with_superseded_bam
           --superseded_info=file_with_superseded_bam_mapping\n";
    print "Required Arguments:\n";
    print "\t--bam_list [Path to file containing bams to check]\n";
    print "\t--superseded_info [Path to file containing mapping between
           superseded and new bams, first columns should be the \"merged_bam\"
           and the second column should be the \"superseding bam\"]\n";

    exit;
}

################################################################################
################# Open file for superseded info and store ######################

# Open FILE HANDLE
open(ANSWER, "<", $superseded_info) || die $!;

# Store the mapping info into a hash
my %map = ();
while(<ANSWER>){
    my @field = split(",", $_);
    $field[0] =~ m/.*\/+([a-z,0-9]+.bam)\(*\d*\)*/g;
    my $bam_a = $1;
    my $bam_b = $field[1];
    if($bam_a ~~ undef || $bam_b ~~ undef){
        next;
    }
    $map{$bam_a} = $bam_b;
}

# Close the FILE HANDLE
close ANSWER;

################################################################################
############### Run through the query file and find the result #################

# Open FILE HANDLE
open(QUERY, "<", $bam_list) || die $!;

# print the matching hash value
while(<QUERY>){
    $_ =~ m/.*\/+([a-z,0-9]+.bam)\(*\d*\)*/g;
    my $bam_query = $1;
    print "$bam_query\t$map{$bam_query}\n";
}

# Close FILE HANDLE
close QUERY;

exit;
