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

See `test.pl` for examples of all of those codes.

# List of not-exported available functions

`PerlHelper::enable_debug()`: Enables debug-output

`PerlHelper::disable_debug()`: Disables debug-output

`PerlHelper::set_myget_cache($path)`: Sets the `$options{myget_cache}`

`PerlHelper::get_myget_cache()`: Gets the current `$options{myget_cache}`-path

`PerlHelper::no_die_on_error()`: Disables dieying on error

`PerlHelper::die_on_error()`: Enables dieying on error

