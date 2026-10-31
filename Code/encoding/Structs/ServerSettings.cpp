#include "ServerSettings.h"
#include <TiltedCore/Serialization.hpp>

using TiltedPhoques::Serialization;

bool ServerSettings::operator==(const ServerSettings& acRhs) const noexcept
{
    return Difficulty == acRhs.Difficulty && GreetingsEnabled == acRhs.GreetingsEnabled && PvpEnabled == acRhs.PvpEnabled && SyncPlayerHomes == acRhs.SyncPlayerHomes && DeathSystemEnabled == acRhs.DeathSystemEnabled && AutoPartyJoin == acRhs.AutoPartyJoin && ItemDropsEnabled == acRhs.ItemDropsEnabled &&
           DynamicScalingEnabled == acRhs.DynamicScalingEnabled &&
           HealthScale2P == acRhs.HealthScale2P &&
           DamageScale2P == acRhs.DamageScale2P &&
           HealthScale3P == acRhs.HealthScale3P &&
           DamageScale3P == acRhs.DamageScale3P;
}

bool ServerSettings::operator!=(const ServerSettings& acRhs) const noexcept
{
    return !this->operator==(acRhs);
}

void ServerSettings::Serialize(TiltedPhoques::Buffer::Writer& aWriter) const noexcept
{
    Serialization::WriteVarInt(aWriter, Difficulty);
    Serialization::WriteBool(aWriter, GreetingsEnabled);
    Serialization::WriteBool(aWriter, PvpEnabled);
    Serialization::WriteBool(aWriter, SyncPlayerHomes);
    Serialization::WriteBool(aWriter, DeathSystemEnabled);
    Serialization::WriteBool(aWriter, SyncPlayerCalendar);
    Serialization::WriteBool(aWriter, AutoPartyJoin);
    Serialization::WriteBool(aWriter, ItemDropsEnabled);
    Serialization::WriteBool(aWriter, DynamicScalingEnabled);
    Serialization::WriteFloat(aWriter, HealthScale2P);
    Serialization::WriteFloat(aWriter, DamageScale2P);
    Serialization::WriteFloat(aWriter, HealthScale3P);
    Serialization::WriteFloat(aWriter, DamageScale3P);
}

void ServerSettings::Deserialize(TiltedPhoques::Buffer::Reader& aReader) noexcept
{
    Difficulty = Serialization::ReadVarInt(aReader) & 0xFFFFFFFF;
    GreetingsEnabled = Serialization::ReadBool(aReader);
    PvpEnabled = Serialization::ReadBool(aReader);
    SyncPlayerHomes = Serialization::ReadBool(aReader);
    DeathSystemEnabled = Serialization::ReadBool(aReader);
    SyncPlayerCalendar = Serialization::ReadBool(aReader);
    AutoPartyJoin = Serialization::ReadBool(aReader);
    ItemDropsEnabled = Serialization::ReadBool(aReader);
    DynamicScalingEnabled = Serialization::ReadBool(aReader);
    HealthScale2P = Serialization::ReadFloat(aReader);
    DamageScale2P = Serialization::ReadFloat(aReader);
    HealthScale3P = Serialization::ReadFloat(aReader);
    DamageScale3P = Serialization::ReadFloat(aReader);
}
