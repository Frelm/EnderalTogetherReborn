#pragma once

using TiltedPhoques::Buffer;

struct ServerSettings
{
    bool operator==(const ServerSettings& acRhs) const noexcept;
    bool operator!=(const ServerSettings& acRhs) const noexcept;

    void Serialize(TiltedPhoques::Buffer::Writer& aWriter) const noexcept;
    void Deserialize(TiltedPhoques::Buffer::Reader& aReader) noexcept;

    uint32_t Difficulty{};
    bool GreetingsEnabled{};
    bool PvpEnabled{};
    bool SyncPlayerHomes{};
    bool DeathSystemEnabled{};
    bool SyncPlayerCalendar{};
    bool AutoPartyJoin{};
    bool ItemDropsEnabled{};
    bool DynamicScalingEnabled{true};
    float HealthScale2P{1.75f};
    float DamageScale2P{1.25f};
    float HealthScale3P{2.30f};
    float DamageScale3P{1.40f};
};
