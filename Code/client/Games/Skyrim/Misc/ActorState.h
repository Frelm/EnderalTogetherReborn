#pragma once

#include <Misc/IMovementState.h>

struct ActorState : IMovementState
{
    virtual ~ActorState();

    uint32_t flags1;
    uint32_t flags2;

    bool IsWeaponDrawn() const noexcept { return (flags2 >> 5 & 7) >= 3; }

    bool IsWeaponFullyDrawn() const noexcept { return (flags2 >> 5 & 7) == 3; }

    bool IsBleedingOut() const noexcept { return (flags1 & 0x1E00000) == 0x1000000 || (flags1 & 0x1E00000) == 0xE00000; }

    uint32_t GetSitSleepState() const noexcept { return (flags1 >> 14) & 0xF; }

    bool IsSittingOrSleeping() const noexcept { return GetSitSleepState() != 0; }

    bool SetWeaponDrawn(bool aDraw) noexcept;
};
