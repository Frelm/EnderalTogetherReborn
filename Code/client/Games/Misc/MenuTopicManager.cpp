#include "MenuTopicManager.h"

#include <AI/Movement/PlayerControls.h>
#include <Events/PlayerDialogueEvent.h>
#include <PlayerCharacter.h>
#include <Services/QuestService.h>
#include <TESObjectREFR.h>
#include <Utils.h>

TP_THIS_FUNCTION(TPlayDialogueOption, bool, MenuTopicManager, int32_t aIndex);
TP_THIS_FUNCTION(TOpenDialogue, bool, MenuTopicManager, TESObjectREFR* apSpeaker, void* apUnk1, void* apUnk2);
static TPlayDialogueOption* RealPlayDialogueOption = nullptr;
static TOpenDialogue* RealOpenDialogue = nullptr;

MenuTopicManager* MenuTopicManager::Get() noexcept
{
    POINTER_SKYRIMSE(MenuTopicManager*, s_singleton, 401099);
    return *s_singleton.Get();
}

bool MenuTopicManager::IsPlayerDialogueSpeaker(const TESObjectREFR* apSpeaker) noexcept
{
    if (!apSpeaker)
        return false;

    const auto* pManager = Get();
    // lastSpeaker survives menu closure; using it here would also capture
    // subsequent ambient speech from a remotely owned NPC.
    return pManager && pManager->IsCurrentSpeaker(apSpeaker->GetHandle());
}

void MenuTopicManager::ForceCloseDialogueMenu() noexcept
{
    using TCloseDialogueMenu = void();
    POINTER_SKYRIMSE(TCloseDialogueMenu, s_closeDialogueMenu, 52856);

    s_closeDialogueMenu();

    if (auto* pManager = Get())
    {
        if (TESObjectREFR* pSpeaker = TESObjectREFR::GetByHandle(pManager->speaker.handle.iBits))
            pSpeaker->StopCurrentDialogue(true);
    }
    if (auto* pPlayer = PlayerCharacter::Get())
        pPlayer->StopCurrentDialogue(true);

    if (auto* pControls = PlayerControls::GetInstance())
    {
        pControls->SetBlockPlayerInput(false);
        pControls->SetActivateEnabled(true);
        pControls->Data.povScriptMode = false;
        if (pControls->togglePOVHandler)
            pControls->togglePOVHandler->isEnabled = true;
    }
    if (auto* pInputManager = BSInputEnableManager::Get())
        pInputManager->EnableOtherEvent(BSInputEnableManager::kPlayerControls | 0x1FF, true, true);
}

static bool IsBlockedCompanionOption(const MenuTopicManager::DialogueOption* apOption) noexcept
{
    if (!apOption || !apOption->parentTopic)
        return false;
    TESTopic* pTopic = apOption->parentTopic;
    // topicType 4 = Service (barter, training, travel, etc.)
    return pTopic->topicType != 4 && pTopic->ownerQuest && QuestService::IsStoryOrSideQuest(pTopic->ownerQuest);
}

bool TP_MAKE_THISCALL(HookPlayDialogueOption, MenuTopicManager, int32_t aIndex)
{
    if (apThis->pOptions)
    {
        int i = 0;
        const char* pText = nullptr;
        MenuTopicManager::DialogueOption* pSelectedOption = nullptr;
        bool hasAnyAllowedOption = false;
        for (auto option : *apThis->pOptions)
        {
            if (option && !IsBlockedCompanionOption(option))
                hasAnyAllowedOption = true;

            if (i == aIndex)
            {
                pSelectedOption = option;
                pText = option ? option->text : nullptr;
            }
            i++;
        }

        if (QuestService::IsCompanionRole() && IsBlockedCompanionOption(pSelectedOption))
        {
            Utils::ShowHudMessage("Companion Role: Only the Main Character can choose quest dialogue options.");

            // If this NPC only has quest dialogue options, close the dialogue menu so the Companion is never trapped.
            if (!hasAnyAllowedOption)
                MenuTopicManager::ForceCloseDialogueMenu();

            return false;
        }

        if (pText != nullptr)
            World::Get().GetRunner().Trigger(PlayerDialogueEvent(pText));
    }

    return TiltedPhoques::ThisCall(RealPlayDialogueOption, apThis, aIndex);
}

bool TP_MAKE_THISCALL(HookOpenDialogue, MenuTopicManager, TESObjectREFR* apSpeaker, void* apUnk1, void* apUnk2)
{
    if (QuestService::IsCompanionRole() && !QuestService::HadRecentManualPlayerActivation(1200))
    {
        spdlog::debug("Companion Role: blocked force-greet dialogue from NPC {:X}", apSpeaker ? apSpeaker->formID : 0u);
        if (apSpeaker)
        {
            QuestService::RecordBlockedForceGreetSpeaker(apSpeaker->formID);
            apSpeaker->StopCurrentDialogue(true);
        }
        if (auto* pControls = PlayerControls::GetInstance())
        {
            pControls->SetBlockPlayerInput(false);
            pControls->SetActivateEnabled(true);
            pControls->Data.povScriptMode = false;
            if (pControls->togglePOVHandler)
                pControls->togglePOVHandler->isEnabled = true;
        }
        if (auto* pInputManager = BSInputEnableManager::Get())
            pInputManager->EnableOtherEvent(BSInputEnableManager::kPlayerControls | 0x1FF, true, true);
        return false;
    }

    return TiltedPhoques::ThisCall(RealOpenDialogue, apThis, apSpeaker, apUnk1, apUnk2);
}

static TiltedPhoques::Initializer s_menuTopicHooks(
    []()
    {
        POINTER_SKYRIMSE(TPlayDialogueOption, s_playDialogueOption, 35269);
        POINTER_SKYRIMSE(TOpenDialogue, s_openDialogue, 35282);

        RealPlayDialogueOption = s_playDialogueOption.Get();
        RealOpenDialogue = s_openDialogue.Get();

        TP_HOOK(&RealPlayDialogueOption, HookPlayDialogueOption);
        TP_HOOK(&RealOpenDialogue, HookOpenDialogue);
    });
