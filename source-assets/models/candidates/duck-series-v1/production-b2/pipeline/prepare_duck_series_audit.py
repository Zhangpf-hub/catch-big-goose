"""Extend the previously verified three-model Unity audit to the production roster."""
import json
from pathlib import Path
from duck_series_catalog import ROOT,OUT,CATALOG
p=Path(__file__).with_name('DuckB2UnityAudit.cs');s=p.read_text('utf-8')
s=s.replace('// Isolated editor audit. This is intentionally not installed into the live game.','// Production import and independent natural PhysX audit for all twenty approved-family models.')
s=s.replace('public static class DuckB2UnityAudit','public static class DuckSeriesUnityAudit')
s=s.replace('Isolated Unity editor: imported FBX/materials, baked skin vertices and manual PhysX simulation. Not production game/tray/match or homepage acceptance.','Actual production Unity imports/materials, baked animation vertices and an independent 60-body natural PhysX arena. Runtime game/home checks are in the player report.')
s=s.replace('static readonly string[] Ids={"duck-eggtart","duck-steelcup","duck-numberblock"};','static string[] Ids=>CatchGoose.Editor.GooseDuckProduction.Ids;')
s=s.replace('public static void Run()','public static bool Run()')
s=s.replace('output=Path.GetFullPath("audit-output");','output=Path.Combine(CatchGoose.Editor.GooseDuckProduction.Output,"editor");')
s=s.replace('            PlayerSettings.colorSpace=ColorSpace.Linear;','            Check(PlayerSettings.colorSpace==ColorSpace.Linear,"Production linear color space");')
s=s.replace('        EditorApplication.Exit(report.passed?0:1);','        return report.passed;')
s=s.replace('string folder="Assets/candidates/"+id','string folder="Assets/Resources/Models/"+id')
s=s.replace('var mat=MaterialAt(folder,true);','var mat=AssetDatabase.LoadAssetAtPath<Material>(folder+"/duck-mobile.mat");')
s=s.replace('folder+"/collision.fbx"','"Assets/duck-collision-inputs/"+id+"-collision.fbx"')
s=s.replace('metallicEnabled=mat.IsKeywordEnabled("_METALLICGLOSSMAP")','metallicEnabled=mat.GetTexture("_MetallicGlossMap")!=null')
triangles=[json.loads((OUT/'qa'/(r['id']+'-metrics.json')).read_text('utf-8'))['triangles'] for r in CATALOG]
s=s.replace('int expectedTriangles=id=="duck-eggtart"?3752:id=="duck-steelcup"?3940:3820;', 'int expectedTriangles=new int[]{'+','.join(map(str,triangles))+'}[Array.IndexOf(Ids,id)];')
s=s.replace('string folder="Assets/candidates/duck-b2-home",path=folder+"/duck-b2-home.fbx";', 'string folder="Assets/duck-mascot-inputs",path=folder+"/duck-home.fbx";')
s=s.replace('Imported(path,MaterialAt(folder,false),true)','Imported(path,AssetDatabase.LoadAssetAtPath<Material>(folder+"/duck-home.mat"),true)')
s=s.replace('i<45;i++','i<60;i++').replace('Ids[i%3]','Ids[i%Ids.Length]')
s=s.replace('All 45 mixed','All 60 mixed').replace('>=40','>=54').replace('40/45','54/60').replace('>=39','>=53')
dest=ROOT/'projects/catch-big-goose-unity/Assets/Editor/DuckSeriesUnityAudit.cs';dest.write_text(s,'utf-8')
print('Prepared audit for',len(CATALOG),'models')
