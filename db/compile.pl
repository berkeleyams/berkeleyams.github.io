#!/usr/bin/perl

# Check for the flag saying this is the current semester
$cr=shift;
if($cr eq "-c") {$curr=1;$cr=shift}

# Check this is an .sdb file
$cr=~s/\.sdb$// or die "The script must be run on a .sdb file\n";

# Open the database file and read in the necessary header lines
open A,"$cr.sdb" or die "Can't open database file \"$cr\"\n";
$_=<A>;chomp;die "No semester title specified on line 1\n" unless /^Semester: *(.*)$/;$seme=$1;
die "Can't extract year from semester title\n" unless $seme=~/(20..)/;$year=$1;
$_=<A>;chomp;die "No location specified on line 2.\n" unless /^Usual location: *(.*)$/;$uloc=$1;
$_=<A>;chomp;die "No time specified on line 3.\n" unless /^Usual time: *(.*)$/;$utim=$1;
$_=<A>;chomp;die "No day specified on line 4.\n" unless /^Usual day: *(.*)$/;$uday=$1;

# Skip any blank lines and search for an initial date
while(<A>) {chomp;last unless /^$/;}
die "First main entry is not a date.\n" unless /^Date: *(.*)$/;
$date[0]=$1;

# Loop over the database entries
$i=0;
while(<A>) {

	# Remove newline and skip blank lines
	chomp;next if /^$/;

	# Remove trailing spaces, and skip incomplete entries
	s/[\t ]*$//;
	next if /:$/;

	# Analyze standard database entries
	$date[++$i]=$1, next if /^Date: *(.*)$/;
	$spkr[$i]=$1, next if /^Speaker: *(.*)$/;
	$affi[$i]=$1, next if /^Affiliation: *(.*)$/;
	$titl[$i]=$1, next if /^Title: *(.*)$/;
	$note[$i]=$1, next if /^Note: *(.*)$/;
	$ntlk[$i]=$1, next if /^No talk: *(.*)$/;
	$time[$i]=$1, next if /^Time: *(.*)$/;
	$loca[$i]=$1, next if /^Location: *(.*)$/;
	$host[$i]=$1, next if /^Host: *(.*)$/;

	# Analyze abstracts
	if(/<(html_|)abstract>/) {
		$h=$1;
		$html[$i]=$h eq "html_"?1:0;
		die "<${h}abstract> tag does not appear on a line by itself $!" unless /^<${h}abstract>$/;
		$abst[$i]=$html[$i]==1?"":"<p>";
		$bl=0;
		while(<A>) {

			# Check for incorrect abstract tag matching
			die "Duplicate <$1abstract> tag detected\n" if /<(html_|)abstract>/;
			if (/<\/(html_|)abstract>/) {
				if($html[$i]==0) {
					die "<abstract> field ended with </html_abstract>\n" if $1 eq "html_";
					last;
				} else {
					die "<html_abstract> field ended with </abstract>\n" if $1 eq "";
					last;
				}
			}
			
			if($html[$i]==0) {
				htmlfix($_);
				if($_ eq "\n") {$_="</p><p>\n" if $bl==0;$bl=1;} else {$bl=0;}
			}
			$abst[$i].=$_;
		}
		$abst[$i].="</p>\n" if $html[$i]==0;
		next;
	}

	# Give an error if the line can't be processed
	die "Can't interpret database line:\n$_\n";
}
close A;

# For entries with titles and abstracts, compute the filename for the abstract
# HTML file
for $t (0..$i) {
	next if defined $ntlk[$t];
	next unless defined $spkr[$t] && defined $titl[$t] && defined $abst[$t];
	$_=$spkr[$t];

	# Remove umlauts and apostrophes
	s/&(.)uml;/$1/g;
	s/'//g;
	m/ ([A-Za-z]*)$/ or die "Can't interpret speaker name \"$spkr[$t]\".\n";
	$fn=lc $1;

	# Check for duplicate filenames, adding a number to repeated entries
	$fc{$fn}++;
	$file[$t]=$fc{$fn}==1?$fn:$fn.$fc{$fn};
	print "$file[$t]\n";
}

# Get numerical user and group IDs for permissions
$user=`whoami`;chomp $user;
(undef,undef,$uid)=getpwnam $user;
(undef,undef,$gid)=getgrnam "web";

# Create index page, reading in the HTML template file
mkdir "../$cr";
chmod 0775,"../$cr";
chown $uid,$gid,"../$cr";
open A,"template.html";
open B,">../$cr/index.html";
while(<A>) {
	last if /BODY/;
	s/TITLE/UC Berkeley \/ LBL Applied Math Seminar/;
	print B;
}
print B "<h4 class=\"top\">$seme Schedule</h4>\n";

