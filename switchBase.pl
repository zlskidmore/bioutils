#!/usr/bin/perl
# author/who to complain to: Zachary Skidmore

################################################################################
################## declare/set up variables and modules ########################
use strict;
use warnings;
use Getopt::Long;

my $input; # input file
my $help; # boolean help
my @line; # array to hold columns of line in an array
my $start; # start position, column 2 in input
my $end; # stop position, column 3 in input
my $toBase; # flag specifying whether to convert to 1 or 0 base
my $output; # output file
my $header; # flag specifying if a header is present
my $tail; # subsection of line after concatenation
my $size; # size of deletion for determining if del is 1/0 based
my $zero2zero_conversions = 0; # store the number of zero to zero base conversions performed
my $one2one_conversions = 0; # store the number of one to one base conversions performed
my $one2zero_conversions = 0; # store the number of one to zero base conversions performed
my $zero2one_conversions = 0; # store the number of zero to one base conversions performed

# set up get opt long and help statement

GetOptions
(
	'input=s'	=> \$input,
	'output=s'	=> \$output,
	'toBase=i'	=> \$toBase,
	'header=i'	=> \$header,
	'help!'		=> \$help,
) || die "Incorrect usage see help!\n";

if($help)
{
	print "Description: This program takes input expecting the first 5 tab-seperated ",
	 	  "columns to be: Chr, Start, Stop, Reference, Variant, and will convert the ",
		  "input from 0-based to 1-based or vice versa based on the --toBase parameter\n\n";
	print "Usage: perl switchBase.pl --input=file1 --output=file2 --toBase=0 --header=0 [--help]\n\n";
	print "Parameters:\n\t--input\tFile to perform conversions on\n",
		  "\t--output\tFile to write output to\n",
		  "\t--toBase\tWhether to convert to 1 base or 0 base (expects 0 or 1)\n",
		  "\t--header\tBoolean specifying if a header is present or not!\n";

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
	# split the required inputs up
    @line = split("\t");
    $start = $line[1];
    $end = $line[2];
    $tail = join("\t", @line[3..$#line]);

	# if header flag is present print that first
	if($header){
		print OUTPUT "$line[0]\t$start\t$end\t$tail";
		$header = 0;
		next;
	}

	# if it is a snv
    if($line[3] =~ /\b[ATCG]\b/ig && $line[4] =~ /\b[ATCG]\b/ig)
    {
		# if it is 0 based
        if($start + 1 == $end)
        {
			if($toBase == 0){
				$zero2zero_conversions++;
				print OUTPUT "$line[0]\t$start\t$end\t$tail";
				next;
			} elsif($toBase == 1){
				$zero2one_conversions++;
				$start = $start+1;
				$end = $end;
				print OUTPUT "$line[0]\t$start\t$end\t$tail";
				next;
			} else {
				print STDERR "Argument supplied to --toBase is not 1 or 0\n";
				exit;
			}

		# if it is 1 based
        } elsif($start == $end) {
			if($toBase == 0){
				$one2zero_conversions++;
				$start = $start-1;
				$end = $end;
				print OUTPUT "$line[0]\t$start\t$end\t$tail";
				next;
			} elsif($toBase == 1){
				$one2one_conversions++;
				print OUTPUT "$line[0]\t$start\t$end\t$tail";
				next;
			} else {
				print STDERR "Argument supplied to --toBase is not 1 or 0\n";
				exit;
			}

		} else {
            print STDERR "Could not detetermine base from coordinates!\n";
            exit;
        }

	# if it is an insertion
    } elsif($line[3] =~ /[0\*\-]/ig) {

		# if it is 0 based
        if($start == $end)
        {
			if($toBase == 0){
				$zero2zero_conversions++;
				print OUTPUT "$line[0]\t$start\t$end\t$tail";
				next;
			} elsif($toBase == 1){
				$zero2one_conversions++;
				$start = $start;
				$end = $end + 1;
				print OUTPUT "$line[0]\t$start\t$end\t$tail";
				next;
			} else {
				print STDERR "Argument supplied to --toBase is not 1 or 0\n";
				exit;
			}


		# if it is 1 based
        } elsif($start == $end -1){

			if($toBase == 0){
				$one2zero_conversions++;
				$start = $start;
				$end = $end - 1;
				print OUTPUT "$line[0]\t$start\t$end\t$tail";
				next;
			} elsif($toBase == 1){
				$one2one_conversions++;
				print OUTPUT "$line[0]\t$start\t$end\t$tail";
				next;
			} else {
				print STDERR "Argument supplied to --toBase is not 1 or 0\n";
				exit;
			}

		} else {
            print STDERR "Could not detetermine base from coordinates!\n";
            exit;
        }

	# if it is a deletion
    } elsif($line[4] =~ /[0\*\-]/ig) {

        $size = length $line[3];

		# if it is 0 based
        if($start + $size == $end)
        {
			if($toBase == 0){
				$zero2zero_conversions++;
				print OUTPUT "$line[0]\t$start\t$end\t$tail";
				next;
			} elsif($toBase == 1) {
				$zero2one_conversions++;
				$start = $start + 1;
				$end = $end;
				print OUTPUT "$line[0]\t$start\t$end\t$tail";
				next;
			}

		# if it is 1 based
        } elsif($end - $start  == $size - 1) {

			if($toBase == 0){
				$one2zero_conversions++;
				$start = $start -1;
				$end = $end;
				print OUTPUT "$line[0]\t$start\t$end\t$tail";
				next;
			} elsif($toBase == 1){
				$one2one_conversions++;
				print OUTPUT "$line[0]\t$start\t$end\t$tail";
				next;
			} else {
				print STDERR "Could not detetermine base from coordinates!\n";
				exit;
			}

        } else {
			print STDERR "Could not detetermine base from coordinates!\n";
            exit;
        }

    } else {
        print STDERR "Could not determine mutation type from coordinates!\n";
        exit;
    }
}

################################################################################
##################### close filhandle print results and exit ###################
print "Performed $zero2one_conversions 0-base to 1-base conversions!\n";
print "Performed $one2zero_conversions 1-base to 0-base conversions!\n";
print "Performed $zero2zero_conversions 0-base to 0-base conversions!\n";
print "Performed $one2one_conversions 1-base to 1-base conversions!\n";
close $output;
close $input;
exit;
