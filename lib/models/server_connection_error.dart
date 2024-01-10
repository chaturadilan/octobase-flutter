class ServerConnectionError extends Error {
  final String message;

  ServerConnectionError(this.message);

  @override
  String toString() {
    return message;
  }
}
