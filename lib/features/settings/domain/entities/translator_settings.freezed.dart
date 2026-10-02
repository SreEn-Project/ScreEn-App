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
 bool get autoTranslate;/// 자동 번역이 새 번역을 보여 주는 시점 (ms). 0 = 번역이 되는 대로 바로.
 int get autoShowDelayMs;/// 조작 뒤 이전 번역을 숨기기까지의 시간 (ms). [hideNever] = 숨기지 않음.
 int get hideAfterInteractionMs;/// 언어 모델을 Wi-Fi에서만 받는다 (FL-05).
 bool get wifiOnlyModelDownload;/// 플로팅 버튼 원 지름 (dp, FL-07).
 int get buttonSizeDp;/// 플로팅 버튼 불투명도 (%, FL-07).
 int get buttonOpacityPercent;/// 고정 영역이 저장돼 있다 (FL-08). 영역 자체는 네이티브 전용.
 bool get hasFixedRegion;
/// Create a copy of TranslatorSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslatorSettingsCopyWith<TranslatorSettings> get copyWith => _$TranslatorSettingsCopyWithImpl<TranslatorSettings>(this as TranslatorSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TranslatorSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslatorSettings&&(identical(other.targetLanguage, _this.targetLanguage) || other.targetLanguage == _this.targetLanguage)&&(identical(other.engine, _this.engine) || other.engine == _this.engine)&&(identical(other.captureMode, _this.captureMode) || other.captureMode == _this.captureMode)&&(identical(other.displayMode, _this.displayMode) || other.displayMode == _this.displayMode)&&(identical(other.onboardingCompleted, _this.onboardingCompleted) || other.onboardingCompleted == _this.onboardingCompleted)&&const DeepCollectionEquality().equals(other.quickLanguages, _this.quickLanguages)&&(identical(other.autoTranslate, _this.autoTranslate) || other.autoTranslate == _this.autoTranslate)&&(identical(other.autoShowDelayMs, _this.autoShowDelayMs) || other.autoShowDelayMs == _this.autoShowDelayMs)&&(identical(other.hideAfterInteractionMs, _this.hideAfterInteractionMs) || other.hideAfterInteractionMs == _this.hideAfterInteractionMs)&&(identical(other.wifiOnlyModelDownload, _this.wifiOnlyModelDownload) || other.wifiOnlyModelDownload == _this.wifiOnlyModelDownload)&&(identical(other.buttonSizeDp, _this.buttonSizeDp) || other.buttonSizeDp == _this.buttonSizeDp)&&(identical(other.buttonOpacityPercent, _this.buttonOpacityPercent) || other.buttonOpacityPercent == _this.buttonOpacityPercent)&&(identical(other.hasFixedRegion, _this.hasFixedRegion) || other.hasFixedRegion == _this.hasFixedRegion));
}


@override
int get hashCode {
  final _this = this as TranslatorSettings;
  return Object.hash(runtimeType,_this.targetLanguage,_this.engine,_this.captureMode,_this.displayMode,_this.onboardingCompleted,const DeepCollectionEquality().hash(_this.quickLanguages),_this.autoTranslate,_this.autoShowDelayMs,_this.hideAfterInteractionMs,_this.wifiOnlyModelDownload,_this.buttonSizeDp,_this.buttonOpacityPercent,_this.hasFixedRegion);
}

@override
String toString() {
  final _this = this as TranslatorSettings;
  return 'TranslatorSettings(targetLanguage: ${_this.targetLanguage}, engine: ${_this.engine}, captureMode: ${_this.captureMode}, displayMode: ${_this.displayMode}, onboardingCompleted: ${_this.onboardingCompleted}, quickLanguages: ${_this.quickLanguages}, autoTranslate: ${_this.autoTranslate}, autoShowDelayMs: ${_this.autoShowDelayMs}, hideAfterInteractionMs: ${_this.hideAfterInteractionMs}, wifiOnlyModelDownload: ${_this.wifiOnlyModelDownload}, buttonSizeDp: ${_this.buttonSizeDp}, buttonOpacityPercent: ${_this.buttonOpacityPercent}, hasFixedRegion: ${_this.hasFixedRegion})';
}


}

