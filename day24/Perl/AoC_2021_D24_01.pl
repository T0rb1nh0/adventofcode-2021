use strict;
use warnings FATAL => 'all';
use feature "say";
use File::Slurp;
use Data::Dumper;
use List::Util;
use POSIX;
#use bigint;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D24.txt');

#I[2]+ 7 == I[3]     2 + 7 = 9
#I[4]+ -4 == I[5]    9 - 4 = 5
#I[8]+ 1 == I[9]     8 + 1 = 9
#I[7]+ 6 == I[10]    3 + 6 = 9
#I[6]+ 8 == I[11]    1 + 8 = 9
#I[1]+ -2 == I[12]   9 - 2 = 7
#I[0]+ -8 == I[13]   9 - 8 = 1

#99299513899971

interpreted_bf_approach();

#generic_bf_approach();

sub interpreted_bf_approach {
	my $number = 99999999999999;

	my %x_addition = (
		0  => 14, #1
		1  => 15, #1
		2  => 15, #1
		3  => -6, #26
		4  => 14, #1
		5  => -4, #26
		6  => 15, #1
		7  => 15, #1
		8  => 11, #1
		9  => 0,  #26
		10 => 0,  #26
		11 => -3, #26
		12 => -9, #26
		13 => -9  #26
	);

	my %y_addition = (
		0  => 1,  #1
		1  => 7,  #1
		2  => 13, #1
		3  => 10, #26
		4  => 0,  #1
		5  => 13, #26
		6  => 11, #1
		7  => 6,  #1
		8  => 1,  #1
		9  => 7,  #26
		10 => 11, #26
		11 => 14, #26
		12 => 4,  #26
		13 => 10  #26
	);

	my %z_division = (
		0  => 1,
		1  => 1,
		2  => 1,
		3  => 26,
		4  => 1,
		5  => 26,
		6  => 1,
		7  => 1,
		8  => 1,
		9  => 26,
		10 => 26,
		11 => 26,
		12 => 26,
		13 => 26
	);

	while (--$number >= 11111111111111) {
		next if (index($number, "0") > -1);

		my @vars = (0, 0, 0);
		for my $i (0 .. length($number) - 1) {
			# Load w value
			$vars[0] = substr($number, $i, 1);

			# Generate x value
			$vars[1] = (($vars[2] % 26) + $x_addition{$i} != $vars[0]) ? 1 : 0;

			#Calculate final z
			$vars[2] += floor($vars[2] / $z_division{$i}) * (25 * $vars[1] + 1) + ($vars[0] + $y_addition{$i}) * $vars[1];
		}

		print "Result of $number is " . $vars[2] . "\r";
		last if !$vars[2];
	}
}

sub generic_bf_approach {
	my @vars;
	my %keys = ('w' => 0, 'x' => 1, 'y' => 2, 'z' => 3);
	my $number = 99999999999999;

	while (--$number >= 11111111111111) {
		next if (index($number, "0") > -1);
		my @numbers = split "", $number;

		@vars = (0, 0, 0, 0);

		foreach my $line (@puzzle) {
			$line =~ s/^\s+|\s+$//g;
			next unless $line;
			next unless $line =~ m/(inp|add|mul|div|mod|eql)\s([wxyz])(?:\s((?:-)?\d+|[wxyz]))?/;
			my ($operation, $a, $b) = ($1, $2, $3);
			$b //= '';
			if ($operation eq "inp") {
				$vars[$keys{$a}] = shift(@numbers);
			}
			elsif ($operation eq "add") {
				$vars[$keys{$a}] = $vars[$keys{$a}] + ($b !~ m/[wxyz]/ ? $b : $vars[$keys{$b}]);
			}
			elsif ($operation eq "mul") {
				$vars[$keys{$a}] = $vars[$keys{$a}] * ($b !~ m/[wxyz]/ ? $b : $vars[$keys{$b}]);
			}
			elsif ($operation eq "div") {
				next if ($b !~ m/[wxyz]/ ? $b : $vars[$keys{$b}]) == 0;
				$vars[$keys{$a}] = floor($vars[$keys{$a}] / ($b !~ m/[wxyz]/ ? $b : $vars[$keys{$b}]));
			}
			elsif ($operation eq "mod") {
				next if $vars[$keys{$a}] < 0;
				next if ($b !~ m/[wxyz]/ ? $b : $vars[$keys{$b}]) <= 0;
				$vars[$keys{$a}] = $vars[$keys{$a}] % ($b !~ m/[wxyz]/ ? $b : $vars[$keys{$b}]);
			}
			elsif ($operation eq "eql") {
				$vars[$keys{$a}] = ($vars[$keys{$a}] == ($b !~ m/[wxyz]/ ? $b : $vars[$keys{$b}])) ? 1 : 0;
			}
		}
		print "Result of $number is " . $vars[3] . "\r";
		last if !$vars[3];
	}
}