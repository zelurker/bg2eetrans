#!/usr/bin/perl

use strict;
use Data::Dumper;
use v5.20;

my %types = (
	"two-handed" => "Arme à 2 mains",
	"one-handed" => "Arme à 1 main",
);

my %prof = (
	"longbow" => "Arc long",
	"club" => "Gourdin",
	"flail/morning star" => "Fléau / Etoile du matin",
	"mace" => "Masse",
	"quarterstaff" => "Bâton",
	"bastard sword" => "Epée bâtarde",
	"two-handed sword" => "Epée à 2 mains",
	"crossbow" => "Arbalète",
	"shortbow" => "Arc court",
	"sling" => "Fronde",
	"axe" => "Hache",
	"long sword" => "Epée longue",
	"war hammer" => "Marteau de guerre",
	"dagger" => "Dague",
	"halberd" => "Hallebarde",
	"spear" => "Lance",
	"katana" => "Katana",
	"short sword" => "Epée courte",
	"scimitar/wakizashi/ninjatō" => "Cimeterre/Wakizashi/Ninjatō",
	"dart" => "Fléchette",
);

my (@us,@fr);
read_tra("us.tra",\@us);
read_tra("bg2eetrans/language/fr_fr/dialogtob.tra",\@fr);
my $fin = shift @ARGV;
my $debut = 0;
$debut = $fin if ($fin);
$fin = $#fr if (!$fin);
open(F,"<bg2eetrans/tob.tph") || die "reading tob.tph\n";
open(G,">bg2eetrans/tob2.tph") || die "writing tob2.tph\n";
open(H,">bg2eetrans/language/fr_fr/dialog.tra") || die "writing dialog.tra\n";
for (my $n=$debut; $n<=$fin; $n++) {
	while (<F>) {
		last if (/[\~ ]$n[\~ ]/);
	}
	my $input = $_;
	my %params = parse_us($us[$n]);
	my $prof = undef;
	$prof = $params{prof};
	my $type = $params{type};
	if ($prof && !$prof{$prof}) {
		print "n=$n prof $prof $prof{$prof}.\n";
		last;
	}
	if ($type && !$types{$type}) {
		print "n=$n type $type\n";
		last;
	}

	if ($params{reste}) {
		print "n=$n ",Dumper(\%params),"\n";
	}
	if (%params && $fr[$n] ne "~~") {
		if ($input =~ /Text/i || $input =~ /^\/\//) {
			print "revalidating $n\n";
		}
		print G "\tSTRING_SET ~$n~ \@$n\n";
		print H sprintf("@%-6d",$n),"= ",translate($fr[$n],\%params),"\n";
	} else {
		print G $input;
		print H sprintf("@%-6d",$n),"= $fr[$n]\n";
	}
}
close(F);
close(G);
close(H);

sub trans_degats {
	trans_save(); #  if (/Save /);
	s/vs\./contre/gi;
	s/piercing/perforant/i;
	s/cold-using creatures/les créatures utilisant le froid/;
	s/ damage//;
	s/slashing/tranchant/i;
	s/missile/projectile/i;
	s/crushing attacks/attaques contondantes/;
	s/crushing/contondant/i;
	s/piercing/perforant/i;
	s/whichever is better/selon ce qui est le mieux/;
	s/shapeshifters/les métamorphes/;
	s/cold/de froid/;
	s/fire/de feu/;
	s/acid/d'acide/;
	s/poison/de poison/ if (!/le poison/);
	s/electrical/électrique/;
	s/regenerating creatures/les créatures qui régénèrent/;
	s/undead/les morts vivants/;
	s/upon impact/à l'impact/;
	s/seconds/secondes/;
}

