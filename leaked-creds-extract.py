#!/usr/bin/python3.5
# AC - 2016-11-02
# extracts email credentials from saved leaked source html files

from lxml import html, etree
import sys

def extract_credential(node_list, strip_str):
    if len(node_list) == 0:
        return ""
    else: # return string without label and extraneous leakedsource whitespace
        return node_list[0].replace(strip_str, "", 1).rstrip()
    

def extract_leaked_source_email_creds(filename):
    parser = etree.HTMLParser()
    tree = etree.parse(filename, parser)

    # iterate through the right nodes and extract the credentials
    for credential_tables in tree.xpath("/html/body/center/center/table/tbody"):
        email = credential_tables.xpath("tr/td[contains(text(), 'email: ')]/text()")
        password = credential_tables.xpath("tr/td[contains(text(), 'Real_Password: ')]/text()")
        
	# print comma separated email and password pair to stdout
        sys.stdout.write("{},{}".format(extract_credential(email, 'email: '), \
                             extract_credential(password, 'Real_Password: ')))
        # TODO find where those first empty lines are coming from


# extract creds from each file indicated on the command line
filenames = sys.argv[1:]
if len(filenames) == 0:
    print("Usage: {} \033[1mFILENAME(s).html\033[0m".format(sys.argv[0]))
    exit(1)
    
for filename in filenames:
    extract_leaked_source_email_creds(filename)

    
    
