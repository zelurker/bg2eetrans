# script pour désinstaller tous les mods weidu d'un coup !

use strict;
use v5.20;

my @mods;
while (<>) {
	if (/^\~(.+?)\~/) {
		my $mod = lc($1);
		if (!@mods || $mod ne $mods[$#mods]) {
			push @mods,$mod;
		}
	}
}
for (my $n=$#mods; $n>=0; $n--) {
	say "uninstall $mods[$n]...";
	system("weidu --uninstall $mods[$n]");
}
