# trouve ce qu'il reste à traduire...

use strict;
use v5.10;

my %tph;
while (<bg2eetrans/*.tph>) { # lit les fichiers tph
	say "lecture $_...";
	open(F,$_) || die "peux pas lire $_\n";
	while (<F>) {
		$tph{$1} = 1 if (/^[ \t]*STRING_SET \~(\d+)/);
	}
	close(F);
}
open(F,"<us.tra") || die "peux pas lire us.tra";
while (<F>) {
	print if (/^\@(\d+)/ && !$tph{$1});
}
close(F);

