#!/usr/bin/env python3
"""
p4def_to_simv.py

Convert the specs to Verilog module definition.
"""
import argparse
import sys
import os
import logging
import re
import yaml


# pattern to match a bussed port, i.e. foo[WIDTH-1:0] will match
#    group(1) ==> "foo"
#    group(2) ==> "[WIDTH-1:0]"
BUSPORT_PAT = re.compile(r"(\S+)(\[\S+\])")

# pattern to match min/max field of range, i.e. "3 .. 18"
#    group(1) ==> "3"
#    group(2) ==> "18"
MINMAX_PAT = re.compile(r"([\d\.]+)\s+\.\.\s+([\d\.]+)")

def is_real_param(param):
    """ check to see if this is an integer """

    if 'range' in param:
        return True

    if 'type' in param and param['type'] == "integer":
        return True

    if 'type' in param and param['type'] == "real":
        return True

    return False

def is_vector_param(param):
    """ check to see if this is a vector """

    if 'vector' in param:
        return True

    return False

def gen_param_string(pdict):
    """ generate a parameter string for the dictionary"""

    param_list = pdict.keys()
    num_params = len(param_list)
    paramcount = 0
    output_str = ""
    for param in param_list:
        paramcount += 1
        param_str = ""


        vector_str = ""
        if 'vector' in pdict[param]:
            msb = int(pdict[param]['vector']) - 1
            vector_str = f"[{msb}:0] "

        if 'default' in pdict[param]:
            default = pdict[param]['default']
            if is_real_param(pdict[param]) or is_vector_param(pdict[param]):
                # integers and vectors don't need quotes
                param_str = f"  parameter {vector_str}{param} = {default}"
            else:
                param_str = f"  parameter {vector_str}{param} = \"{default}\""

        else:
            param_str = f"  parameter {param}"

        # Add suffix of description, if any.#
        # Include ',' if not last parameter
        if 'desc_above' in pdict[param]:
            if 'desc_below' in pdict[param]:
                print("")
            else:
                exit("****An error occured: Please specify desc_below along with desc_above****")

            # has description
            if paramcount != num_params:
                param_str = f" {pdict[param]['desc_above']}\n{param_str}, // {pdict[param]['desc']}\n {pdict[param]['desc_below']}\n"
            else:
                # last element
                param_str = f" {pdict[param]['desc_above']}\n{param_str} // {pdict[param]['desc']}\n {pdict[param]['desc_below']}\n"
        elif 'desc' in pdict[param]:
            # has description
            if paramcount != num_params:
                param_str = f"{param_str}, // {pdict[param]['desc']}\n"
            else:
                # last element
                param_str = f"{param_str} // {pdict[param]['desc']}\n"
        else:
            if paramcount != num_params:
                param_str = f"{param_str},\n"
            else:
                # last element
                param_str = f"{param_str}\n"

        output_str += param_str

    return output_str

def quoted_list(mylist):
    """ generate quotes around a list of values """

    return [ f"\"{str(elem)}\"" for elem in mylist ]

def str_list(mylist):
    """ generate string of list of values """

    return [ f"{str(elem)}" for elem in mylist ]

def is_numeric(pdict):
    """ determine whether a parameter is numeric """

    # if has range or vector element, it is numeric
    if ('range' in pdict) or ('vector' in pdict):
        return True

    # if there are no enumerations, then it must be numerical
    if 'values' not in pdict:
        return True

    # if every element in values: is an integer
    for elem in pdict['values']:
        if not isinstance(elem, int):
            return False

    return True

