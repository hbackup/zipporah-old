# data-selection
To make, do

./make.sh

To run, edit the config file and do 

./run.sh config

If you run this on the CLSP grid and do not want to fine-tune the sytem, you
only need to modify the following in the config file:

$working # working directory
$input   # input language
$output  # output language
$raw_stem_good  # raw good data file without the language suffix, to train lex files
                # if f2e and e2f are set then we don't need raw_stem_good

$raw_stem_bad  # the bad data to select from


$output_percent   $ percentage of data to select from bad data

The selected data is in $working/$id/step-6/*/train.??
