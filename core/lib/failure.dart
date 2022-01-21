abstract class Failure {
  final String message;

  const Failure(this.message);
}

class BusinessFailure extends Failure {
  const BusinessFailure(String message) : super(message);
}
