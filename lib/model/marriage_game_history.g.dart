// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marriage_game_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarriageGameHistoryAdapter extends TypeAdapter<MarriageGameHistory> {
  @override
  final int typeId = 4;

  @override
  MarriageGameHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarriageGameHistory(
      id: fields[0] as String,
      playedAt: fields[1] as DateTime,
      numberOfPlayers: fields[2] as int,
      pointsPerRupee: fields[3] as double,
      totalMaalPoints: fields[4] as double,
      players: (fields[5] as List).cast<MarriagePlayerHistory>(),
      gameType: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MarriageGameHistory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.playedAt)
      ..writeByte(2)
      ..write(obj.numberOfPlayers)
      ..writeByte(3)
      ..write(obj.pointsPerRupee)
      ..writeByte(4)
      ..write(obj.totalMaalPoints)
      ..writeByte(5)
      ..write(obj.players)
      ..writeByte(6)
      ..write(obj.gameType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarriageGameHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MarriagePlayerHistoryAdapter extends TypeAdapter<MarriagePlayerHistory> {
  @override
  final int typeId = 5;

  @override
  MarriagePlayerHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarriagePlayerHistory(
      userId: fields[0] as String,
      userName: fields[1] as String,
      userImage: fields[2] as String?,
      maalPoints: fields[3] as double,
      isSequence: fields[4] as bool,
      isDoublee: fields[5] as bool,
      pointsEarned: fields[6] as double,
      currentScore: fields[7] as int,
      mode: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MarriagePlayerHistory obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.userImage)
      ..writeByte(3)
      ..write(obj.maalPoints)
      ..writeByte(4)
      ..write(obj.isSequence)
      ..writeByte(5)
      ..write(obj.isDoublee)
      ..writeByte(6)
      ..write(obj.pointsEarned)
      ..writeByte(7)
      ..write(obj.currentScore)
      ..writeByte(8)
      ..write(obj.mode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarriagePlayerHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
