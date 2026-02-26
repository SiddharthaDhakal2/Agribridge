// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderHiveModelAdapter extends TypeAdapter<OrderHiveModel> {
  @override
  final int typeId = 7;

  @override
  OrderHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderHiveModel(
      userId: fields[10] as String?,
      orderId: fields[0] as String,
      productId: fields[1] as String,
      productName: fields[2] as String,
      customerName: fields[13] as String,
      deliveryAddress: fields[14] as String,
      imagePath: fields[3] as String,
      pricePerUnit: fields[4] as double,
      quantity: fields[5] as int,
      total: fields[6] as double,
      orderSubtotal: fields[11] as double?,
      deliveryFee: fields[12] as double?,
      status: fields[7] as String,
      unit: fields[8] as String,
      createdAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderHiveModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(10)
      ..write(obj.userId)
      ..writeByte(0)
      ..write(obj.orderId)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(13)
      ..write(obj.customerName)
      ..writeByte(14)
      ..write(obj.deliveryAddress)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.pricePerUnit)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.total)
      ..writeByte(11)
      ..write(obj.orderSubtotal)
      ..writeByte(12)
      ..write(obj.deliveryFee)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.unit)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
