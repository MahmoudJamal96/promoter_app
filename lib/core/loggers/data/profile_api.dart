String _path = "";
mixin ProfileApi {
  String get scannerApi;

  String get profileDataApi;

  String get profileSuspendApi;

  String get homeApi;

  String get loginApi;

  String get notificationList;

  String get registerApi;

  String get userRolesApi;

  String get pointsApi;

  String get marketPlaceApi;

  String get wheelPlayApi;

  String get path;

  String get profileEnabledApi;

  void setPath(String path);

  //01096325466
}

class PUBLIC implements ProfileApi {
  @override
  String get scannerApi => "scan/publicScan";

  @override
  String get homeApi => "";

  @override
  String get profileDataApi => "users/profile";

  @override
  String get profileSuspendApi => "users/deleteUser";

  @override
  String get profileEnabledApi => "users/enableUser";

  @override
  String get loginApi => '';

  @override
  String get userRolesApi => 'user-types/joiningrequest';

  @override
  String get marketPlaceApi => 'user-types/joiningrequest';

  @override
  String get notificationList => '';

  @override
  String get registerApi => '';

  @override
  String get pointsApi => '';

  @override
  String get path => _path;

  @override
  void setPath(String path) => _path = path;

  @override
  String get wheelPlayApi => 'milestone/play';
}

class OPERATION implements ProfileApi {
  @override
  String get scannerApi => "";

  @override
  String get userRolesApi => 'user-types/joiningrequest';

    @override
  String get profileEnabledApi => "users/enableUser";

  @override
  String get homeApi => "";

  @override
  String get profileDataApi => "";

  @override
  String get profileSuspendApi => 'users/deleteUser';

  @override
  String get loginApi => '';

  @override
  String get notificationList => '';

  @override
  String get registerApi => '';

  @override
  String get pointsApi => '';

  String get joiningRequest => 'joining-request';

  @override
  String get wheelPlayApi => 'milestone/play';

  @override
  String get path => resource!;

  String? resource;

  @override
  void setPath(String path) => resource = path;

  @override
  String get marketPlaceApi =>  '';
}

class POD implements ProfileApi {
  @override
  String get scannerApi => "scan";

    @override
  String get profileEnabledApi => "users/enableUser";

  @override
  String get homeApi => "home";

  @override
  String get userRolesApi => 'user-types/joiningrequest';

  @override
  String get loginApi => '';

  @override
  String get profileSuspendApi => 'users/deleteUser';

  @override
  String get profileDataApi => "users/profile";

  @override
  String get notificationList => '';

  @override
  String get registerApi => '';

  @override
  String get pointsApi => 'users/milestone/track';

  @override
  String get wheelPlayApi => 'milestone/play';

  @override
  String get path => _path;

  @override
  String get marketPlaceApi =>  '';

  @override
  void setPath(String path) => _path = path;
}

class DISTRIBUTER implements ProfileApi {
  @override
  String get scannerApi => "scan";

  @override
  String get homeApi => "home";

  @override
  String get userRolesApi => 'user-types/joiningrequest';

  @override
  String get loginApi => '';

  @override
  String get profileDataApi => "users/profile";

  @override
  String get notificationList => '';

  @override
  String get registerApi => '';

  @override
  String get pointsApi => 'users/milestone/track';

  @override
  String get wheelPlayApi => 'milestone/play';

  @override
  String get path => _path;

  @override
  String get marketPlaceApi =>  '';

  @override
  void setPath(String path) => _path = path;
  
  @override
  String get profileEnabledApi => throw UnimplementedError();
  
  @override
  String get profileSuspendApi => throw UnimplementedError();
}


class SUPERVISOR implements ProfileApi {
  @override
  String get scannerApi => "scan";


    @override
  String get profileEnabledApi => "users/enableUser";

  @override
  String get homeApi => "home";

  @override
  String get profileSuspendApi => 'users/deleteUser';

  @override
  String get userRolesApi => 'user-types/joiningrequest';

  @override
  String get loginApi => '';

  @override
  String get profileDataApi => "users/profile";

  @override
  String get notificationList => '';

  @override
  String get registerApi => '';

  @override
  String get pointsApi => 'users/milestone/track';

  @override
  String get wheelPlayApi => 'milestone/play';

  @override
  String get path => _path;

  @override
  String get marketPlaceApi =>  '';

  @override
  void setPath(String path) => _path = path;
}

class CUSTOMER implements ProfileApi {
  @override
  String get scannerApi => "scan";

  @override
  String get profileSuspendApi => 'users/deleteUser';


    @override
  String get profileEnabledApi => "users/enableUser";

  @override
  String get userRolesApi => 'user-types/joiningrequest';

  @override
  String get profileDataApi => "users/profile";

  @override
  String get homeApi => "home";

  @override
  String get loginApi => '';

  @override
  String get notificationList => '';

  @override
  String get registerApi => '';

  @override
  String get pointsApi => 'users/milestone/track';

  @override
  String get wheelPlayApi => 'milestone/play';

  @override
  String get path => _path;

  @override
  String get marketPlaceApi =>  '';

  @override
  void setPath(String path) => _path = path;
}

class WAREHOUSE implements ProfileApi {
  @override
  String get scannerApi => "";

    @override
  String get profileEnabledApi => "users/enableUser";

  @override
  String get profileSuspendApi => 'users/deleteUser';

  @override
  String get profileDataApi => "";

  @override
  String get userRolesApi => 'user-types/joiningrequest';

  @override
  String get homeApi => "";

  @override
  String get loginApi => '';

  @override
  String get notificationList => '';

  @override
  String get registerApi => '';

  @override
  String get pointsApi => '';

  @override
  String get wheelPlayApi => 'milestone/play';

  @override
  String get path => _path;

  @override
  String get marketPlaceApi =>  '';

  @override
  void setPath(String path) => _path = path;
}

class GENERIC implements ProfileApi {
  @override
  String get homeApi => '';

    @override
  String get profileEnabledApi => "users/enableUser";

  @override
  String get profileSuspendApi => 'users/deleteUser';

  String get governorateApi => 'governorate?allowPagination=false';

  @override
  String get profileDataApi => "users/profile";

  @override
  String get userRolesApi => 'user-types/joiningrequest';

  String get districtsApi => 'district?&allowPagination=false';

  @override
  String get scannerApi => '';

  @override
  String get loginApi => 'auth/login';

  @override
  String get notificationList => 'fetch-all-notifications';

  @override
  String get pointsApi => '';

  @override
  String get registerApi => 'joining-request';

  @override
  String get wheelPlayApi => 'milestone/play';

  @override
  String get path => _path;

  @override
  String get marketPlaceApi =>  '';

  @override
  void setPath(String path) => _path = path;
}
