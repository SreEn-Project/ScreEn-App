// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_permissions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppPermissions {

/// 다른 앱 위에 표시 (SYSTEM_ALERT_WINDOW). 시스템 설정 화면에서만 켤 수 있다.
 bool get overlay;/// 알림 (POST_NOTIFICATIONS, Android 13+). 없으면 서비스 알림 · "중지"가 안 보인다.
 bool get notification;/// 알림을 두 번 거부해 팝업이 더 이상 뜨지 않는 상태. 이때는 앱 설정 화면으로 보낸다.
 bool get notificationBlocked;
/// Create a copy of AppPermissions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppPermissionsCopyWith<AppPermissions> get copyWith => _$AppPermissionsCopyWithImpl<AppPermissions>(this as AppPermissions, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AppPermissions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppPermissions&&(identical(other.overlay, _this.overlay) || other.overlay == _this.overlay)&&(identical(other.notification, _this.notification) || other.notification == _this.notification)&&(identical(other.notificationBlocked, _this.notificationBlocked) || other.notificationBlocked == _this.notificationBlocked));
}


@override
int get hashCode {
  final _this = this as AppPermissions;
  return Object.hash(runtimeType,_this.overlay,_this.notification,_this.notificationBlocked);
}

@override
String toString() {
  final _this = this as AppPermissions;
  return 'AppPermissions(overlay: ${_this.overlay}, notification: ${_this.notification}, notificationBlocked: ${_this.notificationBlocked})';
}


}

/// @nodoc
abstract mixin class $AppPermissionsCopyWith<$Res>  {
  factory $AppPermissionsCopyWith(AppPermissions value, $Res Function(AppPermissions) _then) = _$AppPermissionsCopyWithImpl;
@useResult
$Res call({
 bool overlay, bool notification, bool notificationBlocked
});




}
/// @nodoc
class _$AppPermissionsCopyWithImpl<$Res>
    implements $AppPermissionsCopyWith<$Res> {
  _$AppPermissionsCopyWithImpl(this._self, this._then);

  final AppPermissions _self;
  final $Res Function(AppPermissions) _then;

/// Create a copy of AppPermissions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? overlay = null,Object? notification = null,Object? notificationBlocked = null,}) {
  return _then(AppPermissions(
overlay: null == overlay ? _self.overlay : overlay // ignore: cast_nullable_to_non_nullable
as bool,notification: null == notification ? _self.notification : notification // ignore: cast_nullable_to_non_nullable
as bool,notificationBlocked: null == notificationBlocked ? _self.notificationBlocked : notificationBlocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppPermissions].
extension AppPermissionsPatterns on AppPermissions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppPermissions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppPermissions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppPermissions value)  $default,){
final _that = this;
switch (_that) {
case _AppPermissions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppPermissions value)?  $default,){
final _that = this;
switch (_that) {
case _AppPermissions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool overlay,  bool notification,  bool notificationBlocked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppPermissions() when $default != null:
return $default(_that.overlay,_that.notification,_that.notificationBlocked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool overlay,  bool notification,  bool notificationBlocked)  $default,) {final _that = this;
switch (_that) {
case _AppPermissions():
return $default(_that.overlay,_that.notification,_that.notificationBlocked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool overlay,  bool notification,  bool notificationBlocked)?  $default,) {final _that = this;
switch (_that) {
case _AppPermissions() when $default != null:
return $default(_that.overlay,_that.notification,_that.notificationBlocked);case _:
  return null;

}
}

}

/// @nodoc


class _AppPermissions extends AppPermissions {
  const _AppPermissions({required this.overlay, required this.notification, this.notificationBlocked = false}): super._();
  

/// 다른 앱 위에 표시 (SYSTEM_ALERT_WINDOW). 시스템 설정 화면에서만 켤 수 있다.
@override final  bool overlay;
/// 알림 (POST_NOTIFICATIONS, Android 13+). 없으면 서비스 알림 · "중지"가 안 보인다.
@override final  bool notification;
/// 알림을 두 번 거부해 팝업이 더 이상 뜨지 않는 상태. 이때는 앱 설정 화면으로 보낸다.
@override@JsonKey() final  bool notificationBlocked;

/// Create a copy of AppPermissions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppPermissionsCopyWith<_AppPermissions> get copyWith => __$AppPermissionsCopyWithImpl<_AppPermissions>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppPermissions&&(identical(other.overlay, overlay) || other.overlay == overlay)&&(identical(other.notification, notification) || other.notification == notification)&&(identical(other.notificationBlocked, notificationBlocked) || other.notificationBlocked == notificationBlocked));
}


@override
int get hashCode {
    return Object.hash(runtimeType,overlay,notification,notificationBlocked);
}

@override
String toString() {
    return 'AppPermissions(overlay: $overlay, notification: $notification, notificationBlocked: $notificationBlocked)';
}


}

/// @nodoc
abstract mixin class _$AppPermissionsCopyWith<$Res> implements $AppPermissionsCopyWith<$Res> {
  factory _$AppPermissionsCopyWith(_AppPermissions value, $Res Function(_AppPermissions) _then) = __$AppPermissionsCopyWithImpl;
@override @useResult
$Res call({
 bool overlay, bool notification, bool notificationBlocked
});




}
/// @nodoc
class __$AppPermissionsCopyWithImpl<$Res>
    implements _$AppPermissionsCopyWith<$Res> {
  __$AppPermissionsCopyWithImpl(this._self, this._then);

  final _AppPermissions _self;
  final $Res Function(_AppPermissions) _then;

/// Create a copy of AppPermissions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? overlay = null,Object? notification = null,Object? notificationBlocked = null,}) {
  return _then(_AppPermissions(
overlay: null == overlay ? _self.overlay : overlay // ignore: cast_nullable_to_non_nullable
as bool,notification: null == notification ? _self.notification : notification // ignore: cast_nullable_to_non_nullable
as bool,notificationBlocked: null == notificationBlocked ? _self.notificationBlocked : notificationBlocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
