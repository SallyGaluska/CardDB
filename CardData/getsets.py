#extremely quick and dirty script to get sets from scryfall and put them into a format that can be loaded into sql.
import requests, json, csv

r=requests.get("https://api.scryfall.com/sets/")
sets=(json.loads(r.text))["data"]
sets.reverse()
filep=open("allsets", "w")
writer=csv.writer(filep)
for i in sets:
	writer.writerow([i["code"], i["name"]])