sub trans_save {
	# s/Hit target must save vs. Death or take (\d+) point of damage every (\d+) seconds until (\d+) Hit Points of damage has been inflicted/La cible touchée doit réussir un JS contre la mort ou prendre $1 point de dégât toutes les $2 secondes jusqu'à ce que $3 points de dégâts aient été infligés/;
	s/all enemies in a (.+?) radius /tout ennemi dans un rayon de $1 /i;
	s/resistance to fire, cold, and electricity/résistance au feu, au froid, et à l'électricité/;
	s/resistance to fire/résistance au feu/;
	s/resistance to all magical damage/résistance à tout dégât magique/;
	s/resistance to missile damage/résistance aux dégâts de projectiles/;
	s/resistance to/résistance à/;
	s/Flesh to Stone/Pétrification/;
	s/Fireball: (\d+)% chance per hit that a (.+?) fireball explodes, centered on the target/Boule de Feu : $1% de chances par coup qu'une boule de feu de $2 explose, centrée sur la cible/;
	s/Immunity to hold and paralysis/Immunité contre paralysie et étourdir/;
	s/Immunity to 1st and 2nd-level spells/Immunité aux sorts de 1er et 2nd niveau/;
	s/Immunity to charm and domination spells/Immunité contre les sorts de charmes et de domination/i;
	s/Immunity to spells of 5th level and below/Immunité aux sorts de 5ème niveau et en dessous/;
	s/Immunity to charm, confusion/Immunité contre le charme, la confusion/;
	s/Immunity to charm, confusion, domination, and hold/Immunité aux charmes, à la confusion, la domination, et la paralysie/;
	s/Immunity to charm/Immunité contre les charmes/;
	s/Immunity to disease and poison/Immunité à la maladie et au poison/;
	s/Immunity to slow and stun/Immunité au ralentissement et à l'étourdissement/;
	s/Immunity to confusion/Immunité à la confusion/;
	s/Immunity to /Immunité contre /;
	s/ hold/ la paralysie/; # attention aux conflits sur celui là !
	s/Inflicts damage upon the wielder and heals the target/Inflige des dégâts au porteur et soigne la cible/;
	s/Protects the wielder from any magics that adversely affect movement, such as Hold and Web/Protège le porteur de toute magie ayant un effet négatif sur le mouvement, comme paralysie ou toile d'araignée/;
	s/Hit target's movement rate is slowed by (\d+) for (\d+) seconds/La vitesse de déplacement de la cible touchée est réduite de $1 pendant $2 secondes/;
	s/Hit target /La cible touchée /;
	s/takes (\d+) points of poison damage per round for (\d+) rounds/prend $1 points de dégâts de poison par round pendant $2 rounds/;
	s/(suffers|takes) 1 point of poison damage per second for (\d+) seconds/prend 1 point de dégât de poison par seconde pendant $2 secondes/;
	s/must save vs. /doit rééusir un JS contre /;
	s/Target /La cible /;
	s/All struck ogres/Tout ogre frappé/;
	s/Any Bard hit/Tout barde touché/;
	s/Poison or suffer (\d+) points of damage per second for (\d+) seconds/le poison ou subir $1 points de dégâts par seconde pendant $2s/i;
	s/Death or lose (\d+)% of its maximum Hit Points within (\d+) seconds/la mort ou perdre $1% de ses points de vie maximum en $2 secondes/;
	s/Death or take (\d+) points of poison damage in (\d+) seconds/la mort ou prendre $1 points de dégâts de poison pendant $2 secondes/;
	s/Spell or be stunned for (\d) rounds/les sorts ou être étourdie pendant $1 rounds/;
	s/have their AC penalized by (\d) and their THAC0 by (\d) for (\d+) seconds/avoir leur CA pénalisée de $1 et leur THAC0 de $2 pendant $3 secondes/;
	s/Polymorph or be turned into a squirrel permanently/la métamorphose ou être transformée en écureuil pour toujours/;
	s/be held for (\d+) rounds/être paralysée pendant $1 rounds/;
	s/take (.+?) points of de magieal damage/prendre $1 points de dégâts magiques/;
	s/panic for (\d+) rounds/paniquer pendant $1 rounds/;
	s/flee in terror for (\d) rounds/fuir de panique pendant $1 rounds/;
	s/Save vs\. /Jet de sauvegarde contre /i;
	s/Petrification\/Polymorph/la pétrification \/ la métamorphose/;
	s/Spellcasting is not disabled/Le lancer de sorts est permis/i;
	s/Spell/les sorts/i;
	s/Breath/le souffle/i;
	s/Death/la Mort/i;
	s/Wand/les baguettes/i;
	s/negates/annule/;
	s/for none/pour aucun/;
	s/for half/pour la moitié/;
	s/ at ([\+\-]\d)/ à $1/;
	s/ and / et /i;
	s/ or / ou /;
	s/Undead/Mort vivant/;
	s/be destroyed/être détruit/;
	s/be rendered unconscious for /être rendu inconscient pendant /;
	s/be utterly destroyed/être complètement détruit/;
	s/be turned to stone/être pétrifié/;
	s/ die/ mourir/;
	s/penalty/de pénalité/;
}