def needs_checking(spec_dict):
    """ returns true if we expect to write checking code """

    # no checking needed if there aren't any paraeters or properties
    if not 'parameters' in spec_dict and not 'properties' in spec_dict:
        return False

    # The following code mimics the actual code generating the checking code
    # If that code in the main routine is updated, this section needs to be updated
    if 'parameters' in spec_dict:
        for param in spec_dict["parameters"]:

            if 'range' in spec_dict["parameters"][param]:
                return True

            if 'vector' in spec_dict["parameters"][param]:
                # no error checking done for vector types
                continue

            if 'type' in spec_dict["parameters"][param] and spec_dict["parameters"][param]['type'] == "real":
                # no error checking done for vector types
                continue

            return True


    # The following code mimics the actual code generating the checking code
    # If that code in the main routine is updated, this section needs to be updated
    if 'properties' in spec_dict:
        for param in spec_dict["properties"]:

            # determine if property is numeric or not
            if 'range' in spec_dict["properties"][param]:
                return True

            if 'vector' in spec_dict["properties"][param]:
                # no error checking done for vector types
                continue

            if 'type' in spec_dict["properties"][param] and spec_dict["properties"][param]['type'] == "real":
                # no error checking done for vector types
                continue

            return True

    return False

def get_min_max(pdict, vartype="INT"):
    """ get min and max value of a numeric parameter """

    minval = 0
    maxval = 0
    if 'range' in pdict:

        matched = re.match(MINMAX_PAT,pdict['range'])

        if matched and vartype == "INT":
            minval = int(matched.group(1))
            maxval = int(matched.group(2))

        if matched and vartype == "REAL":
            minval = float(matched.group(1))
            maxval = float(matched.group(2))

    return (minval, maxval)

def generate_port_str(port):
    """ reprocess port in case it is bussed

    i.e. if we have port[foo], this will return "[foo] port"
    so it can be put into the module declaration cleanly"
    """

    matched = re.match(BUSPORT_PAT, port)
    if matched:
        busport = matched.group(2)
        portname = matched.group(1)
        return f"{busport} {portname}"

    return port


def insert_file(stream, filename):
    """ insert a file at the current file location"""

    with open(filename, "r", encoding="utf-8") as input_stream:
        stream.write(input_stream.read())

