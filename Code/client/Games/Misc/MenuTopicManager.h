#pragma once

#include <Forms/TESForm.h>

struct TESObjectREFR;
struct TESQuest;

struct TESTopic : TESForm
{
    uint8_t pad20[0x30 - sizeof(TESForm)];
    uint8_t topicFlags;
    uint8_t topicType;
    uint16_t topicSubtype;
    float priority;
    TESForm* ownerBranch;
    TESQuest* ownerQuest;
};

static_assert(offsetof(TESTopic, topicType) == 0x31);
static_assert(offsetof(TESTopic, ownerQuest) == 0x40);

struct MenuTopicManager
{
    static MenuTopicManager* Get() noexcept;
    static bool IsPlayerDialogueSpeaker(const TESObjectREFR* apSpeaker) noexcept;
    static void ForceCloseDialogueMenu() noexcept;

    bool IsCurrentSpeaker(const BSPointerHandle<TESObjectREFR>& acHandle) const noexcept
    {
        return menuOpen && acHandle && speaker.handle.iBits == acHandle.handle.iBits;
    }

    struct DialogueOption
    {
        const char* text;
        uint8_t pad08[0x50 - 0x08];
        TESTopic* parentTopic;
    };

    uint8_t pad0[0x20];
    GameList<DialogueOption>* pOptions;

    uint8_t pad28[0x68 - 0x28];
    BSPointerHandle<TESObjectREFR> speaker;
    uint8_t pad6C[0xB1 - 0x6C];
    bool menuOpen;
};

static_assert(offsetof(MenuTopicManager::DialogueOption, parentTopic) == 0x50);
static_assert(offsetof(MenuTopicManager, pOptions) == 0x20);
static_assert(offsetof(MenuTopicManager, speaker) == 0x68);
static_assert(offsetof(MenuTopicManager, menuOpen) == 0xB1);
