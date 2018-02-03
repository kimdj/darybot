import requests
from bs4 import BeautifulSoup
import sys

if len(sys.argv) == 1:                        # If no args exist, return immediately.
    exit(1)

payload = []                                  # The payload represents the word or phrase.
for i in xrange(1, len(sys.argv)):
    payload.append(sys.argv[i])
payload = ' '.join(payload)
payload = payload + ' meaning'

headers_Get = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:49.0) Gecko/20100101 Firefox/49.0',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1'
    }

def google(q):
    s = requests.Session()
    q = '+'.join(q.split())
    url = 'https://www.google.com/search?q=' + q + '&ie=utf-8&oe=utf-8'
    r = s.get(url, headers=headers_Get)

    soup = BeautifulSoup(r.text, "html.parser")
    output = []

    # print soup.find("div", {"class": "lr_container mod _rWq"}).prettify().encode('utf-8')
    dfn = soup.find("div", {"data-dobid": "dfn"}).span.contents
    # dfn = dfn[0].encode('utf-8')
    # print dfn
    result = ''
    for i in xrange(0, len(dfn)):
        result += dfn[i].encode('utf-8')
    if result == '':
        exit(1)
    print result


r = google(payload)

