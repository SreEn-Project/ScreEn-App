// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(vocabularyRepository)
final vocabularyRepositoryProvider = VocabularyRepositoryProvider._();

final class VocabularyRepositoryProvider
    extends
        $FunctionalProvider<
          VocabularyRepository,
          VocabularyRepository,
          VocabularyRepository
        >
    with $Provider<VocabularyRepository> {
  VocabularyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vocabularyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vocabularyRepositoryHash();

  @$internal
  @override
  $ProviderElement<VocabularyRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VocabularyRepository create(Ref ref) {
    return vocabularyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VocabularyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VocabularyRepository>(value),
    );
  }
}

String _$vocabularyRepositoryHash() =>
    r'ff948635ebc8e33a635841813e6e90773dfbb8f5';

@ProviderFor(getWordbooks)
final getWordbooksProvider = GetWordbooksProvider._();

final class GetWordbooksProvider
    extends $FunctionalProvider<GetWordbooks, GetWordbooks, GetWordbooks>
    with $Provider<GetWordbooks> {
  GetWordbooksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getWordbooksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getWordbooksHash();

  @$internal
  @override
  $ProviderElement<GetWordbooks> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetWordbooks create(Ref ref) {
    return getWordbooks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetWordbooks value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetWordbooks>(value),
    );
  }
}

String _$getWordbooksHash() => r'541235f9460d7a2992b1f8e9f0e365c744333883';

@ProviderFor(createWordbook)
final createWordbookProvider = CreateWordbookProvider._();

final class CreateWordbookProvider
    extends $FunctionalProvider<CreateWordbook, CreateWordbook, CreateWordbook>
    with $Provider<CreateWordbook> {
  CreateWordbookProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createWordbookProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createWordbookHash();

  @$internal
  @override
  $ProviderElement<CreateWordbook> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateWordbook create(Ref ref) {
    return createWordbook(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateWordbook value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateWordbook>(value),
    );
  }
}

String _$createWordbookHash() => r'1ced20e0751c1b5b0c43ac8358de0683943d73f9';

@ProviderFor(renameWordbook)
final renameWordbookProvider = RenameWordbookProvider._();

final class RenameWordbookProvider
    extends $FunctionalProvider<RenameWordbook, RenameWordbook, RenameWordbook>
    with $Provider<RenameWordbook> {
  RenameWordbookProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'renameWordbookProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$renameWordbookHash();

  @$internal
  @override
  $ProviderElement<RenameWordbook> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RenameWordbook create(Ref ref) {
    return renameWordbook(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RenameWordbook value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RenameWordbook>(value),
    );
  }
}

String _$renameWordbookHash() => r'c99da5456bb7baf0712f525e01b8e907f1ae4997';

@ProviderFor(deleteWordbook)
final deleteWordbookProvider = DeleteWordbookProvider._();

final class DeleteWordbookProvider
    extends $FunctionalProvider<DeleteWordbook, DeleteWordbook, DeleteWordbook>
    with $Provider<DeleteWordbook> {
  DeleteWordbookProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteWordbookProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteWordbookHash();

  @$internal
  @override
  $ProviderElement<DeleteWordbook> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteWordbook create(Ref ref) {
    return deleteWordbook(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteWordbook value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteWordbook>(value),
    );
  }
}

String _$deleteWordbookHash() => r'ff9c21c46ccad0c81bf45004ddc0b9af31f2eb10';

@ProviderFor(getWords)
final getWordsProvider = GetWordsProvider._();

final class GetWordsProvider
    extends $FunctionalProvider<GetWords, GetWords, GetWords>
    with $Provider<GetWords> {
  GetWordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getWordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getWordsHash();

  @$internal
  @override
  $ProviderElement<GetWords> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetWords create(Ref ref) {
    return getWords(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetWords value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetWords>(value),
    );
  }
}

String _$getWordsHash() => r'ea7f3d59d335db89f319330cc6dbf3c2fe30a37a';

@ProviderFor(getWord)
final getWordProvider = GetWordProvider._();

final class GetWordProvider
    extends $FunctionalProvider<GetWord, GetWord, GetWord>
    with $Provider<GetWord> {
  GetWordProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getWordProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getWordHash();

  @$internal
  @override
  $ProviderElement<GetWord> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetWord create(Ref ref) {
    return getWord(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetWord value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetWord>(value),
    );
  }
}

String _$getWordHash() => r'9ee5c65124aabe5d65ede37d88ad48b0b00f9df1';

@ProviderFor(moveWord)
final moveWordProvider = MoveWordProvider._();

final class MoveWordProvider
    extends $FunctionalProvider<MoveWord, MoveWord, MoveWord>
    with $Provider<MoveWord> {
  MoveWordProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moveWordProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moveWordHash();

  @$internal
  @override
  $ProviderElement<MoveWord> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MoveWord create(Ref ref) {
    return moveWord(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MoveWord value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MoveWord>(value),
    );
  }
}

String _$moveWordHash() => r'a2f4ab72946e776b8785c0a6bb0c3b7e5074e161';

@ProviderFor(deleteWord)
final deleteWordProvider = DeleteWordProvider._();

final class DeleteWordProvider
    extends $FunctionalProvider<DeleteWord, DeleteWord, DeleteWord>
    with $Provider<DeleteWord> {
  DeleteWordProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteWordProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteWordHash();

  @$internal
  @override
  $ProviderElement<DeleteWord> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteWord create(Ref ref) {
    return deleteWord(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteWord value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteWord>(value),
    );
  }
}

String _$deleteWordHash() => r'6fb02d488bdf69cccf5de9d363aa3115510ab0a9';

@ProviderFor(setWordMemorized)
final setWordMemorizedProvider = SetWordMemorizedProvider._();

final class SetWordMemorizedProvider
    extends
        $FunctionalProvider<
          SetWordMemorized,
          SetWordMemorized,
          SetWordMemorized
        >
    with $Provider<SetWordMemorized> {
  SetWordMemorizedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setWordMemorizedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setWordMemorizedHash();

  @$internal
  @override
  $ProviderElement<SetWordMemorized> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SetWordMemorized create(Ref ref) {
    return setWordMemorized(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetWordMemorized value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetWordMemorized>(value),
    );
  }
}

String _$setWordMemorizedHash() => r'e1f2729a8b69db6067743347e3c5200f8cf21efa';

@ProviderFor(saveWord)
final saveWordProvider = SaveWordProvider._();

final class SaveWordProvider
    extends $FunctionalProvider<SaveWord, SaveWord, SaveWord>
    with $Provider<SaveWord> {
  SaveWordProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveWordProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveWordHash();

  @$internal
  @override
  $ProviderElement<SaveWord> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SaveWord create(Ref ref) {
    return saveWord(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveWord value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveWord>(value),
    );
  }
}

String _$saveWordHash() => r'05f95ee736c1fe0c3d4d163be24754547a0f98f7';

@ProviderFor(createWordTest)
final createWordTestProvider = CreateWordTestProvider._();

final class CreateWordTestProvider
    extends $FunctionalProvider<CreateWordTest, CreateWordTest, CreateWordTest>
    with $Provider<CreateWordTest> {
  CreateWordTestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createWordTestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createWordTestHash();

  @$internal
  @override
  $ProviderElement<CreateWordTest> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateWordTest create(Ref ref) {
    return createWordTest(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateWordTest value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateWordTest>(value),
    );
  }
}

String _$createWordTestHash() => r'c5e94602b338092b74bc517d695f1e2aac6be255';
