enum FiltroData { todas, hoje, ultimos7Dias, ultimos30Dias }

extension FiltroDataLabel on FiltroData {
  String get label {
    return switch (this) {
      FiltroData.todas => 'Todas',
      FiltroData.hoje => 'Hoje',
      FiltroData.ultimos7Dias => 'Últimos 7 dias',
      FiltroData.ultimos30Dias => 'Últimos 30 dias',
    };
  }

  int? get dias {
    return switch (this) {
      FiltroData.todas => null,
      FiltroData.hoje => 1,
      FiltroData.ultimos7Dias => 7,
      FiltroData.ultimos30Dias => 30,
    };
  }
}
