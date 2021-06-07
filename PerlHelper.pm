package PerlHelper;

use strict;
use warnings;

my @modules = qw/Data::Dumper Memoize CPAN LWP::Simple URL::Encode Digest::MD5 Encode Path::Tiny Term::ANSIColor Capture::Tiny UI::Dialog/;
use Filter::Simple;
FILTER {
	$_ = "no warnings; ".join("\n", map { "use $_ qw//;" } @modules )."; use warnings; use strict; \n$_";
	_install_uninstalled_modules_from_string($_);
	return $_;
};

use Data::Dumper;
use Memoize;
use CPAN;
use LWP::Simple qw//;
use URL::Encode qw/url_encode url_decode/;
use Digest::MD5 qw/md5_hex/;
use Encode;
use Path::Tiny;
use Term::ANSIColor;
use Capture::Tiny ':all';
use UI::Dialog;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(myget debug warning error analyze_args Dumper dd memoize program_installed sys init_dialog derror dmsg dinput url_encode url_decode md5_hex is_root);



my %options = (
	debug => 0,
	myget_cache => '.myget_cache',
	die_on_error => 1
);

my $d = undef;

sub error (@) {
	foreach (@_) {
		warn color("on_red black").$_.color("reset")."\n";
	}
	if($options{die_on_error}) {
		exit 1;
	}
}

sub warning (@) {
	foreach (@_) {
		warn color("on_yellow black").$_.color("reset")."\n";
	}
}

sub debug (@) {
	if($options{debug}) {
		foreach (@_) {
			warn color("on_green black").$_.color("reset")."\n";
		}
	}
}

sub init_dialog {
	my $backtitle = shift // '';
	my $title = shift // '';
	$d = new UI::Dialog (
		backtitle => $backtitle, 
		title => $title,
		height => 35, 
		width => 65 , 
		listheight => 25,
		order => ['whiptail', 'gdialog', 'zenity', 'whiptail']
	);
}

sub dmsg ($) {
	my $message = shift;
	unless(defined $d) {
		warning "init_dialog has not been called";
		warn "$message";
	} else {
		$d->msgbox(text => $message);
	}
}

sub dinput {
	my ($text, $entry) = @_;
	debug "input($text, $entry)";
	my $result = undef;
	if(defined $d) {
		$result = $d->inputbox( text => $text, entry => $entry);
		if($d->rv()) {
			debug "You chose cancel. Exiting.";
			exit();
		}
	} else {
		warning "init_dialog has not been called";
		print "$text:\n";
		$result = <STDIN>;
		chomp $result;
	}
	return $result;
}

sub derror ($;$) {
	my $message = shift;
	my $no_exit = shift // 1;

	unless(defined $d) {
		warning "init_dialog has not been called";
	} else {
		$d->msgbox(text => $message);
	}

	debug "error($message, $no_exit)";
	warn color("red").$message.color("reset")."\n";
	if($no_exit != 1) {
		exit 1;
	}
}

sub no_die_on_error {
	$options{die_on_error} = 0;
}

sub die_on_error {
	$options{die_on_error} = 1;
}

sub enable_debug {
	$options{debug} = 1;
}

sub disable_debug {
	$options{debug} = 0;
}

sub get_myget_cache {
	$options{myget_cache};
}

sub set_myget_cache {
	$options{myget_cache} = shift;
}

sub myget {
	my $url = shift;
	debug "myget($url)";
	unless (-d $options{myget_cache}) {
		mkdir $options{myget_cache} or die("$!");
	}

	my $cache_file = $options{myget_cache}.'/'.md5_hex(Encode::encode_utf8($url));

	my $page = undef;

	if(-e $cache_file) {
		debug "`$cache_file` exists. Returning it.";
		$page = path($cache_file)->slurp;
	} else {
		debug "`$cache_file` Did not exist. Getting it...";
		$page = LWP::Simple::get($url);
		if($page) {
			open my $fh, '>', $cache_file;
			binmode($fh, ":utf8");
			print $fh $page;
			close $fh;
			debug "`$url` successfully downloaded.";
		} else {
			debug "`$url` could not be downloaded.";
		}
	}

	return $page;
}

sub dd (\%) {
	die Dumper shift;
}