sub trans_duree {
	s/Duration ?:/Durée :/;
	s/turn/tour/;
	s/second/seconde/ if (!/seconde/);
	s/hour/heure/;
	s/ per / par /;
}

sub trans_charge() {
	s/Creates a globe of anti-magic around the target: Spells cannot be cast from the inside or to the outside of the globe, and all magical effects affecting the target are dispelled/Crée un globe d'anti-magie autour de la cible : aucun sort ne peut être lancé de l'intérieur ou de l'extérieur du globe, et tous les effets magiques affectant la cible sont dissipés/;
	s/Causes enemies to run in fear unless they save vs. Spell/fait fuir les ennemis en courant à moins qu'ils réussissent un JS contre les sorts/;
	s/all physical attacks made by undead creatures/toute attque physique venant d'une créature mort vivante/;
	s/Wearer is immune to/Le porteur est immunisé contre/;
	s/is immune to/est immunisée contre/;
	s/ person / personne /i;
	s/Causes the wielder to go berserk/Rend le porteur enragé/;
	s/Fully heals the imbiber/Soigne complètement le buveur/;
	s/Causes imbiber to run at the first sign of trouble/Fait s'enfuir le buveur au 1er signe de problème/;
	s/Dégâts Resistance ?: \+50% against all forms of magical non-physical damage/Résistance aux dégâts : +50% contre toutes formes de dégâts magique et non physique/;
	s/gaze attacks/attaques de regard/;
	s/Renders the target immune to poison et neutralizes any poison already affecting the target/Rend la cible immunisée au poison et neutralise tout poison l'affectant déjà/;
	s/Restores /Réstaure /;
	s/1 magic missile will strike the target/1 projectile magique va frapper la cible/;
	s/attack rates/vitesse d'attaque/;
	s/disease/les maladies/;
	s/heals/soigne/;
	s/Heals 1 Hit Point/Soigne d'1 Point de Vie/;
 	s/Slays creatures with 1-4 HD; creatures with 5-6 HD /Tue les créatures avec 1-4 DV ; toute créature avec 5-6 DV /;
	s/Target receives/La cible reçoit/;
	s/Can cast/Peut lancer/;
	s/Immune to/Immunisé contre/;
	s/level drain/l'absorption de niveau/;
	s/sleep/le sommeil/;
	s/fear/la peur/;
	s/panic/la panique/;
	s/Detect Alignment/Détecter l'alignement/;
	s/hold/paralysie/;
	s/stun/étourdir/;
	s/sleep/dormir/;
	s/feeblemind/Débilité mentale/i;
	s/petrification/la pétrification/;
	s/Mirror Image/Image mirroir/i;
	s/Glitterdust/Poussière scintillante/;
	s/Glass Dust/Poussière de verre/i;
	s/Blur/Flou/;
	s/Horror/Horreur/;
	s/Cures Poison/Soigne le poison/i;
	s/Randomly cast Fireball, Cone of Cold, or Lightning Bolt/Lance au hasard boule de feu, cône de froid, ou éclair foudroyant/;
	s/Agannazar's Scorcher/Incinérateur d'Agannazar/;
	s/Cloudkill/Nuage de la mort/;
	s/Cone of Cold/Cone de Froid/;
	s/35-ft. cone with 90-deg. arc/cone de 10m avec un arc de 90°/;
	s/ HD / DV /;
	s/ of monsters/ de monstres/;
	s/Stun target/Etourdir la cible/;
	s/Ram /Bélier /;
	s/Special ?:/Spécial :/;
	s/Pushes target away from user/Repousse la cible loin de l'utilisateur/i;
	s/Blindness/Aveuglement/i;
	s/Stone to Flesh/Transmutation de la pierre en chair/i;
	s/Djinni/un Djinn/;
	s/Summons? /Invoquer /;
	s/Flamestrike/Colonne de feu/;
	s/Lesser Fire Elemental/un élémentaire de feu mineur/i;
	s/Lesser Air Elemental/un élémentaire d'air mineur/i;
	s/Lesser Earth Elemental/un élémentaire de terre mineur/i;
	s/Fire Elemental/un élémentaire de feu/i;
	s/Air Elemental/un élémentaire d'air/i;
	s/Earth Elemental/un élémentaire de terre/i;
	s/Death Spell/Sort de Mort/i;
	s/Slays creatures with fewer than (\d) Hit Dice/Tue les créatures avec moins de $1 dé de vie/;
	s/fire/de feu/;
	s/magic/de magie/ if (!/magic(ien|s)/);
	s/cold/de froid/;
	s/Dire Charm/Charme néfaste/;
	s/ Charm/ Charme/i if (!/Charme/);
	s/Prevents/Empêche/;
	s/once per day/1 fois par jour/;
	s/twice per day/2 fois par jour/;
	if (/(\d+)[ \-]ft\./) {
		my $range = int($1*3/10);
		s/(\d+)[ \-]ft\./$range\m/;
	}
	s/Range ?:/Portée :/;
	s/Touch/Toucher/;
	s/Visual range of the user/Portée visuelle de l'utilisateur/i;
	s/The caster/Le lanceur/;
	s/Shield/Bouclier/;
	s/Armor Class ?:/Classe d'armure :/;
	s/bonus vs. missile/en + contre les projectiles/;
	s/Area of Effect ?: (\d+) creature(s?)/Zone d'effet : $1 créature$2/;
	s/Area of Effect ?: The wearer/Zone d'effet : le porteur/;
	s/Area of Effect ?:/Zone d'effet :/;
	s/radius/de rayon/;
	s/Missile Blast/Explosion/i;
	trans_duree();
	s/onece per day/1 fois par jour/;
	s/Fireball/Boule de feu/;
	s/Prismatic Spray/Vaporisation Prismatique/;
	s/Effects vary as per the (\d)th-level wizard spell/Les effets varient comme pour le sort de magicien de $1ème niveau/;
	s/Sunray/Rayon de Soleil/;
	s/Improved Invisibility/Invisibilité Majeure/i;
	s/Invisibility, 10' radius/Invisibilité sur 3m/i;
	s/Invisibility/Invisibilité/i;
	s/three times per day/3 fois par jour/;
	s/Improved Haste/Hâte améliorée/;
	s/Immunity to Magic Missile/Immunité contre projectile magique/;
	s/Protection From Normal Missiles/Protection contre les projectiles normaux/;
	s/Damage ?:/Dégâts :/;
	s/be blinded for /être aveuglé pendant /;
	s/An additional (.+?) points of damage per level of caster/$1 points de dégâts de + par niveau du lanceur/;
	s/Raised by 1 point permanently/+1 point pour toujours/;
	s/The book is consumed upon use/Le livre disparait après usage/;
	s/Usage ?: Place into quick item slot/Utilisation : placez dans Objets Rapides/;
	s/Wearer/Le porteur/;
	trans_save();
	trans_duree();
	$_;
}