# If this is the current schedule, add in a line about the time and place
if($curr==1) {
	$_="<p>Unless otherwise noted, all seminars are on ${uday}s from $utim in $uloc.<br> <br> To subscribe to our mailing list, <a href=\"https://groups.google.com/a/lists.berkeley.edu/forum/#!forum/appliedmathseminar/join\">click here</a>.<br>";
#	$_="<p>Unless otherwise noted, all seminars are on ${uday}s from $utim in $uloc.<br>*This week's applied math seminar is joint with the math department colloquium.  </p>\n";
	htmlfix($_);
	print B;
}

# Print the index table
print B "<table class=\"talks\">\n";
foreach $t (0..$i) {
	print B "<tr><td class=\"date\">$date[$t]:";

	# If the $note field is specified, add in a small note under the date
	if(defined $note[$t]) {
		print B "<br /><span class=\"alter\">$note[$t]</span>";
	}
	if(defined $host[$t]) {
		print B "<br /><span class=\"alter\">(Host:$host[$t])</span>";
	}
	print B "</td><td>";

	if(defined $ntlk[$t]) {
		
		# If the no talk field is specified, just give it and move on
		print B "<b>$ntlk[$t]</b>";
	} else {

		if(defined $spkr[$t]) {
			
			# Print speaker and affilation if available 
			print B "<b>$spkr[$t]</b>";
			htmlfix($affi[$t]);
			print B ", $affi[$t]" if defined $affi[$t];

			# If the title and abstract are specifed, write it and
			# link to the abstract file
			if(defined $titl[$t]) {
				print B "<br />";
				htmlfix($titl[$t]);
				if(defined $abst[$t]) {
					print B "<a href=\"$cr/$file[$t].html\">$titl[$t]</a>";
				} else {
					print B "$titl[$t]";
				}
			}
			
		} else {
			print B "<b>TBA</b>";
		}

	}
	print B "</td></tr>\n";
}
print B "</table>\n";

# Add index if this is the current 
if($curr==1) {
	open C,"sched.html" or die "Can't open sched.html\n";
	print B while <C>;
	close C;
}
print B while <A>;	
close A;
close B;
chmod 0775,"../$cr/index.html";
chown $uid,$gid,"../$cr/index.html";

# Create the abstract files
foreach $t (0..$i) {
	next if defined $ntlk[$t];
	next unless defined $spkr[$t] && defined $titl[$t] && defined $abst[$t];
	open A,"template.html";
	open B,">../$cr/$file[$t].html";
	while(<A>) {
		last if /BODY/;
		s/TITLE/UCB\/LBL Applied Math Seminar &#8211; $spkr[$t] &#8211; $titl[$t]/;
		print B;
	}
	print B "<h4 class=\"top\">$titl[$t]</h4>\n";
	print B "<h5><b>$spkr[$t], $affi[$t]</b></h5>\n<h5>$date[$t], $year at ";
	
	# Use the usual time and date, unless they have been overridden
	$_=(defined $time[$t]?$time[$t]:$utim)." in ".(defined $loca[$t]?$loca[$t]:$uloc)."</h5>\n";
	htmlfix($_);

	# If the location is Evans Hall, provide a map link
	s/Evans Hall/Evans Hall <a href="http:\/\/www.berkeley.edu\/map\/maps\/BC45.html">[Map]<\/a>/;
	print B;
	print B "$abst[$t]\n";
	print B while <A>;
	close A;
	close B;
	chmod 0775,"../$cr/$file[$t].html";
	chown $uid,$gid,"../$cr/$file[$t].html";
}

# If this is the current semester, create a master symlink to this semester's
# index page
if($curr==1) {
	symlink "$cr/index.html","../index.html";
	chmod 0775,"../index.html";
	chown $uid,$gid,"../index.html";
}

# Miscellaneous substitutions that can be applied to strings to make them
# nicer-looking in HTML 
sub htmlfix {
	@_[0]=~s/DAMTP/<acronym title="Department of Applied Mathematics and Theoretical Physics">DAMTP<\/acronym>/g;
	@_[0]=~s/&/&amp;/g;
	@_[0]=~s/---/&mdash;/g;
	@_[0]=~s/--/&ndash;/g;
	@_[0]=~s/``/&#8220;/g;
	@_[0]=~s/''/&#8221;/g;
	@_[0]=~s/_/&nbsp;/g;
	@_[0]=~s/(i\.e\.|e\.g\.)/<i>$1<\/i>/;
}
