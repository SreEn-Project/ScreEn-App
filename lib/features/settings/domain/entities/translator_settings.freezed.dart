// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translator_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TranslatorSettings {

/// BCP-47 언어 코드. 예: "ko", "en".
 String get targetLanguage; EngineType get engine; CaptureMode get captureMode; DisplayMode get displayMode; bool get onboardingCompleted;/// 플로팅 버튼 "빠른 언어" 버블에 나올 대상 언어 코드들 (사용자 편집, 순서 유지).
 List<String> get quickLanguages;/// 자동 번역 (#23): 번역한 뒤 화면이 바뀌면 알아서 다시 번역. 기본 꺼짐.
 bool get autoTranslate;/// 자동 번역의 화면 확인 간격 (ms). 짧을수록 열 · 배터리를 더 쓴다.
 int get autoCheckIntervalMs;/// 화면이 멈춘 뒤 번역하기까지 기다리는 시간 (ms). 0 = 바로.
 int get autoSettleMs;/// 화면이 바뀐 뒤 이전 결과를 숨기기까지의 시간 (ms). [autoHideNever] = 숨기지 않음.
 int get autoHideMs;
/// Create a copy of TranslatorSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslatorSettingsCopyWith<TranslatorSettings> get copyWith => _$TranslatorSettingsCopyWithImpl<TranslatorSettings>(this as TranslatorSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TranslatorSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslatorSettings&&(identical(other.targetLanguage, _this.targetLanguage) || other.targetLanguage == _this.targetLanguage)&&(identical(other.engine, _this.engine) || other.engine == _this.engine)&&(identical(other.captureMode, _this.captureMode) || other.captureMode == _this.captureMode)&&(identical(other.displayMode, _this.displayMode) || other.displayMode == _this.displayMode)&&(identical(other.onboardingCompleted, _this.onboardingCompleted) || other.onboardingCompleted == _this.onboardingCompleted)&&const DeepCollectionEquality().equals(other.quickLanguages, _this.quickLanguages)&&(identical(other.autoTranslate, _this.autoTranslate) || other.autoTranslate == _this.autoTranslate)&&(identical(other.autoCheckIntervalMs, _this.autoCheckIntervalMs) || other.autoCheckIntervalMs == _this.autoCheckIntervalMs)&&(identical(other.autoSettleMs, _this.autoSettleMs) || other.autoSettleMs == _this.autoSettleMs)&&(identical(other.autoHideMs, _this.autoHideMs) || other.autoHideMs == _this.autoHideMs));
}


@override
int get hashCode {
  final _this = this as TranslatorSettings;
  return Object.hash(runtimeType,_this.targetLanguage,_this.engine,_this.captureMode,_this.displayMode,_this.onboardingCompleted,const DeepCollectionEquality().hash(_this.quickLanguages),_this.autoTranslate,_this.autoCheckIntervalMs,_this.autoSettleMs,_this.autoHideMs);
}

@override
String toString() {
  final _this = this as TranslatorSettings;
  return 'TranslatorSettings(targetLanguage: ${_this.targetLanguage}, engine: ${_this.engine}, captureMode: ${_this.captureMode}, displayMode: ${_this.displayMode}, onboardingCompleted: ${_this.onboardingCompleted}, quickLanguages: ${_this.quickLanguages}, autoTranslate: ${_this.autoTranslate}, autoCheckIntervalMs: ${_this.autoCheckIntervalMs}, autoSettleMs: ${_this.autoSettleMs}, autoHideMs: ${_this.autoHideMs})';
}


}

