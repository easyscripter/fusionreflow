/// Отключает автоповтор Riverpod для провайдера: ошибку сразу видит человек и
/// решает кнопкой «Повторить» (`invalidate`). Иначе Riverpod молча повторяет
/// упавший провайдер.
Duration? noRetry(int retryCount, Object error) => null;
