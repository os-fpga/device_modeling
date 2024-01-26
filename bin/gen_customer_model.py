#!/usr/bin/env python3
"""
gen_customer_models.py

Convert the internal models to customer models:
  * strip out ifdef sections marked by RAPIDSILICON_INTERNAL

"""
import argparse
import sys
import os
import logging
import re

IFDEF_PAT = re.compile(r"^\s*\`ifdef(\s+)RAPIDSILICON_INTERNAL")
ELSE_PAT = re.compile(r"^\s*\`else(\s+)\/\/\s*RAPIDSILICON_INTERNAL")
ENDIF_PAT = re.compile(r"^\s*\`endif(\s+)\/\/\s*RAPIDSILICON_INTERNAL")



def main():
    """ main routine """

    parser = argparse.ArgumentParser(
        prog='ProgramName',
        description='What the program does',
        epilog='Text at bottom of help')

    parser.add_argument('--input', help="internal model")
    parser.add_argument('--output', help="customer model")
    parser.add_argument('--log')
    parser.add_argument('-v', '--verbose', action='store_true')  # on/off flag

    args = parser.parse_args()

    # set up logger
    module = os.path.splitext(os.path.basename(args.input))[0]
    logname = f"{module}.{os.path.splitext(os.path.basename(sys.argv[0]))[0]}.log"
    if args.log:
        logname = args.log

    #
    # set up logging
    #
    logger = logging.getLogger('main')
    logger.setLevel(logging.INFO)

    # create console handler
    log_ch = logging.StreamHandler()
    logger.addHandler(log_ch)

    # create file handler
    log_fh = logging.FileHandler(logname, mode='w')
    logger.addHandler(log_fh)

    with open(args.input, "r", encoding="utf-8") as internal_fh:
        lines = internal_fh.readlines()


    # open output file
    in_ifdef_section = False
    copy_line_to_output = True
    with open(args.output, "w+", encoding="utf-8") as customer_fh:

        for line in lines:
            # check for ifdef
            if re.match(IFDEF_PAT, line):
                in_ifdef_section = True
                copy_line_to_output = False
                continue

            # looking for else or endif
            if in_ifdef_section:
                if re.match(ELSE_PAT, line):
                    # finished the ifdef, starting else section
                    copy_line_to_output = True
                    continue
                if re.match(ENDIF_PAT, line):
                    # we are at end of ifdef-endif
                    in_ifdef_section = False
                    copy_line_to_output = True
                    continue

            #
            if copy_line_to_output:
                customer_fh.write(line)

# execute only if called directly
# otherwise, can import the modules for use.
if __name__=="__main__":
    main()