/// @nodoc
abstract mixin class $TranslatorSettingsCopyWith<$Res>  {
  factory $TranslatorSettingsCopyWith(TranslatorSettings value, $Res Function(TranslatorSettings) _then) = _$TranslatorSettingsCopyWithImpl;
@useResult
$Res call({
 String targetLanguage, EngineType engine, CaptureMode captureMode, DisplayMode displayMode, bool onboardingCompleted, List<String> quickLanguages, bool autoTranslate, int autoCheckIntervalMs, int autoSettleMs, int autoHideMs
});




}
/// @nodoc
class _$TranslatorSettingsCopyWithImpl<$Res>
    implements $TranslatorSettingsCopyWith<$Res> {
  _$TranslatorSettingsCopyWithImpl(this._self, this._then);

  final TranslatorSettings _self;
  final $Res Function(TranslatorSettings) _then;

/// Create a copy of TranslatorSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetLanguage = null,Object? engine = null,Object? captureMode = null,Object? displayMode = null,Object? onboardingCompleted = null,Object? quickLanguages = null,Object? autoTranslate = null,Object? autoCheckIntervalMs = null,Object? autoSettleMs = null,Object? autoHideMs = null,}) {
  return _then(TranslatorSettings(
targetLanguage: null == targetLanguage ? _self.targetLanguage : targetLanguage // ignore: cast_nullable_to_non_nullable
as String,engine: null == engine ? _self.engine : engine // ignore: cast_nullable_to_non_nullable
as EngineType,captureMode: null == captureMode ? _self.captureMode : captureMode // ignore: cast_nullable_to_non_nullable
as CaptureMode,displayMode: null == displayMode ? _self.displayMode : displayMode // ignore: cast_nullable_to_non_nullable
as DisplayMode,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,quickLanguages: null == quickLanguages ? _self.quickLanguages : quickLanguages // ignore: cast_nullable_to_non_nullable
as List<String>,autoTranslate: null == autoTranslate ? _self.autoTranslate : autoTranslate // ignore: cast_nullable_to_non_nullable
as bool,autoCheckIntervalMs: null == autoCheckIntervalMs ? _self.autoCheckIntervalMs : autoCheckIntervalMs // ignore: cast_nullable_to_non_nullable
as int,autoSettleMs: null == autoSettleMs ? _self.autoSettleMs : autoSettleMs // ignore: cast_nullable_to_non_nullable
as int,autoHideMs: null == autoHideMs ? _self.autoHideMs : autoHideMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslatorSettings].
extension TranslatorSettingsPatterns on TranslatorSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslatorSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslatorSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslatorSettings value)  $default,){
final _that = this;
switch (_that) {
case _TranslatorSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslatorSettings value)?  $default,){
final _that = this;
switch (_that) {
case _TranslatorSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String targetLanguage,  EngineType engine,  CaptureMode captureMode,  DisplayMode displayMode,  bool onboardingCompleted,  List<String> quickLanguages,  bool autoTranslate,  int autoCheckIntervalMs,  int autoSettleMs,  int autoHideMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslatorSettings() when $default != null:
return $default(_that.targetLanguage,_that.engine,_that.captureMode,_that.displayMode,_that.onboardingCompleted,_that.quickLanguages,_that.autoTranslate,_that.autoCheckIntervalMs,_that.autoSettleMs,_that.autoHideMs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String targetLanguage,  EngineType engine,  CaptureMode captureMode,  DisplayMode displayMode,  bool onboardingCompleted,  List<String> quickLanguages,  bool autoTranslate,  int autoCheckIntervalMs,  int autoSettleMs,  int autoHideMs)  $default,) {final _that = this;
switch (_that) {
case _TranslatorSettings():
return $default(_that.targetLanguage,_that.engine,_that.captureMode,_that.displayMode,_that.onboardingCompleted,_that.quickLanguages,_that.autoTranslate,_that.autoCheckIntervalMs,_that.autoSettleMs,_that.autoHideMs);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String targetLanguage,  EngineType engine,  CaptureMode captureMode,  DisplayMode displayMode,  bool onboardingCompleted,  List<String> quickLanguages,  bool autoTranslate,  int autoCheckIntervalMs,  int autoSettleMs,  int autoHideMs)?  $default,) {final _that = this;
switch (_that) {
case _TranslatorSettings() when $default != null:
return $default(_that.targetLanguage,_that.engine,_that.captureMode,_that.displayMode,_that.onboardingCompleted,_that.quickLanguages,_that.autoTranslate,_that.autoCheckIntervalMs,_that.autoSettleMs,_that.autoHideMs);case _:
  return null;

}
}

}

/// @nodoc


class _TranslatorSettings implements TranslatorSettings {
  const _TranslatorSettings({this.targetLanguage = 'ko', this.engine = EngineType.mlKit, this.captureMode = CaptureMode.fullScreen, this.displayMode = DisplayMode.list, this.onboardingCompleted = false,  List<String> quickLanguages = defaultQuickLanguages, this.autoTranslate = false, this.autoCheckIntervalMs = defaultAutoCheckIntervalMs, this.autoSettleMs = defaultAutoSettleMs, this.autoHideMs = defaultAutoHideMs}): _quickLanguages = quickLanguages;
  

/// BCP-47 언어 코드. 예: "ko", "en".
@override@JsonKey() final  String targetLanguage;
@override@JsonKey() final  EngineType engine;
@override@JsonKey() final  CaptureMode captureMode;
@override@JsonKey() final  DisplayMode displayMode;
@override@JsonKey() final  bool onboardingCompleted;
/// 플로팅 버튼 "빠른 언어" 버블에 나올 대상 언어 코드들 (사용자 편집, 순서 유지).
 final  List<String> _quickLanguages;
/// 플로팅 버튼 "빠른 언어" 버블에 나올 대상 언어 코드들 (사용자 편집, 순서 유지).
@override@JsonKey() List<String> get quickLanguages {
  if (_quickLanguages is EqualUnmodifiableListView) return _quickLanguages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quickLanguages);
}

