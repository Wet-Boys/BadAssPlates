using HarmonyLib;
using UnityEngine;
using KitchenMods;
using PlateUpEmotesApi;
using PlateUpEmotesApi.Anim;
using Unity.Mathematics;
using static HarmonyLib.Code;
using Unity.Jobs;
using UnityEngine.Animations;
using static Cinemachine.CinemachineCore;
using UnityEngine.UIElements;

namespace PlateUpModTemplate;

public class PlateUpMod : IModInitializer
{
    public const string AUTHOR = "AUTHOR";
    public const string MOD_NAME = "MOD_NAME";
    public const string MOD_ID = $"com.{AUTHOR}.{MOD_NAME}";
    int prop1 = -1;
    int stageInt = -1;
    internal static GameObject stage;
    public void PostActivate(Mod mod)
    {
        Harmony.DEBUG = true;
        Harmony harmony = new Harmony(MOD_ID);
        
        harmony.PatchAll();
        Assets.PopulateAssets();
        AddAnimation($"assets/badassemotes/DanceMoves.anim", $"assets/Audio/Fortnite default dance sound.ogg", false, true, true);
        AddAnimation($"assets/badassemotes/Poyo.anim", $"assets/Audio/Poyo.ogg", true, true, true);

        //AddAnimation("Assets/BadAssEmotes/Breakneck.anim", "Assets/Audio/Breakneck.ogg", true, true, true);
        //AddAnimation("Assets/BadAssEmotes/Floss.anim", "Assets/Audio/floss.ogg", true, true, false);
        //AddAnimation("Assets/BadAssEmotes/OrangeJustice.anim", "Assets/Audio/Orange Justice.ogg", true, true, true);
        //AddAnimation("Assets/BadAssEmotes/GangnamStyle.anim", "Assets/Audio/GangnamStyle.ogg", true, true, true);
        //AddAnimation("Assets/BadAssEmotes/Specialist.anim", "Assets/Audio/Specialist.ogg", false, true, true);
        //AddAnimation("Assets/BadAssEmotes/GetDown.anim", "Assets/Audio/GetDown.ogg", false, true, true);
        AddAnimation("Assets/BadAssEmotes/Summertime.anim", "Assets/Audio/Summertime.ogg", false, true, true);
        AddAnimation("Assets/BadAssEmotes/HondaStep.anim", "Assets/Audio/HondaStep.ogg", false, true, true);
        AddAnimation("Assets/BadAssEmotes/Chika.anim", "Assets/Audio/Chika.ogg", false, true, true);


        AddAnimation("Assets/BadAssEmotes/MakeItRainIntro.anim", "Assets/BadAssEmotes/MakeItRainLoop.anim", "Assets/Audio/MakeItRainLoop.ogg", true, true);

        AddAnimation("Assets/BadAssEmotes/Security.anim", "Assets/Audio/Security.ogg", true, true, true);
        AddAnimation("Assets/BadAssEmotes/Smoke.anim", "Assets/Audio/Smoke.ogg", true, true, true);
        AddAnimation("Assets/BadAssEmotes/BimBamBom.anim", "Assets/Audio/BimBamBom.ogg", true, true, true);


        //PlateUpEmotesManager.AddNonAnimatingEmote("IFU Stage");
        //GameObject g2 = Assets.Load<GameObject>($"assets/prefabs/ifustagebasebased.prefab");
        //stageInt = PlateUpEmotesManager.RegisterWorldProp(g2, new JoinSpot[] { new JoinSpot("ifumiddle", new Vector3(0, .4f, 0)), new JoinSpot("ifeleft", new Vector3(-2, .4f, 0)), new JoinSpot("ifuright", new Vector3(2, .4f, 0)) });


        //CustomEmotesAPI.AddCustomAnimation(new AnimationClip[] { Assets.Load<AnimationClip>($"@ExampleEmotePlugin_badassemotes:assets/badassemotes/Haruhi.anim") }, false, new string[] { "Play_Haruhi", "Play_HaruhiYoung" }, new string[] { "Stop_Haruhi", "Stop_Haruhi" }, dimWhenClose: true, syncAnim: true, syncAudio: true, startPref: 0, joinPref: 0, joinSpots: new JoinSpot[] { new JoinSpot("Yuki_Nagato", new Vector3(3, 0, -3)), new JoinSpot("Mikuru_Asahina", new Vector3(-3, 0, -3)) });
        //CustomEmotesAPI.AddCustomAnimation(new AnimationClip[] { Assets.Load<AnimationClip>($"@ExampleEmotePlugin_badassemotes:assets/badassemotes/Yuki_Nagato.anim") }, false, "", visible: false, syncAnim: true);
        //CustomEmotesAPI.AddCustomAnimation(new AnimationClip[] { Assets.Load<AnimationClip>($"@ExampleEmotePlugin_badassemotes:assets/badassemotes/Mikuru_Asahina.anim") }, false, "", visible: false, syncAnim: true);

        PlateUpEmotesManager.AnimationChanged += PlateUpEmotesManager_AnimationChanged;
    }

