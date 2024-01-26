#!/usr/bin/env python3
"""gen_model.py
This generates the black box models using Mako template.

We were originally going to move the sim models also to this system,
but I (George Chen) found no advantage over the original python
script.

"""
import argparse
import yaml

from mako.lookup import TemplateLookup
from mako.template import Template

def cmd_line_args():
    """
    Parse command line arguments
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("-m", "--makofile", help="Input mako template file")
    parser.add_argument("-o", "--outfile", help="Output file")
    parser.add_argument("-y", "--yaml", required=True, help="variables file", default=None)
    args = parser.parse_args()
    return args


def render_template_file(template_fname, result_fname, yaml_fname):
    """
    Render template with mako
    """
    # get the design data in the yaml file
    with open(yaml_fname, "r", encoding="UTF-8") as yaml_stream:
        design_dict = yaml.safe_load(yaml_stream)

    # get the mako template
    with open(template_fname, "r", encoding="UTF-8") as file_stream:
        template = Template(
            file_stream.read(),
            lookup=TemplateLookup(directories=["."]),
            strict_undefined=True,
        )


    # merge template with design data
    rendered = template.render(dd=design_dict)

    # write out the result
    with open(result_fname, "w", encoding="UTF-8") as file_stream:
        file_stream.write(rendered)


def main():
    """
    Main method
    """
    args = cmd_line_args()

    render_template_file(args.makofile, args.outfile, args.yaml)

if __name__ == "__main__":
    main()
