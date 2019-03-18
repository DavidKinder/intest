Writing Intest Recipes.

A guide to writing in Delia, Intest's recipe language.

@h About test cases.
To use any of this, at least one test case is required, and there will
probably be many. The typical arrangement is that each test case has a
name -- say, "sorting" -- and comes with a file of input for the program
being tested -- say, |sorting.txt|. Intest therefore requires each test
case to be specified by a text file. (Its contents don't have to be the
input to the program, though, and there are even situations where it's
convenient to make it an empty text file existing only for the sake of
its name.)

So you need to create a text file for each test case. This should be
called |NAME.txt|, where |NAME| is the test case name. There are some
rules about these names:

(a) They are case-sensitive, so "Frogs" is different from "frogs". This
is true even if your file system is case-insensitive, as it probably is.
Your computer may regard |Frogs.txt| and |frogs.txt| as the same file,
but to Intest those names would refer to different cases. It follows
that you can't practicably have two case names which are the same except
for casing.

(b) The names |all|, |examples|, |extensions|, |problems|, |cases|, and
|maps| are reserved for Intest wildcards, and can't be used.

(c) A name cannot begin with a dash |-|, a caret |^|, a question mark |?|,
an exclamation mark |!|, an open bracket |(|, a square bracket |[|,
a full stop |.|, an underscore |_|, or a digit. It's probably best to
start with a letter.

(d) A name cannot consist only of a number or a single letter.

(e) A name cannot contain a colon or a slash, forwards or backwards, and
must contain only filename-safe characters. It can contain white space, but
your life will be easier if it doesn't. Similarly, best to avoid accented
letters or emoji.

If you are testing Inform 7, it is conventional that a test case name which
ends in |-G| is one needing to be compiled for the Glulx virtual machine,
and a name which ends in |-Z| needs to be compiled for the Z-machine.

@ There are five types of case, but three are used only for testing Inform 7,
and can be ignored by everybody else. The important ones are:

(a) "case" -- where the expectation is that the program being tested will
accept this test case and not produce errors, and

(b) "problem" -- where the expectation is that the program will reject it
with error messages.

The other three are:

(c) "example" -- a "case", but written into an Inform documentation file,
a format which takes a bit of decoding.

(d) "extension" -- a "case", but one of the examples from an Inform extension
file, a format which takes even more decoding.

(e) "map" -- a "case", but to do with spatial maps drawn out from Inform
source text, in a way not worth going into here.

@h Recipe files.
As previously noted, Intest needs a recipe file in order to run in any
useful fashion; by default, Intest expects to find this file at

	|PROJECT/Tests/PROJECT.intest|

where |PROJECT| is the name of the tested project's home directory. But
with the |-using| switch at the command line, an alternative file cam be
used somewhere else.

An Intest recipe file is a UTF-8 encoded text file. It is a list of commands
which, for the most part, tell Intest where to find test cases, and then
definitions of recipes, which Intest can then use to test them.

Here is a typical simple recipe file. It begins with a command, telling Intest
the location of a directory of test cases which will have type |case|, and
then gives a single recipe, which Intest will use on whatever cases it
discovered in that directory.

= (not code)
-cases 'inform7/kinds-test/Tests/Test Cases'

-recipe

	set: $A = $PATH/_Results_Actual/$CASE.txt
	set: $I = $PATH/_Results_Ideal/$CASE.txt

	step: inform7/kinds-test/Tangled/kinds-test -test-$CASE $PATH/$CASE.txt >$A 2>&1
	or: 'produced errors in kinds-test' $A

	show: $A

	exists: $I
	or: 'passed without errors but no blessed output existed'

	match text: $A $I
	or: 'produced incorrect output'

-end

@ As that example suggests, each line is a command, and each command begins
with a dash |-|, except that blank lines are ignored. So are comment lines,
beginning with exclamation marks |!|.

A recipe file normally begins by declaring where all the cases live:

|-case F|, where |F| is a filename. Make this a test case of type "case".
Similarly for |-problem|, |-example|, |-extension|, and |-map|.

|-cases D|, where |D| is a directory name. Make every validly named text file
in this directory a test case of type "case". Similarly for |-problems|,
|-examples|, |-extensions|, and |-maps|.

Each case has a recipe assigned to it. Often the same recipe will be assigned
to every case, but not all always. The recipe is by default the one called
just |[Recipe]| (see below), but declaring |-case [NAME] F|, |-cases [NAME] D|,
and so on, makes the recipe for those case(s) |[NAME]| instead.

@ A recipe file must also define at least one recipe. There are two ways
to do this:

|-recipe [NAME] FILE| says that the recipe |[NAME]| is defined in the given
text file. This is the old-fashioned way; experienced showed that it was
more convenient to write --

|-recipe [NAME]| followed by a definition written in the main file itself:

	|-recipe [NAME]|
	|    ...|
	|    ...|
	|-end|

where the definition occupies the lines in between the |-recipe| line and the
|-end| line. (Those lines in between are not commands and don't start with
dashes.)

If no |[NAME]| is given, the name is assumed to be just |[Recipe]|.

@ Those are the only essentials, but two other dashed commands exist:

|-set VARIABLE VALUE|. Variables are more usually set inside recipes, but
they can also be set here, as global variables whose values apply whatever
recipe is used. See the notes on variables in the section on recipes below.
(The variable, being global, will be called |$$VARIABLE| in Delia code.)

|-if PLATFORM| and |-endif|. Dashed commands in between these lines will be
followed only if the variable |$$platform| matches the value |PLATFORM|. This
value will be something like |osx|, |windows|, or |android|.

@h Writing Delia.
Recipe definitions are written in a very simple mini-language called Delia,
for reasons which English users of Intest will appreciate. Had Intest been
written by an American, it would have been called Julia.

In Delia, once again, blanks lines and lines beginning with exclamation
marks |!| are ignored. All other lines must have the form

	|command: token1 ... tokenN|

where different commands need different numbers of tokens. Most commands
are a single word, but a few are more than one. There are sometimes no
tokens at all, in which case no colon is required:

	|command|

The command and its tokens must occupy a single line and no comment is
allowed at the end of it. Quotation marks can be used to make multiple words
a single token; thus:

	|exists: 'My Tests/output.txt'|

is a command plus a single token, not two. A backslash can be used to escape
the quotation mark when inside quotes. A token which begins with a backtick,
|`thus|, is marked as not to be quoted: see below.

@ Delia has just one data structure, a set of named variables. Each of these
has a textual value; usually those represent filenames or parts of filenames,
but not necessarily.

There are a very few "global" variables, written with a double dollar sign.
Global means they have the same value regardless of which test case is being
worked on. One global is automatically defined: |$$platform|, as mentioned
above, which is a string such as |osx| or |windows|. It is always better
to avoid using this where possible. All other global variables are created
by the |-set| command at the top of the recipe file: see above.

Other variables are "local" and written with a single dollar sign. These have
different values for different test cases. For every Delia recipe, three are
automatically defined:

|$CASE| is the name of the test case;

|$PATH| is the pathname to the directory which the test case is in;

|$TYPE| is the type of test case this is: |case|, |problem|, |example|,
|extension| or |map|;

|$WORK| is the pathname of a directory set aside by Intest for any intermediate
files we might need to produce during the test process -- these must all be
temporary files we can happily lose when the test is completed. The real
usefulness of this comes when Intest is running a batch of tests across
multiple threads, because those threads each need their own independent work
area to avoid stepping on each other's feet. Provided the recipe uses |$WORK|,
it never needs to think about this complication.

@ The real usefulness of variables is that they are automatically substituted
into tokens. When Delia reads the token |$PATH/$CASE.txt|, for example,
it substitutes in the values of |$PATH| and |$CASE| to produce something
like |zap/Tests/planets.txt|. This process is called "expansion".

For example, when a new variable is created with:

	|set: $NAME = VALUE|

the |VALUE| is expanded before being written into the new variable |$NAME|.

A wrinkle here is that if the setting value has multiple tokens:

	|set: $NAME = VALUE1 VALUE2 ...|

then they are each "quote-expanded", rather than being simply "expanded".
This basically means that the value is meant to be used in place of a string
of tokens, rather than as a fragment or the whole of a single token.
For example:

	|set: $OPTIONS = -no-warnings -p=10 -to $FILE.txt|

sets the value to be

	|'-no-warnings' '-p=10' '-verbose' '-to' 'My File.txt'|

This precaution is in case, as happened in this example, expansion of one of
the tokens, |$FILE.txt|, brought in new white space -- here, the space between
"My" and "File".

Quote-expansion is not always what we want. For example, suppose we further
defined:

	|set: $MOREOPTIONS = $OPTIONS -lang=en-uk|

We would then get the value:

	|'\'-no-warnings\' \'-p=10\' \'-verbose\' \'-to\' \'My File.txt\'' '-lang=en-uk'|

which of course is wrong. We avoid this using a backtick to suppress quote
expansion of the first token:

	|set: $MOREOPTIONS = `$OPTIONS -lang=en-uk|

which gets it right:

	|'-no-warnings' '-p=10' '-verbose' '-to' 'My File.txt' '-lang=en-uk'|

Note that quote expansion respects the Unix shell redirection markers like
|>file| or |2>&1|, quoting just the file parts.

Quote-expansion also supports one more feature: the token |$[filename$]|
expands to the (tokenised and further expanded) contents of the file named.
Thus for example if the file |Frog.txt| contains the words "never turn your
back on a frog", then

	|$[Frog.txt$]|

will quote-expand to:

	|'never' 'turn' 'your' 'back' 'on' 'a' 'frog'|

@ Note that the filename is itself expanded before use, so that it can be
defined using variables. This can be very useful when we want to test a
program which takes its input mainly in the form of command-line arguments,
rather than from a file. See the example supplied with Intest for testing
"dc", the very old-school reverse Polish notation calculator supplied with
most Unix systems (including MacOS). In that example, a test case such as
|dc/Tests/Cases/plus.txt| contains what to put on the command line when
running dc:

	|-e '1 1 + p'|

The important step in the recipe for using this then reads:

	|step: dc $[$PATH/$CASE.txt$]|

and this causes Intest to run the command:

	|$ dc -e '1 1 + p'|

which produces the concise output "2".

@ A Delia recipe runs from the first line onwards. There are no loops,
functions or subroutines, but there are conditionals. The run ends
as soon as one of the three commands |pass|, |fail| and |or| is executed.

Testing consists mainly of running some programs, "steps", and then
checking that their output is correct, "matching". There are two sorts
of step:

|step: COMMAND|. Runs the shell command |COMMAND|. The step passes if the
command returns the exit code 0, which for Unix utilities conventionally
means that no errors occurred. It fails on all non-zero exit codes.

|fail step: COMMAND|. The same, but this time expecting a non-zero exit
code, and failing on zero.

What happens if a step "fails"? The answer is that nothing happens and
the recipe simply carries on, unless the next line is an |or:| command,
as we shall see next. So if the shell command doesn't follow Unix
conventions with its exit code, or if we just don't care, we needn't
worry that the test will halt. It will only do so on our explicit
instruction.

@ Matching simply means comparing the contents of two files.

|match text: A B|. Here |A| and |B| are text files, and Intest will show
diffs if they disagree.

|match binary: A B|. Now they are binaries, so Intest will simply report
that they disagree, if they do.

|match folder: A B|. This time they are folders (i.e., directories), and
Intest will expect the entire contents (other than any hidden files
beginning with |.|) to agree. This recurses downwards through any
subfolders.

All of these are commands which can pass or fail, so that they can be followed
by an |or| command taking effect only if they fail. If a test fails because
of a failed |match|, then the command line options |-diff| or |-bbdiff|
cause these tools to be invoked on |A| and |B|, the two matched files which
failed.

There are also three Inform-specific forms of matching: |match problem|,
|match frotz transcript| and |match glulxe transcript|, which are roughly
the same as |match text|, but display differences in a more contextual way.
Details here would be tiresome: see the Intest source code.

@ However, the |match| commands have a very useful side-effect if the test
is being run by |-curse|, |-bless| or |-rebless| at the command line. If we
are cursing, then |match text: A B| will delete |B|, the ideal form. If we
are blessing, then |match text: A B| will copy |A| into |B|, thus declaring
that the actual form this time should serve as ideal from now on.

@ |match| is also just a little forgiving, in that it allows a few not quite
equal texts to "match" each other. In particular:

On a |match text: A B|, a line of A and a line of B will match even if they
disagree about the decimal number appearing in a use of |/Tn/|, where |n|
is that number. For example, these two lines match:

	|Opened intest/Workspace/T4/intermediate.txt|
	|Opened intest/Workspace/T11/intermediate.txt|

This example should suggest why -- when Intest is spreading tests across
multiple processors, we cannot predict which thread number a test will run
on; and as a result, we cannot say which sandbox area of the file system
it is allowed to use. That may cause the program under test to print
output which will contain the thread number it is running on. But since
we want to verify that output, we need to allow such output to match. What
happens internally is that both lines are converted to

	|Opened intest/Workspace/Txx/intermediate.txt|

and then, of course, they match exactly. This makes runs of the same test
comparable even when the runs occur on different threads.

This is the only important case of "forgiveness": the others apply only
when matching forms of file specific to Inform. Those make similar
arrangements to ignore the exact build number of Inform when it leaks
out into I7 console output or into story file transcripts.

@ There is one other commonly used pass/fail command:

|exists: F|. This passes if the file at |F| exists on disc, and fails otherwise.
For example,

	|exists: $TRANSCRIPT|
	|or: 'no transcript was written'|

(When testing a program which doesn't return exit codes, sometimes the best
way to see whether it worked or not is to see whether it produced any output.)

@ These are the three main "stopping commands", which do cause the test to halt:

|pass: 'NOTE'|. Stops the test and marks it a success. The text |'NOTE'|
is optional, and is a summary used when Intest prints its results.

|fail: 'NOTE'|. Stops the test and marks it a failure. The text |'NOTE'|
is optional, and is a summary used when Intest prints its results.

|or: 'NOTE' FILE|. If the step performed immediately before this line
failed, this stops the whole test and marks it as a failure. The |FILE|,
which is optional, is then printed out when Intest describes what went
wrong. For example:

	|step: dc -e $EXPRESSION|
	|or: 'dc produced an error'|

@ But there are actually two others:

|show F|. Stops the test and prints out the file |F|, but only if the test
is being run by the |-show| command: otherwise, does nothing and carries on.

This is how we implement the |-show| command-line feature of Intest. Typically,
it's used to show the full console output from the program being tested. For
Inform testing only, there's a related:

|show i6: F|. The same, but for the |-show-i6| command instead of |-show|.

|show:| and |show i6:| both fail if the file |F| does not exist, and this
possibility can be picked up by placing an |or:| after them.

@ As noted above, Delia has no loops. But it does have one control construct:
an if/then/else command, working in the obvious way.

	|if matches: TOKEN EXPRESSION|
	|    ...|
	|else|
	|    ...|
	|endif|

The |else| clause is optional, and these conditionals can be nested in the
usual way.

What the test does is to expand both |TOKEN| and |EXPRESSION|, and then see
if the expanded token matches the regular expression defined by the expanded
expression. That can be just a simple textual match:

	|if matches: $CASE Balloons|

tests if the current test case name is "Balloons". On the other hand,

	|if matches: $CASE Party-%d+|

would match cases such as |Party-12|, because |%d+| is regular expression
syntax for "one or more digits here".

@ That's all of the important commands covered, but Delia has a small
miscellany of other features. It has a very limited ability to write to
the file system itself:

|copy: FROM TO|

copies a file. This should only be used to copy into the work area |$WORK|.

|mkdir: PATH|

ensures the existence of directory at the given |PATH|. (Again, this should
be used only to make subdirectories of |$WORK|.) There is intentionally no
|rm| command. You could fake this easily with |step: rm ...|, but don't
try to clean up the work area yourself: Intest will handle that automatically.

@ Suppose the program to be tested produces output which takes a long time
to verify the correctness of. (This is the case for Inform 7, because its
output needs to be fed through Inform 6 and then executed in a virtual
machine before any results can be seen. Both steps take a second or so,
and with 2000 tests and only 3600 seconds in an hour, that's significant.)

An obvious optimisation is to check that the intermediate output matches a
version already known to work. This is not as easy as it seems, though, if
that intermediate output is very large, and if the exact contents of the
output are allowed to change from time to time (provided that the end
functionality does not). Intest provides for this by allowing each test
case to perform one "hash", that is, reducing a text file to a hash code.
These hash codes are then cached between runs of Intest, which always
knows the last hash value found on a run of the test case which passed.

All of that is accomplished with two global variable settings and one
single command. Note that the two globals have to be set outside of Delia;
they aren't dependent on any single test case. They are:

|-set hash_utility HASHPROGRAM|, which tells Intest what program to use
in order to determine the hash: a good choice is |md5|, if it's available.
If this is not set, the Delia |hash| command (see below) does nothing.

|-set hash_cache FILE|, which tells Intest where to store known-good hash
values in between runs. If this is not set, hash values may be generated
but are not cached, so that there is little benefit.

|hash: FROM TO| takes a hash value of the file |FROM| and writes it into
a (very short) file |TO|. This is a pass/fail command, which means that it
can be followed by an |or:|, but perhaps unexpectedly, it fails if the
checksum is the same as the last time this checksum was performed for the
test case in question. That enables something like this:

	|hash: $I6SOURCE $WORK/checksum.txt|
	|or: 'passed (matching cached I6 known to work)'|

(Uniquely, the |or:| in this case causes the overall test to pass, not fail.)
Besides being written to the file, the hash value is also stored in the
local variable |$HASHCODE|.

@ And finally, a great convenience for testing Inform 7, but useless for
anything else:

|extract: FILE VM|. This extracts a clean copy of the Inform 7 source text in
the test case and stores it in the |FILE|. For a test case which is a |case|
or |problem|, that's simply a file copy, but for an |extension|, for example,
it's a non-trivial operation. |VM| should be the Inform virtual machine
in question, |Z| or |G|. If the |FILE| contains a command script, this is
automatically written into the local variable |$SCRIPT|.