sub trans_eq() {
	if (/(\d+) ft\./) {
		my $range = int($1*3/10);
		s/(\d+) ft./$range\m/;
	}
	s/resistance to slashing, piercing, and crushing damage/résistance aux dégâts tranchants, perçants, et contondants/;
	s/Can memorize one extra 2nd-level wizard spell/Peut mémoriser 1 sort de magicien de 2ème niveau en +/;
	s/Can memorize one extra 5th- and one extra 6th-level divine spell/Peut mémoriser 1 sort divin de + de 5ème et de 6ème niveau/;
	s/vs. lycanthropes/contre les loups garous/;
	s/Open Locks/Crochetage des serrures/;
	s/Protects against all forms of panic/Protège contre toute forme de panique/;
	s/Casting failure/Echec de lancement de sort/;
	s/boosts morale/booste le moral/;
	s/1 attack per round at (\d+) THAC0 for (.+)/1 attaque\/round à THAC0 $1 faisant $2 de dégâts/;
	s/(\d) attacks per round at (\d+) THAC0 for (.+) damage/$1 attaques\/round à THAC0 $2 faisant $3 de dégâts/;
	s/(\d) attacks per round at (\d+) THAC0 for (.+)/$1 attaques\/round à THAC0 $2 faisant $3 de dégâts/;
	s/Find Traps/Détection des pièges/;
	s/Pick Pockets/Vol à la tire/;
	s/Detect Illusion/Détection des illusions/;
	s/Detect Traps/Détection des pièges/;
	s/Luck/Chance/;
	s/Set Traps/Poser des pièges/;
	s/Spellcasting is not diabled/Le lancement de sorts est toujours possible/i;
	s/Infravision up to/Infravision jusqu'à/;
	s/The wearer is immune to everything, magical and otherwise, that affects mobility in any way. This includes Haste and Slow spells./Le porteur est immunisé à tout ce qui, magique ou non, pourrait affecter sa mobilité, y compris les sorts de hâte et de ralentissement./;
	s/Armor Class/Classe d'armure/;
	s/Launcher/Lanceur/;
	foreach my $key (keys %prof) {
		s/$key/$prof{$key}/i;
	}
	s/Bow/Arc/;
	s/Saving Throws/Jets de sauvegarde/;
	s/Magic Resistance/Résistance magique/;
	s/Fire Resistance/Résistance au feu/;
	s/Acid Resistance/Résistance à l'acide/;
	s/No protection against missile and piercing attacks/Pas de protection contre les attaques perforantes et les projectiles/;
	s/No protection against missile attacks/Pas de protection contre les attaques de projectiles/;
	s/Cold Resistance/Résistance au froid/;
	s/Electrical Resistance/Résistance à l'électricité/;
	s/Hide in Shadows/Se cacher dans l'ombre/i;
	s/Move silently/Se déplacer silencieusement/i;
	s/with missile weapons/avec les armes à projectiles/;
	s/Protects against critical hits/Protège des coups critiques/;
	s/when attacking with fists/pour l'attaque avec les poings/i;
	s/May only be removed with a Remove Curse spell/Ne peut être enlevé qu'avec un sort de délivrance de la malédiction/i;
	s/through the destruction of the mastery orb/par la destruction de l'orbe de maitrise/;
	s/Regenerate (\d+) (HP|Hit Points?) every (\d+) seconds/Régénère $1 PV toutes les $3 secondes/;
	s/Regenerate (\d+) (HP|Hit Points?) every (\d+) rounds/Régénère $1 PV tous les $3 rounds/;
	s/Regenerate (\d+) (HP|Hit Points?) per /Régénère $1 PV par /;
	s/Dexterity/Dextérité/;
	s/Stone Giant Strength/Force de Géant de Pierre/;
	s/Hill Giant Strength/Force de géant des Collines/;
	s/Frost Giant Strength/Force de géant du froid/;
	s/Cloud Giant Strength/Force de géant des nuages/;
	s/Storm Giant Strength/Force de géant des tempêtes/;
	s/Fire Giant Strength/Force de géant du feu/;
	s/Strength/Force/;
	s/Special Abilities/Capacités spéciales/;
	s/Wisdom/Sagesse/;
	s/Hit Points/Points de Vie/i;
	s/Charisma/Charisme/;
	s/Stealth/Furtivité/;
	s/(\d+)% chance of spellcasting failure/$1% de chances d'échouer à lancer un sort/;
	s/Can memorize one extra 5th-level spell, one extra 6th-level spell, and one extra 7th-level spell/Confère un sort de cinquième niveau, un sort de sixième niveau et un sort de septième niveau de plus/;
	s/Can memorize one extra divine spell of each level from 1st to 4th/Accorde un sort divin supplémentaire de chaque niveau (du 1er au 4ème)/;
	s/Intelligence and Sagesse scores are set to (\d+)/Les scores d'intelligence et de sagesse sont fixés à $1/;
	s/Doubles movement rate/Double la vitesse de déplacement/;
	s/ movement / vitesse de déplacement /;
	s/Doubles /Double /;
	s/vs. missile attacks/contre les projectiles/;
	s/vs. slashing attacks/contre les armes tranchantes/;
	s/vs. missile and piercing attacks/contre les armes perforantes/;
	s/vs. crushing attacks/contre les armes contondantes/;
	s/an extra/et encore/;
	s/Negative Plane Protection/Protection contre le plan négatif/i;
	s/Physical damage resistance/Résistance aux dégâts physiques/i;
	s/Damage/Dégâts/;
	s/Polymorph into a wolf at will/Métamorphose en loup à volonté/;
	s/Non-detectable by magical means such as Detect Invisibility and scrying/indétectable par des moyens magiques tels que détection de l'invisiblité ou scrutation/i;
	s/While hidden or invisible, the wearer is/Quand caché ou invisible, le porteur est/;
	s/(\d+) points of magic damage to any who damage the wielder/$1 points de dégâts magiques à quiconque blesse le porteur/;
	s/:/ :/;
	trans_charge();
	$_;
}