sub analyze_args (\%\@\@){
	my $options = shift;
	my $parameters = shift;
	my $argv = shift;

	my %param_names = ();
	my %varnames = ();
	foreach my $param (@$parameters) {
		die "Doubly-defined varname name $param->{varname} in \@parameters\n" if(exists $varnames{$param->{varname}});
		$varnames{$param->{varname}} = 1;
		if(ref $param->{names} eq "ARRAY") {
			foreach my $name (@{$param->{names}}) {
				die "Doubly-defined parameter name $name in \@parameters\n" if(exists $param_names{$name});
				$param_names{$name} = 1;
			}
		} else {
			my $name = $param->{names};
			$param_names{$name} = 1;
			die "Doubly-defined parameter name $name in \@parameters\n" if(exists $param_names{$name});
		}
	}

	foreach my $param (@$parameters) {
		my @names = ();

		my $name = "";
		if(exists $param->{varname}) {
			$name = $param->{varname};
		} else {
			error "Cannot be used without varname";
		}

		if(ref $param->{names} eq "ARRAY") {
			@names = @{$param->{names}};
		} else {
			error "Invalid type for names";
		}

		if(exists $param->{type} && defined $param->{type} && $param->{type} eq "int") {
			$param->{regex} = qr/(\d+)$/;
			$param->{value} = '$1';
			$param->{type} = undef;
		}

		if(exists $param->{type} && defined $param->{type} && $param->{type} eq "float") {
			$param->{regex} = qr/(\d+(?:\.\d*)?)$/;
			$param->{value} = '$1';
			$param->{type} = undef;
		}


		if(exists $param->{type} && defined $param->{type} && $param->{type} eq "string") {
			$param->{regex} = qr/(.*)$/;
			$param->{value} = '$1';
			$param->{type} = undef;
		}

		if(exists $param->{regex}) {
			if(ref $param->{regex} eq "Regexp") {
				foreach my $arg (@$argv) {
					foreach my $this_param (@names) {
						my $this_re = qr/$this_param=$param->{regex}/;
						if($arg =~ m#^$this_param=#) {
							if($arg =~ m#$this_re#) {
								$options->{$param->{varname}} = eval $param->{value};
							} else {
								error "Invalid parameter for $this_param, does not match $param->{regex}";
							}
						}
					}
				}
			} else {
				error "Invalid data type for regex";
			}
		} else {
			if($param->{type} eq 'bool') {
				foreach my $arg (@$argv) {
					foreach my $this_param (@names) {
						if($arg eq $this_param) {
							$options->{$param->{varname}} = $param->{value};
						}
					}
				}
			} else {
				error "Undefined type $options->{type}";
			}
		}

		if(exists $param->{needed} && $param->{needed} && !defined $options->{$param->{varname}}) {
			error "Option ".join(", ", @names)." not set correctly";
		}

		if(exists $param->{checksub} && ref $param->{checksub} eq "CODE") {
			my $sub = \&{$param->{checksub}};
			$sub->($options->{$param->{varname}});
		}
	}
}

sub program_installed {
	my $program = shift;
	debug "program_installed($program)";

	my $exists = 0;
	my $ret = system(qq#which $program > /dev/null 2> /dev/null#);

	if($ret == 0) {
		debug "$program already installed";
		$exists = 1;
	} else {
		warning "$program does not seem to be installed. Please install it!";
	}

	return $exists;
}

sub sys ($) {
	my $command = shift;

	my ($stdout, $stderr, $exit) = capture {
		system($command);
	};

	return +{
		stdout => $stdout,
		stderr => $stderr,
		exit => $exit
	};
}

sub _install_uninstalled_modules_from_string {
	my $string = shift;

	my @uninstalled_modules = _get_uninstalled_modules_from_string($string);

	foreach my $module (@uninstalled_modules) {
		if(is_root()) {
			CPAN::Shell->install($module);
		} else {
			error "You must be root to install the missing module $module!";
			exit(1);
		}
	}
}

sub is_root {
	my $login = (getpwuid $>);
	if($login eq 'root') {
		return 1;
	} else {
		return 0;
	}
}

sub _get_uninstalled_modules_from_string {
	my $string = shift;
	my @modules = _get_modules_from_string($string);

	my @uninstalled_modules = ();
	foreach my $module (@modules) {
		eval "use $module qw//;";
		if($@) {
			push @uninstalled_modules, $module;
		}
	}
	return @uninstalled_modules;
}

sub _get_modules_from_string {
	my $string = shift;

	my @modules = ();

	while ($string =~ m#\buse\s+([A-Za-z0-9_:]+)(\b\s*(\s+.*?))?;#gism) {
		push @modules, $1;
	}

	return @modules;
}

1;
