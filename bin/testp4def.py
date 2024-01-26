#!/usr/bin/env python3

import argparse
import yaml

def main():

    parser = argparse.ArgumentParser(
        prog='ProgramName',
        description='What the program does',
        epilog='Text at bottom of help')

    parser.add_argument('--input') 
    parser.add_argument('--output')
    parser.add_argument('-v', '--verbose',
                    action='store_true')  # on/off flag

    args = parser.parse_args()

    print("Called with --input %s and --output %s" % (args.input, args.output))

    mydict= dict()
    with open(args.input, "r") as fh:
        mydict = yaml.safe_load(fh)

    print(mydict)

# execute only if called directly
# otherwise, can import the modules for use.
if __name__=="__main__":
    main()
