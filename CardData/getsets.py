#extremely quick and dirty script to get sets from scryfall and put them into a format that can be loaded into sql.
import requests, json

r=requests.get("https://api.scryfall.com/sets/")
sets=(json.loads(r.text))["data"]
sets.reverse()
filep=open("allsets", "w")
for i in sets:
	filep.write('"'+i["code"]+'","'+i["name"]+'",\n')
