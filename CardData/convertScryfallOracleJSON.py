import json, requests

#scryfall-oracle-cards.json downloaded at https://scryfall.com/docs/api/bulk-data
#thanks to scryfall for making this extremely disgusting script possible

def main():
    cardList=getCardListFromLocalFile("scryfall-oracle-cards.json")
    with open("AllCardsIncludingUnsets", "w") as out:
        for i in cardList:
            out.write('"'+i["name"]+'"\n')
 
def getCardListFromLocalFile(filename):
    filep=open(filename, "r")
    jsonobj=json.loads(filep.read())
    actualCards=[]
    for i in jsonobj:
        if ((i["layout"] in getListOfActualCardLayouts()) and i["oversized"]==False):
            actualCards.append(i)
    return actualCards

def getListOfActualCardLayouts():
    #this excludes planar cards, tokens, schemes, vanguards, and emblems, which aren't real magic cards.
    return ["normal", "split", "flip", "transform", "meld", "leveler", "saga", "augment", "host"]

if __name__=="__main__":
    main()

