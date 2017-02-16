__author__ = 'bharta1'

import sys
import requests
import os

API_URL = "https://www.censys.io/api/v1"
UID = os.environ['CensysUID']
SECRET = os.environ['CensysSecret']
WEBSITE = os.environ['TARGETS']
subdomain_list = []

params = {'query' : WEBSITE}

res = requests.post(API_URL + "/search/ipv4", json = params, auth=(UID, SECRET))
if res.status_code != 200:
    print "error occurred: %s" % res.json()["error"]
    sys.exit(1)

payload = res.json()

for r in payload['results']:
    ip = r["ip"]
    protolist = r["protocols"]

    for p in protolist:
        port = p.split("/")[0]
        protocol = p.split("/")[1]
        res2 = requests.get(API_URL + ("/view/ipv4/%s" % ip), auth=(UID, SECRET))
        payload2 = res2.json()
        if port in payload2.keys():
            if protocol == "https":
                for name in payload2[port][protocol]['tls']['certificate']['parsed']['names']:
                    subdomain_list.append(name)


res = requests.post(API_URL + "/search/certificates", json = params, auth=(UID, SECRET))
if res.status_code != 200:
    print "error occurred: %s" % res.json()["error"]
    sys.exit(1)

payload = res.json()

for r in payload['results']:
    str = r["parsed.subject_dn"]
    subdomain_list.append(str[0].split("CN=")[1])

for subdomain in list(set(subdomain_list)):
    print subdomain
