## NOTE TO USER:  THIS TEMPLATE WAS NOT DEPLOYED
## THE REASON IS THAT IT IS JUST AS LONG AND EVEN HARDER TO READ THAN THE PURE PYTHON CODE
## p4def_to_simv.py.  It does work, but without the checking portion.
<%!
from time import strftime as time
import re
import os

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
        if 'desc' in pdict[param]:
            # has description
            if paramcount != num_params:
                param_str = f"{param_str}, // {pdict[param]['desc']}\n"
            else:
                # last element
                param_str = f"{param_str} // {pdict[param]['desc']}"
        else:
            if paramcount != num_params:
                param_str = f"{param_str},\n"
            else:
                # last element
                param_str = f"{param_str}"

        output_str += param_str

    return output_str

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

%>\
`timescale 1ns/1ps
`celldefine
//
// ${dd['name']} simulation model
% if 'desc' in dd:
// ${dd['desc']}
% endif
//
// Copyright (c) ${"%Y" | time} Rapid Silicon, Inc.  All rights reserved.
//
<%
    has_parameters = False
    has_properties = False

    if 'parameters' in dd:
        has_parameters = True
    if 'properties' in dd:
        has_properties = True

    param_str = ""
    if has_parameters:
        param_str = gen_param_string(dd['parameters'])

    prop_str = ""

    if has_properties:
        prop_str = gen_param_string(dd['properties'])
%>
##
## header depends on whether or not there are parameters and properties
##
## BOTH PARAMETERS and PROPERTIES
% if has_parameters and has_properties:
module ${dd['name']} #(
${param_str}
`ifdef RAPIDSILICON_INTERNAL
  , ${prop_str}
`endif // RAPIDSILICON_INTERNAL
) (
% endif
## ONLY PARAMETERS
% if has_parameters and not has_properties:
module ${dd['name']} #(
${param_str}
) (
% endif
## ONLY PROPERTIES
% if not has_parameters and has_properties:
module ${dd['name']}
`ifdef RAPIDSILICON_INTERNAL
#(
${prop_str}
)
`endif // RAPIDSILICON_INTERNAL
(
% endif
## NEITHER PARAMETERS NOR PROPERTIES
% if not has_parameters and not has_properties:
module ${dd['name']} (
% endif      
<%
  if 'ports' in dd:
        ports_list = dd['ports'].keys()
        num_ports = len(ports_list)
        portcount = 0
        output_str = ""
        for port in ports_list:
            portcount += 1
            port_str = ""
            port_token = generate_port_str(port)

            # input port
            if dd['ports'][port]["dir"] == "input":
                port_str += f"input {port_token}"

            # output port
            if dd['ports'][port]["dir"] == "output":

                # check to see if it is reg type
                reg_str = ""
                default_str = ""
                if 'type' in dd['ports'][port] and dd['ports'][port]['type'] == "reg":
                    reg_str = "reg "

                    if 'default' in dd['ports'][port]:
                        default_str = f" = {dd['ports'][port]['default']}"

                # now build output port declaration
                port_str += f"output {reg_str}{port_token}{default_str}"

            # inout port
            if dd['ports'][port]["dir"] == "inout":
                port_str += f"inout {port_token}"

            if 'desc' in dd['ports'][port]:
                # there's a description
                if portcount != num_ports:
                    output_str += f"  {port_str}, // {dd['ports'][port]['desc']}\n"
                else:
                    # this is the last port, no comma
                    output_str += f"  {port_str} // {dd['ports'][port]['desc']}\n"
            else:
                if portcount != num_ports:
                    output_str += f"  {port_str},\n"
                else:
                    # this is the last port, no comma
                    output_str += f"  {port_str}\n"

%>\
${output_str});
% if os.path.exists(f"/nfs_project/castor/gchen/workspaces/device_modeling/models_internal/verilog/inc/{dd['name']}.inc.v"):
<%include file="models_internal/verilog/inc/${dd['name']}.inc.v" />
% else:
//
// add user code here
//
% endif
endmodule
`endcelldefine
