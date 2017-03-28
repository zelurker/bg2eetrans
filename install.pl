# réinstalle une liste de mods d'après un fichier weidu.log sauvé

use strict;
use v5.10;

my (%mods,@order);
while (<>) {
	next if (/BG2EETRANS/); # except bg2eetrans !
	if (/^\~(.+?)\~ #(\d) #(\d+)/) {
		my $mod = lc($1);
		my $lang = $2;
		my $part = $3;
		if (!$mods{$mod}) {
			$mods{$mod}->{lang} = $lang;
			$mods{$mod}->{parts} = [$part];
			push @order,$mod;
		} else {
			push @{$mods{$mod}->{parts}},$part;
		}
	}
}
foreach (@order) {
	my $mod = $_;
	my $lang = $mods{$_}->{lang};
	my $list = join(" ",@{$mods{$mod}->{parts}});
	say "install $mod $lang $list","\033]0;$mod\007";
	system "weidu $mod --language $lang --force-install-list $list";
}
