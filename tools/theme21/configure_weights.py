"""Bind frozen source values to own IDs, explicitly recording mapping confidence."""
import hashlib
import json
from pathlib import Path
from catalog import ROOT,GROUPS

# source index, source name, relation. Every number is read, never typed as a weight.
MAPS={
 'fruit':[
 (1,'Apple','same-kind'),(1101,'FruitBanana','same-kind'),(1101,'RedGrapes','same-kind'),
 (1101,'FruitOrange','same-kind'),(1101,'Strawberry','same-kind'),(1101,'GreenLimeSlice','form-proxy'),
 (1101,'Goose_Pear','goose-to-ordinary-adaptation'),(1101,'Cherries','same-kind'),(1101,'Goose_Coconut','rarity-proxy'),
 (1101,'FruitWatermelonSlice','form-proxy'),(1101,'Pineapple','same-kind'),(1101,'Goose_Peach','goose-to-ordinary-adaptation'),
 (1101,'Kiwi','same-kind'),(1101,'Goose_Mango','goose-to-ordinary-adaptation'),(1101,'Goose_Coconut','goose-to-ordinary-adaptation'),
 (1101,'Blueberry','same-kind'),(1101,'PitayaPiece','form-proxy'),(1101,'Avocado','same-kind'),
 (1101,'Pomegranate','same-kind'),(1101,'Persimmon','same-kind'),(1101,'Carambola','same-kind')],
 'antique':[
 (3,'GoldCoin','same-kind'),(3,'JadeBracelet3','same-kind'),(3,'JadeRock2','same-kind'),
 (3,'JadeCalabash2','same-kind'),(3,'JadeBracelet1','same-kind'),(3,'JadeTrigger','same-kind'),
 (3,'JadeSeal','same-kind'),(3,'JadeRuyi','same-kind'),(3,'Goose_JadeStone','rarity-proxy'),
 (3,'Goose_JadeBottle','goose-to-ordinary-adaptation'),(3,'JadePeanut','same-kind'),(3,'JadeCarp','same-kind'),
 (3,'JadeTiger','same-kind'),(3,'JadeTalisman','same-kind'),(3,'GoldRing','same-kind'),
 (3,'GoldChime','same-kind'),(3,'JadeChime','same-kind'),(103,'JD2LeafPendant','same-kind'),
 (103,'JD2Lock','same-kind'),(103,'JD2JadePot','same-kind'),(3,'Goose_JadeBeads','goose-to-ordinary-adaptation')],
 'farm':[
 (7,'Carrot_WetMarket','same-kind'),(7,'Corn_WetMarket','same-kind'),(7,'Eggplant_WetMarket','same-kind'),
 (1901,'80TinFrog','toy-to-animal-proxy'),(7,'Goose_Pumpkin','goose-to-ordinary-adaptation'),
 (7,'WhiteMushroom','same-kind'),(3,'JadeCarp','material-proxy'),(7,'LotusRoot','plant-form-proxy'),(5,'RoastChicken','animal-proxy'),
 (7,'Tomato_WetMarket','same-kind'),(7,'Potato_WetMarket','same-kind'),(7,'BigCabbage','same-kind'),
 (7,'Broccoli','same-kind'),(7,'BellPepper','same-kind'),(7,'BitterGourd','vegetable-form-proxy'),
 (7,'Goose_Onion','goose-to-ordinary-adaptation'),(7,'WhiteCarrot','same-kind'),(1,'CS_Garlic','same-kind'),
 (2,'SprayGreen1','container-proxy'),(4,'Egg2','same-kind'),(1,'WoodHand','tool-proxy')],
 'dessert':[
 (6,'CupCake1','same-kind'),(6,'Dount1','same-kind'),(6,'ToonIceCream','same-kind'),(6,'Macaron1','same-kind'),
 (6,'Cookie1','same-kind'),(6,'Cake1','same-kind'),(6,'Candy3','same-kind'),(6,'Pudding','same-kind'),(6,'Goose_Cake','pastry-proxy'),
 (6,'Chocolate','same-kind'),(6,'Lollipop1','same-kind'),(6,'ToonPopsicle1','same-kind'),(106,'TF2Wafer','same-kind'),
 (106,'Goose_TF2SwissRoll','goose-to-ordinary-adaptation'),(8,'Goose_EggTart','goose-to-ordinary-adaptation'),
 (5,'Goose_Pancake','goose-to-ordinary-adaptation'),(6,'Cookie3','pastry-proxy'),(5,'BBQToast','same-kind'),
 (8,'BFSoupDumpling','same-kind'),(6,'Goose_Cake','pastry-proxy'),(8,'BFCornJuice','drink-proxy')],
 'electronics':[
 (1901,'Goose_80DaGeDa','device-era-proxy'),(1901,'80GameConsole','device-proxy'),(1901,'80MovieCD','device-proxy'),
 (1901,'80Walkman','audio-proxy'),(1901,'80GameConsole','same-kind'),(1901,'80OldRadio','audio-proxy'),
 (1901,'80TinFrog','shape-proxy'),(1901,'80BBJi','wearable-proxy'),(1901,'80OldRadio','same-kind'),
 (1901,'80TV','display-proxy'),(1901,'80Abacus','input-proxy'),(1901,'80TV','display-proxy'),(1901,'80TV','same-kind'),
 (1901,'80UniversalCharger','device-proxy'),(1901,'80UniversalCharger','device-proxy'),(1901,'80FloppyDisk','storage-proxy'),
 (1901,'80UniversalCharger','power-proxy'),(1901,'80Telephone','audio-proxy'),(1901,'80GameConsole','device-proxy'),
 (1901,'80Flashlight','same-kind'),(1901,'80AlarmClock','same-kind')]
}