sub translate {
	my ($desc,$p) = @_;
	$desc =~ s/(PARAM|CARACT).+//s;
	$desc =~ s/\~$//;
	$desc .= "\n" if ($desc !~ /\n$/s); # Ajoute un retour charriot
	$desc .= "\n" if ($desc !~ /\n\n$/s); # Ajoute une ligne vide
	$desc .= "PARAMÈTRES :\n\n";
	my $old = $desc;
	if ($p->{eq}) {
		$desc .= "Capacités quand équipé :\n";
		foreach (@{$p->{eq}}) {
			trans_eq();
			$desc .= "$_\n";
		}
		$desc .= "\n";
	}

	if ($p->{combat}) {
		$desc .= "Capacités de combat :\n";
		foreach (@{$p->{combat}}) {
			s/With every hit, it has a (\d+)% chance of draining (\d+) levels from the target and healing the wielder by (\d+) Hit Points as well as hasting <PRO_HIMHER> for (\d+) seconds and increasing <PRO_HISHER> Strength by (\d+) points for (\d+) seconds/A chaque coup, a une chance de $1% de drainer $2 niveaux de la cible et de soigner le porteur de $3 Points de Vie, de l'accélérer pour $4 secondes et d'augmenter sa force de $5 points port $7 secondes/;
			s/Deals an additional 10 electrical damage when thrown/Inflige 10 dégâts éléctriques supplémentaires quand lancé(e)/;
			s/Struck earth elementals must save vs. spell or be destroyed/L'élémentaire de terre touché doit réussir un JS contre les sorts ou être détruit/;
			s/Returns to the wielder's hand when thrown/Retourne à la main du porteur quand lancé(e)/;
			s/1 extra attack per round/1 attaque supplémentaire par round/;
			s/Each hit heals the wielder (\d) Hit Point/Chaque coup soigne le porteur de $1 PV/;
			s/When no bullets are equipped, the sling fires missiles that are treated as \+5 for the purposes of determining what enemies they can damage. The missiles receive \+5 to hit, including the bonus listed below, and deal a total of (.+?) missile damage/Quand aucune munition n'est équipée, la fronde tire des projectiles qui sont traités comme des +5 pour déterminer quels ennemis peuvent être touchés. Le projectiles reçoivent +5 pour toucher, incluant les bonus listés ci-dessous, et infligent un total de $2 dégâts de projectile/;
			trans_save();
			$desc .= "$_\n";
		}
		$desc .= "\n";
	}

	if ($p->{charge}) {
		$desc .= "Capacités de charge :\n";
		foreach (@{$p->{charge}}) {
			trans_charge();
			$desc .= "$_\n";
		}
		$desc .= "\n";
	}

	if ($p->{ac}) {
		$_ = $p->{ac};
		trans_degats();
		$desc .= "Classe d'armure : $_\n";
	}
	if ($p->{thac0}) {
		$_ = $p->{thac0};
		trans_degats();
		$desc .= "THAC0 : $_\n";
	}
	if ($p->{dam}) {
		$_ = $p->{dam};
		trans_degats();
		$desc .= "Dégâts : $_\n";
	}
	if ($p->{dt}) {
		$_ = $p->{dt};
		trans_degats();
		$desc .= "Type de dégâts : $_\n";
	}
	$desc .= "Facteur de vitesse : $p->{speed}\n" if ($p->{speed});
	$desc .= "Type de compétence : ".$prof{$p->{prof}}."\n" if ($p->{prof});
	$desc .= "Type : ".$types{$p->{type}}."\n" if ($p->{type});
	$desc .= "Nécessite :\n" if ($p->{req});
	foreach (@{$p->{req}}) {
		s/(\d+) Strength/Force $1/i;
		$desc .= "$_\n";
	}
	if ($p->{reste}) { # Normalement devrait plus y en avoir ici...
		foreach (@{$p->{reste}}) {
			s/Immunity to psionics/Immunité aux attaques psioniques/;
			s/Damage type/Type de dégât/;
			s/melee/mêlée/;
			s/thrown/lancé/i;
			s/Slashing/Tranchant/;
			s/Missile/Projectile/;
			trans_charge();
			trans_degats();
			trans_eq();
			$desc .= "$_\n";
		}
	}
	if (defined($p->{poids})) {
		$desc .= "\n" if ($desc ne $old && $desc !~ /\n\n$/s);
		$desc .= "Poids : $p->{poids}\n";
	}
	$desc =~ s/\n$/\~/s;
	$desc;
}

