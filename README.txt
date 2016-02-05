Project Structure

Gelato
	|--bin/
	|	|--gparse
	|	|--gctrl
	|--lib/
	|	|--parser/
	|	|	|--exceptions/
	|	|	|	|--gelato_exceptions.rb
	|	|	|--operators/
	|	|	|	|--output_factory.rb
	|	|	|	|--file_operator.rb
	|	|	|	|--regexp_operator.rb
	|	|	|	|--logger_operator.rb
	|	|	|	|--timestamp_operator.rb
	|	|	|--configuration.rb
	|	|	|--data_storage.rb
	|	|	|--pattern.rb
	|	|	|--flavour.rb
	|	|	|--file_parser.rb
	|	|	|--input_file.rb
	|	|	|--main.rb
	|	|	|--opt_parser.rb
	|	|	|--pattern.rb
	|	|--controller/
	|	|	|--IGNORE THIS DIRECTORY FOR NOW
	|--test/
	|	|--misc/
	|	|--test_commandline_args.rb
	|	|--test_configuration_process.rb
	|	|--test_output_format.rb
	|	|--test_container,rb
	|	|--test_flavours.rb
	|	|--test_input_string_or_regexp.rb
	|--etc/
	|	|--default_configuration.json
	|--configs/
	|	|--EXAMPLE CONFIGURATION FILES

0. Introduction:

gparse is a tool that allows your to parse any text or log file by providing a .json format configuration file telling the program what to look for. By default, the parsed results are in .json and .csv format stored in your home directory. This tool makes data collection from tests outputs, system logs, etc easy and can be effortlessly integrated into your automation framework.


1. Installation:

git clone https://github.com/emchen39/gelatoparser.git into your installation directory

Set your system to include <INSTALL_PATH>/bin into your system PATH, now you can use gparse


2. Configuration files:

gparse needs a .json format configuration file in order to know what you want to parse from a file. Here's a template of what a configuration file might look like:
{
        "inputs": ["<INPUT FILES>"],

        "metadata": {
                "<NAME>": "<regexp(<INT>)=SOME PATTERN|or|SOME STRING LITERAL",
                "<MORE>": "<regexp(<INT>)=SOME PATTERN|or|SOME STRING LITERAL>"
        },


        "flavours": {
                "<SECTION NAME>" : {
                        "identifiers" : {
                                "<NAME>": "<regexp(<INT>)=SOME OTHER PATTERN|or|regexp(<INT>)=SOME OTHER PATTERN|or|...>",
                                "<MORE>": "<regexp(<INT>)=SOME OTHER PATTERN|or|regexp(<INT>)=SOME OTHER PATTERN|or|...>"
                        },

                        "triggers":     {
                                "<NAME>": "<regexp(<INT>)=SOME OTHER PATTERN|or|regexp(<INT>)=SOME OTHER PATTERN|or|...>"
                        }
                }
        },

        "output": "<OUTPUT FILE PATH>",
        "format": ["csv", "json"]
}

You may also find working examples of configuration files under <INSTALL_PATH>/configs/default_files


3. Regex:

In your configuration files, the regex follows the ruby regex ruls except that a character that needs to be escaped must be escaped with '\\'. To indicate that an expression is a regexp, you must preceed the expression with regexp(<INT>), where <INT> must either be left blank or an integer. <INT> tells gparse which backreference of the matching string to store into the output.


4. Calculating duration:

If the file you are interested in parsing is timestamped on every line (like any log files), you may be interested in knowing the elapsed time of each event (a line in the file). gparse handles converting timestamp into epoch and calculating the duration with the option --get-elapsed FORMAT. If you have this option specified, then gparse adds [elapsed DURATION] in front of each line of the file when you are parsing. Hence, you may include an identifier or trigger that parses for the DURATION from each line. Examples may be found in some of the configuration files under <INSTALL_PATH>/configs/default_files