def main():
    file=ROOT/'competitor-analysis/artifacts/competitor-config-trace/serialized-verified/LevelData.json'
    rows=json.loads(file.read_text('utf-8'))['dataArray']
    catalog=ROOT/'projects/catch-big-goose-unity/Assets/Resources/Data/themes.json'
    data=json.loads(catalog.read_text('utf-8-sig'))
    history=ROOT/'work/theme21/before-themes.json';history.parent.mkdir(parents=True,exist_ok=True)
    if not history.exists():history.write_bytes(catalog.read_bytes())
    bindings=[]
    for theme in data['themes']:
        base=theme['items'][:9]
        ids=base+[r[0] for r in GROUPS[theme['id']]]
        assert len(ids)==len(set(ids))==21
        weights=[]
        for id,(index,name,relation) in zip(ids,MAPS[theme['id']]):
            matches=[r for r in rows if r['_index']==index and r['_level']==2 and name in r['_namelist'] and len(r['_namelist'])==len(r['_othertypeweight'])]
            assert matches,(id,index,name)
            # Prefer MainLevel where present, otherwise the source's special mode.
            row=next((r for r in matches if r['_gametype']=='MainLevel'),matches[0]);ordinal=row['_namelist'].index(name)
            weight=row['_othertypeweight'][ordinal];weights.append(weight)
            bindings.append(dict(theme=theme['id'],id=id,weight=weight,sourceTable='LevelData',sourceIndex=index,
                                 sourceGameType=row['_gametype'],sourceLevel=2,sourceName=name,sourceOrdinal=ordinal,
                                 sourceRow=next(i for i,r in enumerate(rows) if r is row),
                                 sourceHeight=row['_height'],sourceNormalCount=row['_sumcount'],
                                 valueConfidence='confirmed serialized source value',mappingConfidence='project adaptation: '+relation))
        theme['items']=ids;theme['coreGroupWeights']=weights
        theme['coreWeightEvidence']='themes-21-20261024: source values confirmed; own item mappings are adaptations'
    catalog.write_text(json.dumps(data,ensure_ascii=False,indent=2),'utf-8')
    report=dict(sourceSha256=hashlib.sha256(file.read_bytes()).hexdigest(),bindings=bindings,
                limits=['Values are actual frozen table values, not live account values',
                        'The per-theme combination and model mapping are project adaptations, not original source theme reproductions',
                        'Only core group quotas use these values; type inclusion remains equal-weight without replacement'])
    (ROOT/'work/theme21/weight-bindings.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),'utf-8')
    print('Configured',len(bindings),'source-backed quota bindings across five 21-item themes')

if __name__=='__main__':main()