    private void PlateUpEmotesManager_AnimationChanged(string newAnimation, BoneMapper mapper)
    {
        if (newAnimation == "Summertime")
        {
            prop1 = mapper.props.Count;
            //mapper.props.Add(GameObject.CreatePrimitive(PrimitiveType.Capsule));
            mapper.props.Add(GameObject.Instantiate(Assets.Load<GameObject>("Assets/Prefabs/Summermogus.prefab")));

            mapper.props[prop1].transform.SetParent(mapper.transform.parent);
            mapper.props[prop1].transform.localEulerAngles = Vector3.zero;
            mapper.props[prop1].transform.localPosition = Vector3.zero;
            mapper.ScaleProps();
            var smr = mapper.props[prop1].GetComponentInChildren<SkinnedMeshRenderer>();
            Debug.Log($"summermogus shader name is: {smr.material.shader.name}");
        }
        if (newAnimation == "HondaStep")
        {
            prop1 = mapper.props.Count;
            GameObject myNutz = GameObject.Instantiate(Assets.Load<GameObject>("assets/Prefabs/hondastuff.prefab"));
            foreach (var item in myNutz.GetComponentsInChildren<ParticleSystem>())
            {
                item.time = CustomAnimationClip.syncTimer[mapper.currentClip.syncPos];
            }
            Animator a = myNutz.GetComponentInChildren<Animator>();
            //a.Play("MusicSync", -1);
            a.Play("MusicSync", 0, (CustomAnimationClip.syncTimer[mapper.currentClip.syncPos] % a.GetCurrentAnimatorClipInfo(0)[0].clip.length) / a.GetCurrentAnimatorClipInfo(0)[0].clip.length);
            myNutz.transform.SetParent(mapper.transform.parent);
            myNutz.transform.localEulerAngles = Vector3.zero;
            myNutz.transform.localPosition = Vector3.zero;
            mapper.props.Add(myNutz);
            //mapper.ScaleProps();
        }
        if (newAnimation == "MakeItRainIntro")
        {
            prop1 = mapper.props.Count;
            mapper.props.Add(GameObject.Instantiate(Assets.Load<GameObject>("@BadAssEmotes_badassemotes:assets/Prefabs/money.prefab")));
            mapper.props[prop1].transform.SetParent(mapper.transform.parent);
            mapper.props[prop1].transform.localEulerAngles = Vector3.zero;
            mapper.props[prop1].transform.localPosition = Vector3.zero;
            mapper.ScaleProps();
        }
        if (newAnimation == "Chika")
        {
            prop1 = mapper.props.Count;
            mapper.props.Add(GameObject.Instantiate(Assets.Load<GameObject>("@BadAssEmotes_badassemotes:assets/models/desker.prefab")));
            mapper.props[prop1].transform.SetParent(mapper.transform.parent);
            mapper.props[prop1].transform.localEulerAngles = Vector3.zero;
            mapper.props[prop1].transform.localPosition = Vector3.zero;
            mapper.ScaleProps();
        }
        if (newAnimation == "BimBamBom")
        {
            prop1 = mapper.props.Count;
            mapper.props.Add(GameObject.Instantiate(Assets.Load<GameObject>("@BadAssEmotes_badassemotes:assets/Prefabs/BimBamBom.prefab")));
            mapper.props[prop1].transform.SetParent(mapper.transform.parent);
            mapper.props[prop1].transform.localEulerAngles = Vector3.zero;
            mapper.props[prop1].transform.localPosition = Vector3.zero;
            mapper.ScaleProps();
        }
        if (newAnimation == "Smoke")
        {
            prop1 = mapper.props.Count;
            mapper.props.Add(GameObject.Instantiate(Assets.Load<GameObject>("@BadAssEmotes_badassemotes:assets/Prefabs/BluntAnimator.prefab")));
            mapper.props[prop1].transform.SetParent(mapper.transform.parent);
            mapper.props[prop1].transform.localEulerAngles = Vector3.zero;
            mapper.props[prop1].transform.localPosition = Vector3.zero;
            mapper.props[prop1].GetComponentInChildren<ParticleSystem>().gravityModifier *= mapper.scale;
            var velocity = mapper.props[prop1].GetComponentInChildren<ParticleSystem>().limitVelocityOverLifetime;
            velocity.dampen *= mapper.scale;
            velocity.limitMultiplier = mapper.scale;
            mapper.ScaleProps();
        }
        if (newAnimation == "Haruhi")
        {
            GameObject g = new GameObject();
            g.name = "HaruhiProp";
            mapper.props.Add(g);
            g.transform.localPosition = mapper.transform.position;
            g.transform.localEulerAngles = mapper.transform.eulerAngles;
            g.transform.localScale = Vector3.one;
            mapper.AssignParentGameObject(g, false, false, true, true, false);
        }
        if (newAnimation == "Security")
        {
            prop1 = mapper.props.Count;
            mapper.props.Add(GameObject.Instantiate(Assets.Load<GameObject>("@BadAssEmotes_badassemotes:assets/prefabs/neversee.prefab")));
            mapper.props[prop1].transform.SetParent(mapper.gameObject.GetComponent<Animator>().GetBoneTransform(HumanBodyBones.Spine));
            mapper.props[prop1].transform.localEulerAngles = Vector3.zero;
            mapper.props[prop1].transform.localPosition = Vector3.zero;
            mapper.ScaleProps();
        }
        //if (newAnimation == "IFU Stage")
        //{
        //    if (stage)
        //    {
        //        GameObject.Destroy(stage);
        //    }
        //    stage = CustomEmotesAPI.SpawnWorldProp(stageInt);
        //    stage.transform.SetParent(mapper.transform.parent);
        //    stage.transform.localPosition = new Vector3(0, 0, 0);
        //    stage.transform.SetParent(null);
        //    stage.transform.localPosition += new Vector3(0, .5f, 0);
        //    NetworkServer.Spawn(stage);
        //}
    }

