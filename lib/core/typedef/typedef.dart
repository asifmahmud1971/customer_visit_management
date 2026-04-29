import 'package:dartz/dartz.dart';
import '../errors/api_failure.dart';

typedef Result<T> = Future<Either<ApiFailure, T>>;
typedef ResultFuture<T> = Future<Either<ApiFailure, T>>;
typedef ResultVoid = Result<void>;
typedef Params = Map<String, dynamic>;
