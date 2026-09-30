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
 String get targetLanguage; EngineType get engine; CaptureMode get captureMode; DisplayMode get displayMode; bool get onboardingCompleted;
/// Create a copy of TranslatorSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslatorSettingsCopyWith<TranslatorSettings> get copyWith => _$TranslatorSettingsCopyWithImpl<TranslatorSettings>(this as TranslatorSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TranslatorSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslatorSettings&&(identical(other.targetLanguage, _this.targetLanguage) || other.targetLanguage == _this.targetLanguage)&&(identical(other.engine, _this.engine) || other.engine == _this.engine)&&(identical(other.captureMode, _this.captureMode) || other.captureMode == _this.captureMode)&&(identical(other.displayMode, _this.displayMode) || other.displayMode == _this.displayMode)&&(identical(other.onboardingCompleted, _this.onboardingCompleted) || other.onboardingCompleted == _this.onboardingCompleted));
}


@override
int get hashCode {
  final _this = this as TranslatorSettings;
  return Object.hash(runtimeType,_this.targetLanguage,_this.engine,_this.captureMode,_this.displayMode,_this.onboardingCompleted);
}

@override
String toString() {
  final _this = this as TranslatorSettings;
  return 'TranslatorSettings(targetLanguage: ${_this.targetLanguage}, engine: ${_this.engine}, captureMode: ${_this.captureMode}, displayMode: ${_this.displayMode}, onboardingCompleted: ${_this.onboardingCompleted})';
}


}

/// @nodoc
abstract mixin class $TranslatorSettingsCopyWith<$Res>  {
  factory $TranslatorSettingsCopyWith(TranslatorSettings value, $Res Function(TranslatorSettings) _then) = _$TranslatorSettingsCopyWithImpl;
@useResult
$Res call({
 String targetLanguage, EngineType engine, CaptureMode captureMode, DisplayMode displayMode, bool onboardingCompleted
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
@pragma('vm:prefer-inline') @override $Res call({Object? targetLanguage = null,Object? engine = null,Object? captureMode = null,Object? displayMode = null,Object? onboardingCompleted = null,}) {
  return _then(TranslatorSettings(
targetLanguage: null == targetLanguage ? _self.targetLanguage : targetLanguage // ignore: cast_nullable_to_non_nullable
as String,engine: null == engine ? _self.engine : engine // ignore: cast_nullable_to_non_nullable
as EngineType,captureMode: null == captureMode ? _self.captureMode : captureMode // ignore: cast_nullable_to_non_nullable
as CaptureMode,displayMode: null == displayMode ? _self.displayMode : displayMode // ignore: cast_nullable_to_non_nullable
as DisplayMode,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String targetLanguage,  EngineType engine,  CaptureMode captureMode,  DisplayMode displayMode,  bool onboardingCompleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslatorSettings() when $default != null:
return $default(_that.targetLanguage,_that.engine,_that.captureMode,_that.displayMode,_that.onboardingCompleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String targetLanguage,  EngineType engine,  CaptureMode captureMode,  DisplayMode displayMode,  bool onboardingCompleted)  $default,) {final _that = this;
switch (_that) {
case _TranslatorSettings():
return $default(_that.targetLanguage,_that.engine,_that.captureMode,_that.displayMode,_that.onboardingCompleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String targetLanguage,  EngineType engine,  CaptureMode captureMode,  DisplayMode displayMode,  bool onboardingCompleted)?  $default,) {final _that = this;
switch (_that) {
case _TranslatorSettings() when $default != null:
return $default(_that.targetLanguage,_that.engine,_that.captureMode,_that.displayMode,_that.onboardingCompleted);case _:
  return null;

}
}

}

/// @nodoc


class _TranslatorSettings implements TranslatorSettings {
  const _TranslatorSettings({this.targetLanguage = 'ko', this.engine = EngineType.mlKit, this.captureMode = CaptureMode.fullScreen, this.displayMode = DisplayMode.list, this.onboardingCompleted = false});
  

/// BCP-47 언어 코드. 예: "ko", "en".
@override@JsonKey() final  String targetLanguage;
@override@JsonKey() final  EngineType engine;
@override@JsonKey() final  CaptureMode captureMode;
@override@JsonKey() final  DisplayMode displayMode;
@override@JsonKey() final  bool onboardingCompleted;

/// Create a copy of TranslatorSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslatorSettingsCopyWith<_TranslatorSettings> get copyWith => __$TranslatorSettingsCopyWithImpl<_TranslatorSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslatorSettings&&(identical(other.targetLanguage, targetLanguage) || other.targetLanguage == targetLanguage)&&(identical(other.engine, engine) || other.engine == engine)&&(identical(other.captureMode, captureMode) || other.captureMode == captureMode)&&(identical(other.displayMode, displayMode) || other.displayMode == displayMode)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted));
}


@override
int get hashCode {
    return Object.hash(runtimeType,targetLanguage,engine,captureMode,displayMode,onboardingCompleted);
}

@override
String toString() {
    return 'TranslatorSettings(targetLanguage: $targetLanguage, engine: $engine, captureMode: $captureMode, displayMode: $displayMode, onboardingCompleted: $onboardingCompleted)';
}


}

/// @nodoc
abstract mixin class _$TranslatorSettingsCopyWith<$Res> implements $TranslatorSettingsCopyWith<$Res> {
  factory _$TranslatorSettingsCopyWith(_TranslatorSettings value, $Res Function(_TranslatorSettings) _then) = __$TranslatorSettingsCopyWithImpl;
@override @useResult
$Res call({
 String targetLanguage, EngineType engine, CaptureMode captureMode, DisplayMode displayMode, bool onboardingCompleted
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
@override @pragma('vm:prefer-inline') $Res call({Object? targetLanguage = null,Object? engine = null,Object? captureMode = null,Object? displayMode = null,Object? onboardingCompleted = null,}) {
  return _then(_TranslatorSettings(
targetLanguage: null == targetLanguage ? _self.targetLanguage : targetLanguage // ignore: cast_nullable_to_non_nullable
as String,engine: null == engine ? _self.engine : engine // ignore: cast_nullable_to_non_nullable
as EngineType,captureMode: null == captureMode ? _self.captureMode : captureMode // ignore: cast_nullable_to_non_nullable
as CaptureMode,displayMode: null == displayMode ? _self.displayMode : displayMode // ignore: cast_nullable_to_non_nullable
as DisplayMode,onboardingCompleted: null == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