def main():
    """ main routine """

    parser = argparse.ArgumentParser(
        prog='ProgramName',
        description='What the program does',
        epilog='Text at bottom of help')

    parser.add_argument('--input', help="p4def spec file")
    parser.add_argument('--output', help="output file")
    parser.add_argument('--include', default=".", help="include directory that contains body of code")
    parser.add_argument('--log')
    parser.add_argument('-v', '--verbose', action='store_true')  # on/off flag

    args = parser.parse_args()

    # figure out module from filename
    module = os.path.splitext(os.path.basename(args.input))[0]
    # set up logger
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

    with open(args.input, "r", encoding="utf-8") as stream:
        spec_dict = yaml.safe_load(stream)

    # open output file
    with open(args.output, "w+", encoding="utf-8") as stream:

        name = spec_dict['name']

        # print header
        timescale = "1ns/1ps"
        if 'timescale' in spec_dict:
            timescale = spec_dict['timescale']

        stream.write(f"`timescale {timescale}\n")
        stream.write("`celldefine\n")
        stream.write("//\n")
        stream.write(f"// {name} simulation model\n")
        if 'desc' in spec_dict:
            stream.write(f"// {spec_dict['desc']}\n")
        stream.write("//\n")
        stream.write("// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.\n")
        stream.write("//\n")
        stream.write("\n")

        # look for $name.inc file from the include directory
        prologue_file = f"{args.include}/{name}.pro.v"
        if os.path.exists(prologue_file):
            insert_file(stream, prologue_file)
        else:
            msg = f"No prologue file {prologue_file} found"
            logger.info(msg)

        # module definition and parameters
        has_parameters = False
        has_properties = False

        if 'parameters' in spec_dict:
            has_parameters = True
        if 'properties' in spec_dict:
            has_properties = True

        # We can have the following cases:
        #   has both parameters and properties
        #   has parameters only
        #   has properties only
        #   has no parameters or properties

        param_str = ""
        if has_parameters:
            param_str = gen_param_string(spec_dict['parameters'])

        prop_str = ""
        if has_properties:
            prop_str = gen_param_string(spec_dict['properties'])

        outstr = ""
        if has_parameters and has_properties:
            outstr += f"module {name} #(\n    "
            outstr += param_str
            outstr += "`ifdef RAPIDSILICON_INTERNAL\n    ,"
            outstr += prop_str
            outstr += "`endif // RAPIDSILICON_INTERNAL\n"
            outstr += ") (\n"
            stream.write(outstr)

        if has_parameters and not has_properties:
            outstr += f"module {name} #(\n"
            outstr += param_str
            outstr += ") (\n"
            stream.write(outstr)

        if not has_parameters and has_properties:
            outstr += f"module {name}\n"
            outstr += "`ifdef RAPIDSILICON_INTERNAL\n    "
            outstr += "#(\n"
            outstr += prop_str
            outstr += ")\n"
            outstr += "`endif // RAPIDSILICON_INTERNAL\n"
            outstr += "(\n"
            stream.write(outstr)

        if not has_parameters and not has_properties:
            outstr += f"module {name} (\n"
            stream.write(outstr)

        #
        # Add ports
        #
        ports_list = spec_dict['ports'].keys()
        num_ports = len(ports_list)
        portcount = 0
        output_str = ""
        for port in ports_list:
            portcount += 1
            port_str = ""
            port_token = generate_port_str(port)

            # input port
            if spec_dict['ports'][port]["dir"] == "input":
                port_str += f"input {port_token}"

            # output port
            if spec_dict['ports'][port]["dir"] == "output":

                # check to see if it is reg type
                reg_str = ""
                default_str = ""
                if 'type' in spec_dict['ports'][port] and spec_dict['ports'][port]['type'] == "reg":
                    reg_str = "reg "

                    if 'default' in spec_dict['ports'][port]:
                        default_str = f" = {spec_dict['ports'][port]['default']}"

                # now build output port declaration
                port_str += f"output {reg_str}{port_token}{default_str}"

            # inout port
            if spec_dict['ports'][port]["dir"] == "inout":
                port_str += f"inout {port_token}"

            if 'desc' in spec_dict['ports'][port]:
                # there's a description
                if portcount != num_ports:
                    output_str += f"  {port_str}, // {spec_dict['ports'][port]['desc']}\n"
                else:
                    # this is the last port, no comma
                    output_str += f"  {port_str} // {spec_dict['ports'][port]['desc']}\n"
            else:
                if portcount != num_ports:
                    output_str += f"  {port_str},\n"
                else:
                    # this is the last port, no comma
                    output_str += f"  {port_str}\n"

        stream.write(f"{output_str}")
        stream.write(");\n")

        # insert user-generated code

        # look for $name.inc file from the include directory
        include_file = f"{args.include}/{name}.inc.v"
        if os.path.exists(include_file):
            insert_file(stream, include_file)
        else:
            msg = (f"No include file {include_file} found")
            logger.info(msg)
            stream.write("\n//\n")
            stream.write("// include user code here\n")
            stream.write("//\n")

        # parameter error checking
        if needs_checking(spec_dict):
            stream.write(" initial begin\n")


        if 'parameters' in spec_dict:
            for param in spec_dict["parameters"]:

                # we check only enum types (which have "values" key")
                #if 'values' not in spec_dict["parameters"][param]:
                #    continue

                # we skip checking code for parameters that have the 'nocheck' set to true
                if 'nocheck' in spec_dict["parameters"][param] and spec_dict["parameters"][param]["nocheck"] is True:
                    continue

                # here's what the code needs to look like
                #   case (WEAK_KEEPER)
                #     "NONE",
                #     "PULLUP",
                #     "PULLDOWN": begin end
                #     default: begin
                #       $display("\nError: I_BUF instance %m has parameter WEAK_KEEPER set to %s.  Valid values are NONE, PULLUP, PULLDOWN\n", WEAK_KEEPER);
                #       #1 $stop;
                #     end
                #   endcase

                if 'range' in spec_dict["parameters"][param]:
                    # determine if property is numeric or not
                    if 'type' in spec_dict["parameters"][param] and spec_dict["parameters"][param]['type'] == "real":
                        (minval, maxval) = get_min_max(spec_dict["parameters"][param], vartype="REAL")
                        format_char = "%f"
                    else:
                        (minval, maxval) = get_min_max(spec_dict["parameters"][param])
                        format_char = "%d"

                    stream.write(f"\n    if (({param} < {minval}) || ({param} > {maxval})) begin\n")
                    stream.write(f"       $fatal(1,\"{name} instance %m {param} set to incorrect value, {format_char}.  Values must be between {minval} and {maxval}.\", {param});\n")
                    stream.write("    end\n")
                    continue

                if 'vector' in spec_dict["parameters"][param]:
                    # no error checking done for vector types
                    continue

                if 'type' in spec_dict["parameters"][param] and spec_dict["parameters"][param]['type'] == "real":
                    # no error checking done for vector types
                    continue

                if 'type' in spec_dict["parameters"][param] and spec_dict["parameters"][param]['type'] == "integer":
                    value_list_for_case = ' ,\n      '.join(str_list(spec_dict["parameters"][param]["values"]))
                    format_char = "%d"
                else:
                    value_list_for_case = ' ,\n      '.join(quoted_list(spec_dict["parameters"][param]["values"]))
                    format_char = "%s"

                value_list_for_msg = ', '.join([str(element) for element in spec_dict["parameters"][param]["values"]])

                stream.write(f"    case({param})\n")
                stream.write(f"      {value_list_for_case}: begin end\n")
                stream.write("      default: begin\n")
                stream.write(f"        $fatal(1,\"\\nError: {name} instance %m has parameter {param} set to {format_char}.  Valid values are {value_list_for_msg}\\n\", {param});\n")
                stream.write("      end\n")
                stream.write("    endcase\n")


        # property checking
        if 'properties' in spec_dict:
            stream.write('\n`ifdef RAPIDSILICON_INTERNAL\n')
            for param in spec_dict["properties"]:

                # determine if property is numeric or not
                if 'range' in spec_dict["properties"][param]:
                    if 'type' in spec_dict["properties"][param] and spec_dict["properties"][param]['type'] == "real":
                        (minval, maxval) = get_min_max(spec_dict["properties"][param], vartype="REAL")
                        format_char = "%f"
                    else:
                        (minval, maxval) = get_min_max(spec_dict["properties"][param])
                        format_char = "%d"

                    stream.write(f"\n    if (({param} < {minval}) || ({param} > {maxval})) begin\n")
                    stream.write(f"       $fatal(1,\"{name} instance %m {param} set to incorrect value, {format_char}.  Values must be between {minval} and {maxval}.\", {param});\n")
                    stream.write("    end\n")
                    continue

                if 'vector' in spec_dict["properties"][param]:
                    # no error checking done for vector types
                    continue

                if 'type' in spec_dict["properties"][param] and spec_dict["properties"][param]['type'] == "real":
                    # no error checking done for vector types
                    continue

                if 'type' in spec_dict["properties"][param] and spec_dict["properties"][param]['type'] == "integer":
                    value_list_for_case = ' ,\n      '.join(str_list(spec_dict["properties"][param]["values"]))
                else:
                    value_list_for_case = ' ,\n      '.join(quoted_list(spec_dict["properties"][param]["values"]))

                value_list_for_msg = ', '.join([str(element) for element in spec_dict["properties"][param]["values"]])

                stream.write(f"\n    case({param})\n")
                stream.write(f"      {value_list_for_case}: begin end\n")
                stream.write("      default: begin\n")
                stream.write(f"        $fatal(1,\"\\nError: {name} instance %m has parameter {param} set to %s.  Valid values are {value_list_for_msg}\\n\", {param});\n")
                stream.write("      end\n")
                stream.write("    endcase\n")

            stream.write('`endif // RAPIDSILICON_INTERNAL\n')

        if needs_checking(spec_dict):
            stream.write("\n  end\n")

        # endmodule
        stream.write("\nendmodule\n")
        stream.write("`endcelldefine\n")


# execute only if called directly
# otherwise, can import the modules for use.
if __name__=="__main__":
    main()