sub parse_us {
	$_ = shift;
	my %p;
	s/\~$//;
	s/^\~//;
	my $req = 0;
	my @req = ();
	my @reste = ();
	my $stat = 0;
	my $eq = 0;
	my $combat = 0;
	my @combat;
	my @eq = ();
	my ($charge,@charge) = ();
	foreach (split /\n/,$_) {
		for($_) {
			$stat = 1 when /^STATISTICS/;
			$p{thac0} = $1 when /^THAC0 ?\: *(.+)/i;
			$p{speed} = $1 when /^Speed Factor: *(.+)/i;
			$p{prof} = $1 when /^Proficiency Type: *(.+?) *$/i;
			$p{dt} = $1 when /^Damage Type: *(.+)/i;
			$p{type} = lc($1) when /^Type: *(.+)/i;
			$p{poids} = $1 when /^Weight: *(.+)/i;
			$p{dam} = $1 when /^Damage: *(.+)/i;
			$p{ac} = $1 when /^Armor Class: *(.+)/i;
			$eq = 1 when /^Equipped abilities:/i;
			$charge = 1 when /^Charge abilities:/i;
			$combat = 1 when /^Combat abilities:/i;
			$req = 1 when /^Requires:/;
			when ("") { $req = $eq = $combat = 0; }
			default {
				if ($req) {
					push @req,$_;
				} elsif ($eq) {
					push @eq,$_;
				} elsif ($combat) {
					push @combat,$_;
				} elsif ($charge) {
					push @charge,$_;
				} elsif ($stat) {
					push @reste,$_;
				}
			}
		}

	}
	$p{prof} =~ tr/[A-Z]/[a-z]/ if ($p{prof}); # ne pas utiliser lc sur le o du ninjato !
	$p{req} = \@req if (@req);
	for (my $n=0; $n<=$#reste; $n++) {
		if ($reste[$n] =~ /(Speed Factor|Proficiency Type):( *)$/) {
			splice @reste,$n,1;
			redo;
		}
	}
	$p{reste} = \@reste if (@reste);
	$p{eq} = \@eq if (@eq);
	$p{combat} = \@combat if (@combat);
	$p{charge} = \@charge if (@charge);
	%p;
}

sub read_tra {
	my ($name,$tab) = @_;
	open(G,"<$name") || die "read_tra: $name\n";
	while (<G>) {
		next if (/^\/\//);
		while (!/\~$/ && !/\]$/) {
			$_ .= <G>;
		}
		chomp;
		if (/^\@(\d+) += (.+)/s) {
			$$tab[$1] = $2;
		}
	}
	close(G);
}

