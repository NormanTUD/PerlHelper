# PerlHelper

This defines and exports some in my opinion useful perl functions. 

# List of exported functions

`myget($url)`: Downloads a given URL and caches the output in `$options{myget_cache}`-dir. 

`debug @messages`: Prints some messages to STDERR in green

`warning @messages`: Prints some messages to STDERR in orange

`error @messages`: Prints some messages to STDERR in red and exits

`analyze_args %options, @parameters, @ARGV`: Analyzes arguments and sets `%options` accordingly

`Dumper`: Data::Dumper's Dumper

`dd %hash`: Prints Dumper \%hash

`memoize 'subname'`: Memoizes the sub via Memoize

`sys $command`: Executes `$command` and returns it's stdout, stderr and exit-code in a hash

`init_dialog($backtitle, $title)`: Initializes Whiptail-Dialog

`derror($msg, $die_on_error)`: Displays a whiptail error message

`dmsg $message"`: Display a whiptail message

`dinput $message, $default"`: Display a whiptail input field with default value `$default`

`url_encode($param)`, `url_decode($param)` de- and encodes URL parameters

`md5_hex($param)`: Creates a hexadecimal md5 from `$param`

`is_root()`: true if you are root, false otherwise 

See `test.pl` for examples of all of those codes.

# List of not-exported available functions

`PerlHelper::enable_debug()`: Enables debug-output

`PerlHelper::disable_debug()`: Disables debug-output

`PerlHelper::set_myget_cache($path)`: Sets the `$options{myget_cache}`

`PerlHelper::get_myget_cache()`: Gets the current `$options{myget_cache}`-path

`PerlHelper::no_die_on_error()`: Disables dieying on error

`PerlHelper::die_on_error()`: Enables dieying on error

# Other features

When loading a module that does not exist, you will get an error message. Run the program again
with sudo-rights and it will be installed automagically from CPAN if available.

Also, you don't need to use `warnings`, `strict` and `autodie` anymore, as these are loaded automatically.