/// @nodoc
abstract mixin class $TranslatorSettingsCopyWith<$Res>  {
  factory $TranslatorSettingsCopyWith(TranslatorSettings value, $Res Function(TranslatorSettings) _then) = _$TranslatorSettingsCopyWithImpl;
@useResult
$Res call({
 String targetLanguage, EngineType engine, CaptureMode captureMode, DisplayMode displayMode, bool onboardingCompleted, List<String> quickLanguages, bool autoTranslate, int autoShowDelayMs, int hideAfterInteractionMs, bool wifiOnlyModelDownload, int buttonSizeDp, int buttonOpacityPercent, bool hasFixedRegion
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
@pragma('vm:prefer-inline') @override $Res call({Object? targetLanguage = null,Object? engine = null,Object? captureMode = null,Object? displayMode = null,Object? onboardingCompleted = null,Object? quickLanguages = null,Object? autoTranslate = null,Object? autoShowDelayMs = null,Object? hideAfterInteractionMs = null,Object? wifiOnlyModelDownload = null,Object? buttonSizeDp = null,Object? buttonOpacityPercent = null,Object? hasFixedRegion = null,}) {
  return _then(TranslatorSettings(
targetLanguage: null == targetLanguage ? _self.targetLanguage : targetLanguage // ignore: cast_nullable_to_non_nullable
as String,engine: null == engine ? _self.engine : engine // ignore: cast_nullable_to_non_nullable
as EngineType,captureMode: null == captureMode ? _self.captureMode : captureMode // ignore: cast_nullable_to_non_nullable
as CaptureMode,displayMode: null == displayMode ? _self.displayMode : displayMode // ignore: cast_nullable_to_non_nullable
as DisplayMode,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,quickLanguages: null == quickLanguages ? _self.quickLanguages : quickLanguages // ignore: cast_nullable_to_non_nullable
as List<String>,autoTranslate: null == autoTranslate ? _self.autoTranslate : autoTranslate // ignore: cast_nullable_to_non_nullable
as bool,autoShowDelayMs: null == autoShowDelayMs ? _self.autoShowDelayMs : autoShowDelayMs // ignore: cast_nullable_to_non_nullable
as int,hideAfterInteractionMs: null == hideAfterInteractionMs ? _self.hideAfterInteractionMs : hideAfterInteractionMs // ignore: cast_nullable_to_non_nullable
as int,wifiOnlyModelDownload: null == wifiOnlyModelDownload ? _self.wifiOnlyModelDownload : wifiOnlyModelDownload // ignore: cast_nullable_to_non_nullable
as bool,buttonSizeDp: null == buttonSizeDp ? _self.buttonSizeDp : buttonSizeDp // ignore: cast_nullable_to_non_nullable
as int,buttonOpacityPercent: null == buttonOpacityPercent ? _self.buttonOpacityPercent : buttonOpacityPercent // ignore: cast_nullable_to_non_nullable
as int,hasFixedRegion: null == hasFixedRegion ? _self.hasFixedRegion : hasFixedRegion // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String targetLanguage,  EngineType engine,  CaptureMode captureMode,  DisplayMode displayMode,  bool onboardingCompleted,  List<String> quickLanguages,  bool autoTranslate,  int autoShowDelayMs,  int hideAfterInteractionMs,  bool wifiOnlyModelDownload,  int buttonSizeDp,  int buttonOpacityPercent,  bool hasFixedRegion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslatorSettings() when $default != null:
return $default(_that.targetLanguage,_that.engine,_that.captureMode,_that.displayMode,_that.onboardingCompleted,_that.quickLanguages,_that.autoTranslate,_that.autoShowDelayMs,_that.hideAfterInteractionMs,_that.wifiOnlyModelDownload,_that.buttonSizeDp,_that.buttonOpacityPercent,_that.hasFixedRegion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String targetLanguage,  EngineType engine,  CaptureMode captureMode,  DisplayMode displayMode,  bool onboardingCompleted,  List<String> quickLanguages,  bool autoTranslate,  int autoShowDelayMs,  int hideAfterInteractionMs,  bool wifiOnlyModelDownload,  int buttonSizeDp,  int buttonOpacityPercent,  bool hasFixedRegion)  $default,) {final _that = this;
switch (_that) {
case _TranslatorSettings():
return $default(_that.targetLanguage,_that.engine,_that.captureMode,_that.displayMode,_that.onboardingCompleted,_that.quickLanguages,_that.autoTranslate,_that.autoShowDelayMs,_that.hideAfterInteractionMs,_that.wifiOnlyModelDownload,_that.buttonSizeDp,_that.buttonOpacityPercent,_that.hasFixedRegion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String targetLanguage,  EngineType engine,  CaptureMode captureMode,  DisplayMode displayMode,  bool onboardingCompleted,  List<String> quickLanguages,  bool autoTranslate,  int autoShowDelayMs,  int hideAfterInteractionMs,  bool wifiOnlyModelDownload,  int buttonSizeDp,  int buttonOpacityPercent,  bool hasFixedRegion)?  $default,) {final _that = this;
switch (_that) {
case _TranslatorSettings() when $default != null:
return $default(_that.targetLanguage,_that.engine,_that.captureMode,_that.displayMode,_that.onboardingCompleted,_that.quickLanguages,_that.autoTranslate,_that.autoShowDelayMs,_that.hideAfterInteractionMs,_that.wifiOnlyModelDownload,_that.buttonSizeDp,_that.buttonOpacityPercent,_that.hasFixedRegion);case _:
  return null;

}
}

}

/// @nodoc


class _TranslatorSettings implements TranslatorSettings {
  const _TranslatorSettings({this.targetLanguage = 'ko', this.engine = EngineType.mlKit, this.captureMode = CaptureMode.fullScreen, this.displayMode = DisplayMode.list, this.onboardingCompleted = false,  List<String> quickLanguages = defaultQuickLanguages, this.autoTranslate = false, this.autoShowDelayMs = defaultAutoShowDelayMs, this.hideAfterInteractionMs = defaultHideAfterInteractionMs, this.wifiOnlyModelDownload = true, this.buttonSizeDp = defaultButtonSizeDp, this.buttonOpacityPercent = defaultButtonOpacityPercent, this.hasFixedRegion = false}): _quickLanguages = quickLanguages;
  

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
/// 자동 번역이 새 번역을 보여 주는 시점 (ms). 0 = 번역이 되는 대로 바로.
@override@JsonKey() final  int autoShowDelayMs;
/// 조작 뒤 이전 번역을 숨기기까지의 시간 (ms). [hideNever] = 숨기지 않음.
@override@JsonKey() final  int hideAfterInteractionMs;
/// 언어 모델을 Wi-Fi에서만 받는다 (FL-05).
@override@JsonKey() final  bool wifiOnlyModelDownload;
/// 플로팅 버튼 원 지름 (dp, FL-07).
@override@JsonKey() final  int buttonSizeDp;
/// 플로팅 버튼 불투명도 (%, FL-07).
@override@JsonKey() final  int buttonOpacityPercent;
/// 고정 영역이 저장돼 있다 (FL-08). 영역 자체는 네이티브 전용.
@override@JsonKey() final  bool hasFixedRegion;

/// Create a copy of TranslatorSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslatorSettingsCopyWith<_TranslatorSettings> get copyWith => __$TranslatorSettingsCopyWithImpl<_TranslatorSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslatorSettings&&(identical(other.targetLanguage, targetLanguage) || other.targetLanguage == targetLanguage)&&(identical(other.engine, engine) || other.engine == engine)&&(identical(other.captureMode, captureMode) || other.captureMode == captureMode)&&(identical(other.displayMode, displayMode) || other.displayMode == displayMode)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&const DeepCollectionEquality().equals(other.quickLanguages, _quickLanguages)&&(identical(other.autoTranslate, autoTranslate) || other.autoTranslate == autoTranslate)&&(identical(other.autoShowDelayMs, autoShowDelayMs) || other.autoShowDelayMs == autoShowDelayMs)&&(identical(other.hideAfterInteractionMs, hideAfterInteractionMs) || other.hideAfterInteractionMs == hideAfterInteractionMs)&&(identical(other.wifiOnlyModelDownload, wifiOnlyModelDownload) || other.wifiOnlyModelDownload == wifiOnlyModelDownload)&&(identical(other.buttonSizeDp, buttonSizeDp) || other.buttonSizeDp == buttonSizeDp)&&(identical(other.buttonOpacityPercent, buttonOpacityPercent) || other.buttonOpacityPercent == buttonOpacityPercent)&&(identical(other.hasFixedRegion, hasFixedRegion) || other.hasFixedRegion == hasFixedRegion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,targetLanguage,engine,captureMode,displayMode,onboardingCompleted,const DeepCollectionEquality().hash(_quickLanguages),autoTranslate,autoShowDelayMs,hideAfterInteractionMs,wifiOnlyModelDownload,buttonSizeDp,buttonOpacityPercent,hasFixedRegion);
}

@override
String toString() {
    return 'TranslatorSettings(targetLanguage: $targetLanguage, engine: $engine, captureMode: $captureMode, displayMode: $displayMode, onboardingCompleted: $onboardingCompleted, quickLanguages: $quickLanguages, autoTranslate: $autoTranslate, autoShowDelayMs: $autoShowDelayMs, hideAfterInteractionMs: $hideAfterInteractionMs, wifiOnlyModelDownload: $wifiOnlyModelDownload, buttonSizeDp: $buttonSizeDp, buttonOpacityPercent: $buttonOpacityPercent, hasFixedRegion: $hasFixedRegion)';
}


}

/// @nodoc
abstract mixin class _$TranslatorSettingsCopyWith<$Res> implements $TranslatorSettingsCopyWith<$Res> {
  factory _$TranslatorSettingsCopyWith(_TranslatorSettings value, $Res Function(_TranslatorSettings) _then) = __$TranslatorSettingsCopyWithImpl;
@override @useResult
$Res call({
 String targetLanguage, EngineType engine, CaptureMode captureMode, DisplayMode displayMode, bool onboardingCompleted, List<String> quickLanguages, bool autoTranslate, int autoShowDelayMs, int hideAfterInteractionMs, bool wifiOnlyModelDownload, int buttonSizeDp, int buttonOpacityPercent, bool hasFixedRegion
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
@override @pragma('vm:prefer-inline') $Res call({Object? targetLanguage = null,Object? engine = null,Object? captureMode = null,Object? displayMode = null,Object? onboardingCompleted = null,Object? quickLanguages = null,Object? autoTranslate = null,Object? autoShowDelayMs = null,Object? hideAfterInteractionMs = null,Object? wifiOnlyModelDownload = null,Object? buttonSizeDp = null,Object? buttonOpacityPercent = null,Object? hasFixedRegion = null,}) {
  return _then(_TranslatorSettings(
targetLanguage: null == targetLanguage ? _self.targetLanguage : targetLanguage // ignore: cast_nullable_to_non_nullable
as String,engine: null == engine ? _self.engine : engine // ignore: cast_nullable_to_non_nullable
as EngineType,captureMode: null == captureMode ? _self.captureMode : captureMode // ignore: cast_nullable_to_non_nullable
as CaptureMode,displayMode: null == displayMode ? _self.displayMode : displayMode // ignore: cast_nullable_to_non_nullable
as DisplayMode,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,quickLanguages: null == quickLanguages ? _self._quickLanguages : quickLanguages // ignore: cast_nullable_to_non_nullable
as List<String>,autoTranslate: null == autoTranslate ? _self.autoTranslate : autoTranslate // ignore: cast_nullable_to_non_nullable
as bool,autoShowDelayMs: null == autoShowDelayMs ? _self.autoShowDelayMs : autoShowDelayMs // ignore: cast_nullable_to_non_nullable
as int,hideAfterInteractionMs: null == hideAfterInteractionMs ? _self.hideAfterInteractionMs : hideAfterInteractionMs // ignore: cast_nullable_to_non_nullable
as int,wifiOnlyModelDownload: null == wifiOnlyModelDownload ? _self.wifiOnlyModelDownload : wifiOnlyModelDownload // ignore: cast_nullable_to_non_nullable
as bool,buttonSizeDp: null == buttonSizeDp ? _self.buttonSizeDp : buttonSizeDp // ignore: cast_nullable_to_non_nullable
as int,buttonOpacityPercent: null == buttonOpacityPercent ? _self.buttonOpacityPercent : buttonOpacityPercent // ignore: cast_nullable_to_non_nullable
as int,hasFixedRegion: null == hasFixedRegion ? _self.hasFixedRegion : hasFixedRegion // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
