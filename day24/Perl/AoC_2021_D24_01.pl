use strict;
use warnings FATAL => 'all';
use feature "say";
use File::Slurp;
use Data::Dumper;
use List::Util;
use POSIX;
use bigint;
use bigrat;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D24.txt');

my @vars = (0, 0, 0, 0);
my %keys = ('w' => 0, 'x' => 1, 'y' => 2, 'z' => 3);
my $number = 99999999999999;

while (--$number >= 11111111111111) {
	next if (index($number, "0") > -1);
	my @numbers = split "", $number;

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
	say "$number -> " . $vars[3];
	last if !$vars[3];
}