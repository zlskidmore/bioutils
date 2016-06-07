#!/usr/bin/perl

# author: Zachary Skidmore

# declare/set up variables and modules

use strict;
use warnings;
use Getopt::Long;

my $input; # input file
my $help; # boolean help
my @line; # array to hold columns of line in an array
my $start; # start position, column 2 in input
my $end; # stop position, column 3 in input
my $output; # output file 
my $flag; # flag stating 0 or 1 based
my $tail; # subsection of line after concatenation
my $size; # size of deletion for determining if del is 1/0 based

# set up get opt long and help statement

GetOptions
(
	'input=s'	=> \$input,
	'output=s'	=> \$output,
	'help!'		=> \$help,
) || die "Incorrect usage see help!\n";

if($help)
{
	print "Description: This program takes input requiring the first 5 columns to be: Chr, Start, Stop, Reference, Variant, Type and will convert input from 0-based\into 1-based or vice versa, the program will automatically determine the existing format for each variant\n\nUSAGE: perl convert.pl --input=file1 --output=file2 [--help]\n";
    exit;
}

########################################################################################################################
################################ open input file handle and determine if file is 1-based or 0-based ####################
########################################################################################################################

# open the file handle

open(INPUT, "$input") || die;
open(OUTPUT, ">$output") || die;

# obtain the start and stop coordinates of the first snp encountered in the file

while(<INPUT>)
{
    
    @line = split("\t");
    $start = $line[1];
    $end = $line[2];
    $tail = join("\t", @line[3..$#line]);

    if($line[3] =~ /\b[ATCG]\b/ig && $line[4] =~ /\b[ATCG]\b/ig)
    {
        if($start + 1 == $end)
        {
            
            print "Detected 0-based SNV\n";
            
            $start = $start+1;
            $end = $end;
            print OUTPUT "$line[0]\t$start\t$end\t$tail";
            next;
        
        } elsif($start == $end) {
            
            print "Detected 1-based SNV\n";
            
            $start = $start-1;
            $end = $end;
            print OUTPUT "$line[0]\t$start\t$end\t$tail";
            next;
            
        } else {
            
            print "An unknown error occured, exitting\n";
            exit;
            
        }
        
       
        
    } elsif($line[3] =~ /[0\*\-]/ig) {
        
        if($start == $end)
        {
            print "Detected 0-based Insertion\n";
            
            $start = $start;
            $end = $end + 1;
            print OUTPUT "$line[0]\t$start\t$end\t$tail";
            next;
            
        } elsif($start == $end -1){
            
            print "Detected 1-based Insertion\n";
            
            $start = $start;
            $end = $end - 1;
            print OUTPUT "$line[0]\t$start\t$end\t$tail";
            next;
            
        } else {
            
            print "An unknown error occured, exitting\n";
            exit;
            
        }
        
        
    } elsif($line[4] =~ /[0\*\-]/ig) {
        
        $size = length $line[3];
        
        if($start + $size == $end)
        {
            
            print "Detected 0-based Deletion\n";
            
            $start = $start + 1;
            $end = $end;
            print OUTPUT "$line[0]\t$start\t$end\t$tail";
            next;
            
        } elsif($end - $start  == $size - 1) {
            
            print "Detected a 1-based Deletion\n";
            
            $start = $start -1;
            $end = $end;
            print OUTPUT "$line[0]\t$start\t$end\t$tail";
            next;
            
        } else {
            
            print "An unknown error occured, exitting\n";
            exit;
            
        }
        
        
        
    } else {
        
        print "Could not determine mutation type, for 1-based|0-based\nexiting...\n";
        exit;
        
    }
    
}

###########################################################################################################################
################################# close filhandle and exit ################################################################

close $output;
close $input;
exit;
