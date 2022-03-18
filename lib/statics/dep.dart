import 'package:get/get.dart';

abstract class Dep {
  static void lazyPut<S>(InstanceBuilderCallback<S> builder,
      {String? tag, bool fenix = false}) {
    GetInstance().lazyPut<S>(builder, tag: tag, fenix: fenix);
  }

  static Future<S> putAsync<S>(AsyncInstanceBuilderCallback<S> builder,
          {String? tag, bool permanent = false}) async =>
      GetInstance().putAsync<S>(builder, tag: tag, permanent: permanent);

  static void create<S>(InstanceBuilderCallback<S> builder,
          {String? tag, bool permanent = true}) =>
      GetInstance().create<S>(builder, tag: tag, permanent: permanent);

  static S find<S>({String? tag}) => GetInstance().find<S>(tag: tag);

  static S put<S>(S dependency,
          {String? tag,
          bool permanent = false,
          InstanceBuilderCallback<S>? builder}) =>
      GetInstance().put<S>(dependency, tag: tag, permanent: permanent);

  static Future<bool> delete<S>({String? tag, bool force = false}) async =>
      GetInstance().delete<S>(tag: tag, force: force);

  static Future<void> deleteAll({bool force = false}) async =>
      GetInstance().deleteAll(force: force);

  static void reloadAll({bool force = false}) =>
      GetInstance().reloadAll(force: force);

  static void reload<S>({String? tag, String? key, bool force = false}) =>
      GetInstance().reload<S>(tag: tag, key: key, force: force);

  static bool isRegistered<S>({String? tag}) =>
      GetInstance().isRegistered<S>(tag: tag);

  static bool isPrepared<S>({String? tag}) =>
      GetInstance().isPrepared<S>(tag: tag);

  static void replace<P>(P child, {String? tag}) {
    final info = GetInstance().getInstanceInfo<P>(tag: tag);
    final permanent = (info.isPermanent ?? false);
    delete<P>(tag: tag, force: permanent);
    put(child, tag: tag, permanent: permanent);
  }

  static void lazyReplace<P>(InstanceBuilderCallback<P> builder,
      {String? tag, bool? fenix}) {
    final info = GetInstance().getInstanceInfo<P>(tag: tag);
    final permanent = (info.isPermanent ?? false);
    delete<P>(tag: tag, force: permanent);
    lazyPut(builder, tag: tag, fenix: fenix ?? permanent);
  }
}