    public void PreInject()
    {
        
    }

    public void PostInject()
    {
    }



    internal void AddAnimation(string AnimClip, string wwise, bool looping, bool dimAudio, bool sync)
    {
        AnimationClipParams clipParams = new AnimationClipParams();
        clipParams.animationClip = new AnimationClip[] { Assets.Load<AnimationClip>(AnimClip) };
        clipParams.audioClips.Add(Assets.Load<AudioClip>(wwise));
        clipParams.looping = looping;
        clipParams.syncAnim = sync;
        clipParams.syncAudio = sync;
        clipParams.dimAudio = dimAudio;
        PlateUpEmotesManager.AddCustomAnimation(clipParams);
    }
    internal void AddAnimation(string AnimClip, string secondaryAnimClip, string wwise, bool dimAudio, bool sync)
    {
        AnimationClipParams clipParams = new AnimationClipParams();
        clipParams.animationClip = new AnimationClip[] { Assets.Load<AnimationClip>(AnimClip) };
        clipParams.secondaryAnimation = new AnimationClip[] { Assets.Load<AnimationClip>(secondaryAnimClip) };
        clipParams.audioClips.Add(Assets.Load<AudioClip>(wwise));
        clipParams.looping = true;
        clipParams.syncAnim = sync;
        clipParams.syncAudio = sync;
        clipParams.dimAudio = dimAudio;
        PlateUpEmotesManager.AddCustomAnimation(clipParams);
    }
    //internal void AddAnimation(string AnimClip, string[] wwise, string stopWwise, bool looping, bool dimAudio, bool sync)
    //{
    //    List<string> stopwwise = new List<string>();
    //    foreach (var item in wwise)
    //    {
    //        stopwwise.Add($"Stop_{stopWwise}");
    //    }
    //    PlateUpEmotesManager.AddCustomAnimation(new AnimationClip[] { Assets.Load<AnimationClip>($"@ExampleEmotePlugin_badassemotes:assets/badassemotes/{AnimClip}.anim") }, looping, wwise, stopwwise.ToArray(), dimWhenClose: dimAudio, syncAnim: sync, syncAudio: sync);
    //}
    //internal void AddAnimation(string AnimClip, string[] wwise, string stopWwise, bool looping, bool dimAudio, bool sync, JoinSpot[] joinSpots)
    //{
    //    List<string> stopwwise = new List<string>();
    //    foreach (var item in wwise)
    //    {
    //        stopwwise.Add($"Stop_{stopWwise}");
    //    }
    //    PlateUpEmotesManager.AddCustomAnimation(new AnimationClip[] { Assets.Load<AnimationClip>($"@ExampleEmotePlugin_badassemotes:assets/badassemotes/{AnimClip}.anim") }, looping, wwise, stopwwise.ToArray(), dimWhenClose: dimAudio, syncAnim: sync, syncAudio: sync, joinSpots: joinSpots);
    //}
    //internal void AddAnimation(string AnimClip, string wwise, string AnimClip2ElectricBoogaloo, bool dimAudio, bool sync)
    //{
    //    PlateUpEmotesManager.AddCustomAnimation(Assets.Load<AnimationClip>($"@ExampleEmotePlugin_badassemotes:assets/badassemotes/{AnimClip}.anim"), false, $"Play_{wwise}", $"Stop_{wwise}", secondaryAnimation: Assets.Load<AnimationClip>($"@ExampleEmotePlugin_badassemotes:assets/badassemotes/{AnimClip2ElectricBoogaloo}.anim"), dimWhenClose: dimAudio, syncAnim: sync, syncAudio: sync);
    //}
    //internal void AddStartAndJoinAnim(string[] AnimClip, string wwise, bool looping, bool dimaudio, bool sync)
    //{
    //    List<AnimationClip> nuts = new List<AnimationClip>();
    //    foreach (var item in AnimClip)
    //    {
    //        nuts.Add(Assets.Load<AnimationClip>($"@ExampleEmotePlugin_badassemotes:assets/badassemotes/{item}.anim"));
    //    }
    //    PlateUpEmotesManager.AddCustomAnimation(nuts.ToArray(), looping, $"Play_{wwise}", $"Stop_{wwise}", dimWhenClose: dimaudio, syncAnim: sync, syncAudio: sync, startPref: 0, joinPref: 1);
    //}
    //internal void AddStartAndJoinAnim(string[] AnimClip, string wwise, string[] AnimClip2ElectricBoogaloo, bool looping, bool dimaudio, bool sync)
    //{
    //    List<AnimationClip> nuts = new List<AnimationClip>();
    //    foreach (var item in AnimClip)
    //    {
    //        nuts.Add(Assets.Load<AnimationClip>($"@ExampleEmotePlugin_badassemotes:assets/badassemotes/{item}.anim"));
    //    }
    //    List<AnimationClip> nuts2 = new List<AnimationClip>();
    //    foreach (var item in AnimClip2ElectricBoogaloo)
    //    {
    //        nuts2.Add(Assets.Load<AnimationClip>($"@ExampleEmotePlugin_badassemotes:assets/badassemotes/{item}.anim"));
    //    }
    //    PlateUpEmotesManager.AddCustomAnimation(nuts.ToArray(), looping, $"Play_{wwise}", $"Stop_{wwise}", dimWhenClose: dimaudio, syncAnim: sync, syncAudio: sync, startPref: 0, joinPref: 1, secondaryAnimation: nuts2.ToArray());
    //}
}