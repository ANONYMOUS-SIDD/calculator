// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_history_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoundHistoryDataAdapter extends TypeAdapter<RoundHistoryData> {
  @override
  final int typeId = 3;

  @override
  RoundHistoryData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoundHistoryData(
      roundNumber: fields[0] as int,
      bids: (fields[1] as List).cast<int>(),
      extras: (fields[2] as List).cast<int>(),
      points: (fields[3] as List).cast<double>(),
      bidSuccess: (fields[4] as List).cast<bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, RoundHistoryData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.roundNumber)
      ..writeByte(1)
      ..write(obj.bids)
      ..writeByte(2)
      ..write(obj.extras)
      ..writeByte(3)
      ..write(obj.points)
      ..writeByte(4)
      ..write(obj.bidSuccess);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoundHistoryDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CallBreakGameHistoryAdapter extends TypeAdapter<CallBreakGameHistory> {
  @override
  final int typeId = 1;

  @override
  CallBreakGameHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CallBreakGameHistory(
      gameId: fields[0] as String,
      timestamp: fields[1] as DateTime,
      playerNames: (fields[2] as List).cast<String>(),
      totalScores: (fields[3] as List).cast<double>(),
      totalRounds: fields[4] as int,
      gameTag: fields[5] as String,
      roundDetails: (fields[6] as List).cast<RoundHistoryData>(),
    );
  }

  @override
  void write(BinaryWriter writer, CallBreakGameHistory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.gameId)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.playerNames)
      ..writeByte(3)
      ..write(obj.totalScores)
      ..writeByte(4)
      ..write(obj.totalRounds)
      ..writeByte(5)
      ..write(obj.gameTag)
      ..writeByte(6)
      ..write(obj.roundDetails);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallBreakGameHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayerOverallStatsAdapter extends TypeAdapter<PlayerOverallStats> {
  @override
  final int typeId = 2;

  @override
  PlayerOverallStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerOverallStats(
      playerName: fields[0] as String,
      totalMatchesPlayed: fields[1] as int,
      totalWins: fields[2] as int,
      currentLevel: fields[3] as int,
      lastPlayed: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerOverallStats obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.playerName)
      ..writeByte(1)
      ..write(obj.totalMatchesPlayed)
      ..writeByte(2)
      ..write(obj.totalWins)
      ..writeByte(3)
      ..write(obj.currentLevel)
      ..writeByte(4)
      ..write(obj.lastPlayed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerOverallStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
