# réinstalle une liste de mods d'après un fichier weidu.log sauvé

use strict;
use v5.10;

my (@mods);
while (<>) {
	next if (/BG2EETRANS/); # except bg2eetrans !
	if (/^\~(.+?)\~ #(\d) #(\d+)/) {
		my $mod = lc($1);
		my $lang = $2;
		my $part = $3;
		if (@mods && $mods[$#mods][0] eq $mod) {
			$mods[$#mods][2] .= " $part";
		} else {
			push @mods,[$mod,$lang,$part];
		}
	}
}
foreach (@mods) {
	my ($mod,$lang,$list) = @$_;
	say "install $mod $lang $list","\033]0;$mod\007";
	system "weidu $mod --language $lang --force-install-list $list";
}