/// 자동 번역 (#23): 번역한 뒤 화면이 바뀌면 알아서 다시 번역. 기본 꺼짐.
@override@JsonKey() final  bool autoTranslate;
/// 자동 번역의 화면 확인 간격 (ms). 짧을수록 열 · 배터리를 더 쓴다.
@override@JsonKey() final  int autoCheckIntervalMs;
/// 화면이 멈춘 뒤 번역하기까지 기다리는 시간 (ms). 0 = 바로.
@override@JsonKey() final  int autoSettleMs;
/// 화면이 바뀐 뒤 이전 결과를 숨기기까지의 시간 (ms). [autoHideNever] = 숨기지 않음.
@override@JsonKey() final  int autoHideMs;

/// Create a copy of TranslatorSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslatorSettingsCopyWith<_TranslatorSettings> get copyWith => __$TranslatorSettingsCopyWithImpl<_TranslatorSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslatorSettings&&(identical(other.targetLanguage, targetLanguage) || other.targetLanguage == targetLanguage)&&(identical(other.engine, engine) || other.engine == engine)&&(identical(other.captureMode, captureMode) || other.captureMode == captureMode)&&(identical(other.displayMode, displayMode) || other.displayMode == displayMode)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&const DeepCollectionEquality().equals(other.quickLanguages, _quickLanguages)&&(identical(other.autoTranslate, autoTranslate) || other.autoTranslate == autoTranslate)&&(identical(other.autoCheckIntervalMs, autoCheckIntervalMs) || other.autoCheckIntervalMs == autoCheckIntervalMs)&&(identical(other.autoSettleMs, autoSettleMs) || other.autoSettleMs == autoSettleMs)&&(identical(other.autoHideMs, autoHideMs) || other.autoHideMs == autoHideMs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,targetLanguage,engine,captureMode,displayMode,onboardingCompleted,const DeepCollectionEquality().hash(_quickLanguages),autoTranslate,autoCheckIntervalMs,autoSettleMs,autoHideMs);
}

@override
String toString() {
    return 'TranslatorSettings(targetLanguage: $targetLanguage, engine: $engine, captureMode: $captureMode, displayMode: $displayMode, onboardingCompleted: $onboardingCompleted, quickLanguages: $quickLanguages, autoTranslate: $autoTranslate, autoCheckIntervalMs: $autoCheckIntervalMs, autoSettleMs: $autoSettleMs, autoHideMs: $autoHideMs)';
}


}

/// @nodoc
abstract mixin class _$TranslatorSettingsCopyWith<$Res> implements $TranslatorSettingsCopyWith<$Res> {
  factory _$TranslatorSettingsCopyWith(_TranslatorSettings value, $Res Function(_TranslatorSettings) _then) = __$TranslatorSettingsCopyWithImpl;
@override @useResult
$Res call({
 String targetLanguage, EngineType engine, CaptureMode captureMode, DisplayMode displayMode, bool onboardingCompleted, List<String> quickLanguages, bool autoTranslate, int autoCheckIntervalMs, int autoSettleMs, int autoHideMs
});




}
/// @nodoc
class __$TranslatorSettingsCopyWithImpl<$Res>
    implements _$TranslatorSettingsCopyWith<$Res> {
  __$TranslatorSettingsCopyWithImpl(this._self, this._then);

  final _TranslatorSettings _self;
  final $Res Function(_TranslatorSettings) _then;

/// Create a copy of TranslatorSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetLanguage = null,Object? engine = null,Object? captureMode = null,Object? displayMode = null,Object? onboardingCompleted = null,Object? quickLanguages = null,Object? autoTranslate = null,Object? autoCheckIntervalMs = null,Object? autoSettleMs = null,Object? autoHideMs = null,}) {
  return _then(_TranslatorSettings(
targetLanguage: null == targetLanguage ? _self.targetLanguage : targetLanguage // ignore: cast_nullable_to_non_nullable
as String,engine: null == engine ? _self.engine : engine // ignore: cast_nullable_to_non_nullable
as EngineType,captureMode: null == captureMode ? _self.captureMode : captureMode // ignore: cast_nullable_to_non_nullable
as CaptureMode,displayMode: null == displayMode ? _self.displayMode : displayMode // ignore: cast_nullable_to_non_nullable
as DisplayMode,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,quickLanguages: null == quickLanguages ? _self._quickLanguages : quickLanguages // ignore: cast_nullable_to_non_nullable
as List<String>,autoTranslate: null == autoTranslate ? _self.autoTranslate : autoTranslate // ignore: cast_nullable_to_non_nullable
as bool,autoCheckIntervalMs: null == autoCheckIntervalMs ? _self.autoCheckIntervalMs : autoCheckIntervalMs // ignore: cast_nullable_to_non_nullable
as int,autoSettleMs: null == autoSettleMs ? _self.autoSettleMs : autoSettleMs // ignore: cast_nullable_to_non_nullable
as int,autoHideMs: null == autoHideMs ? _self.autoHideMs : autoHideMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
