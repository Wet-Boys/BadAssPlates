using HarmonyLib;
using UnityEngine;
using KitchenMods;
using PlateUpEmotesApi;
using PlateUpEmotesApi.Anim;
using Unity.Mathematics;
using static HarmonyLib.Code;
using Unity.Jobs;
using UnityEngine.Animations;

namespace PlateUpModTemplate;

public class PlateUpMod : IModInitializer
{
    public const string AUTHOR = "AUTHOR";
    public const string MOD_NAME = "MOD_NAME";
    public const string MOD_ID = $"com.{AUTHOR}.{MOD_NAME}";
    int prop1 = -1;
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

        PlateUpEmotesManager.AnimationChanged += PlateUpEmotesManager_AnimationChanged;
    }

    private void PlateUpEmotesManager_AnimationChanged(string newAnimation, BoneMapper mapper)
    {
        if (newAnimation == "Summertime")
        {
            prop1 = mapper.props.Count;
            mapper.props.Add(GameObject.Instantiate(Assets.Load<GameObject>("Assets/Prefabs/Summermogus.prefab")));
            mapper.props[prop1].transform.SetParent(mapper.transform.parent);
            mapper.props[prop1].transform.localEulerAngles = Vector3.zero;
            mapper.props[prop1].transform.localPosition = Vector3.zero;
            mapper.ScaleProps();
            var smr = mapper.props[prop1].GetComponentInChildren<SkinnedMeshRenderer>();
            Debug.Log($"{smr.isVisible}");
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