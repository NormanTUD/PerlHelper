use lib '.';
use PerlHelper;

my %options = ();

my @parameters = (
	{ # accepts "-p=10" or "--parameter=20" and saves 10 or 20 in $options{parameter}
		names => ["-p", "--parameter"],
		regex => qr/(\d+)$/,
		varname => "parameter",
		value => '$1',
		checksub => sub { my $arg = shift; error "undefined variable" unless defined $arg; error "ERROR: Value must be below 100" if $arg >= 100 }
	},
	{ # boolean switch for -d and --debug
		names => ["-d", "--debug"],
		varname => "debug",
		type => "bool",
		value => 1
	},
	{ # accept int, like -i=10, and sets $options{integer} to 10
		names => ["-i", "--integer"],
		varname => "integer",
		type => "int"
	},
	{ # accept float, like -i=10.5, and sets $options{float} to 10.5
		names => ["-f", "--float"],
		varname => "float",
		type => "float",
	},
	{ # accept string, like -s=asdasdas, and sets $options{string} to asdasdas
		names => ["-s", "--string"],
		varname => "string",
		type => "string",
	}
);
analyze_args %options, @parameters, @ARGV;
#dd %options;

warning "Warning";
PerlHelper::no_die_on_error();
error "Error";
PerlHelper::enable_debug();
debug "I am visible";
myget("https://google.de");
PerlHelper::disable_debug();
debug "I am NOT visible";
myget("https://google.de");
program_installed("ls");
program_installed("lsasdasdas");
warn Dumper sys "ls";
init_dialog("", "welt");
dmsg "hallo welt";
dinput "hallo welt", "a";
derror "hallo";
