{
  fetchurl,
  lib,
  python313Packages,
}:

let
  inherit (python313Packages)
    annotated-types
    asgiref
    atomicwrites
    buildPythonApplication
    buildPythonPackage
    click
    croniter
    cryptography
    daphne
    dateparser
    django-extensions
    django-ninja
    django-stubs
    django-taggit
    django_6
    email-validator
    hatch-vcs
    hatchling
    httpx
    ipython
    jsonschema
    mypy-extensions
    psutil
    py-machineid
    python-dotenv
    requests
    rich
    rich-click
    setuptools
    supervisor
    typing-extensions
    typing-inspection
    tzdata
    uv
    w3lib
    ;

  mkWheel =
    {
      pname,
      version,
      url,
      hash,
      dependencies ? [ ],
    }:
    buildPythonPackage {
      inherit
        pname
        version
        dependencies
        ;
      format = "wheel";
      src = fetchurl {
        inherit url hash;
      };
      catchConflicts = false;
      doCheck = false;
      pythonImportsCheck = [ ];
    };

  django = django_6;

  platformdirs = mkWheel {
    pname = "platformdirs";
    version = "4.9.6";
    url = "https://files.pythonhosted.org/packages/75/a6/a0a304dc33b49145b21f4808d763822111e67d1c3a32b524a1baf947b6e1/platformdirs-4.9.6-py3-none-any.whl";
    hash = "sha256-5hrbHV5cs0QbS3cQvqfkwSJQyklDkijMECHADc+sCRc=";
  };

  pydantic-settings = mkWheel {
    pname = "pydantic-settings";
    version = "2.12.0";
    url = "https://files.pythonhosted.org/packages/c1/60/5d4751ba3f4a40a6891f24eec885f51afd78d208498268c734e256fb13c4/pydantic_settings-2.12.0-py3-none-any.whl";
    hash = "sha256-/duf2ZpbGNqDeylxA5HpRbHjDBNUd/SECE7lE625OAk=";
    dependencies = [
      pydantic
      python-dotenv
      typing-inspection
    ];
  };

  pydantic-core = mkWheel {
    pname = "pydantic-core";
    version = "2.46.4";
    url = "https://files.pythonhosted.org/packages/07/f8/41db9de19d7987d6b04715a02b3b40aea467000275d9d758ffaa31af7d50/pydantic_core-2.46.4-cp313-cp313-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
    hash = "sha256-lVEYc2P/wN4qALLkfCWurrECC2m2aHYpZt8V/FZZ3Vo=";
    dependencies = [ typing-extensions ];
  };

  pydantic = mkWheel {
    pname = "pydantic";
    version = "2.13.4";
    url = "https://files.pythonhosted.org/packages/fd/7b/122376b1fd3c62c1ed9dc80c931ace4844b3c55407b6fb2d199377c9736f/pydantic-2.13.4-py3-none-any.whl";
    hash = "sha256-RaKCzeMdgII2/X6p2RmxKGU8izizk9HEqzNcYpJNmro=";
    dependencies = [
      annotated-types
      pydantic-core
      typing-extensions
      typing-inspection
    ];
  };

  pip = mkWheel {
    pname = "pip";
    version = "26.0.1";
    url = "https://files.pythonhosted.org/packages/de/f0/c81e05b613866b76d2d1066490adf1a3dbc4ee9d9c839961c3fc8a6997af/pip-26.0.1-py3-none-any.whl";
    hash = "sha256-vbGwj0J0gz1iwaop4gkHNlos65UEEN8V/JUhutRAEis=";
  };

  django-settings-holder = mkWheel {
    pname = "django-settings-holder";
    version = "0.3.0";
    url = "https://files.pythonhosted.org/packages/f5/e3/0759620f917f7f7585375c1edb2875ed6c95597cf6645c3f5a21e0d44046/django_settings_holder-0.3.0-py3-none-any.whl";
    hash = "sha256-l8acRxKfzYvl/DUfgM8xyPP37K7EGLwsICADgqC+UsA=";
    dependencies = [ django ];
  };

  django-signal-webhooks = mkWheel {
    pname = "django-signal-webhooks";
    version = "0.3.1";
    url = "https://files.pythonhosted.org/packages/eb/7a/0f193eb3351af74de8c3d0fa89f72005caf63ad9456e281e5cd9b2be1a10/django_signal_webhooks-0.3.1-py3-none-any.whl";
    hash = "sha256-hjvrlPZTagmwTVFt9hAwN3SIkfX0VV3zZ5b7VMhkmFQ=";
    dependencies = [
      asgiref
      cryptography
      django
      django-settings-holder
      httpx
    ];
  };

  django-admin-data-views = mkWheel {
    pname = "django-admin-data-views";
    version = "0.4.3";
    url = "https://files.pythonhosted.org/packages/e7/4a/c441cc177beb536c80747eaffa13ea14214cb7a5b67f5ae7bbec6948ba72/django_admin_data_views-0.4.3-py3-none-any.whl";
    hash = "sha256-ZhtNWBYdKD7uHRMQE9s+g6SZCEck9I/QzVvZMVt2jjg=";
    dependencies = [
      django
      django-settings-holder
    ];
  };

  django-object-actions = mkWheel {
    pname = "django-object-actions";
    version = "5.1.2";
    url = "https://files.pythonhosted.org/packages/37/23/c5743780fc68433f244fba86cd64b513b9d6a9491714ac700a4654b5e00f/django_object_actions-5.1.2-py3-none-any.whl";
    hash = "sha256-Nm3NXM+z72oWzkwUe+jfKjW1LWN+s2+5xVjihBmuQDg=";
  };

  base32-crockford = mkWheel {
    pname = "base32-crockford";
    version = "0.3.0";
    url = "https://files.pythonhosted.org/packages/4d/6f/7ad1176c56c920e9841b14923f81545a4243876628312f143915561770d2/base32_crockford-0.3.0-py2.py3-none-any.whl";
    hash = "sha256-KV71/79u2Wtuc5/9Nr6Y+n6QogbdGMOazvsVd37t/m4=";
  };

  sonic-client = mkWheel {
    pname = "sonic-client";
    version = "1.0.0";
    url = "https://files.pythonhosted.org/packages/9d/12/e98f8533a5c5b28271be79b38e0648a69e4068907568a435276532bb2871/sonic_client-1.0.0-py3-none-any.whl";
    hash = "sha256-KRvykoYel6Lddl/wyHVOqWMTg2gNMaY+w9pvWqX0vto=";
  };

  uuid7 = mkWheel {
    pname = "uuid7";
    version = "0.1.0";
    url = "https://files.pythonhosted.org/packages/b5/77/8852f89a91453956582a85024d80ad96f30a41fed4c2b3dce0c9f12ecc7e/uuid7-0.1.0-py2.py3-none-any.whl";
    hash = "sha256-XiWbtjyMtK3tWSf/QbREqA0McSTooM7Xz0TvofXMz2E=";
  };

  python-statemachine = mkWheel {
    pname = "python-statemachine";
    version = "3.1.2";
    url = "https://files.pythonhosted.org/packages/f2/f5/fe9072bfc9d245138561c09bf05b841bf6d92b4ce93d44dbfa18d96e498e/python_statemachine-3.1.2-py3-none-any.whl";
    hash = "sha256-idzby/exl62t4WE4x1vuTzLgyYt+6xjTCuscgw273WI=";
  };

  jambo = buildPythonPackage {
    pname = "jambo";
    version = "0.1.7";
    pyproject = true;
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/91/f5/74de157c7aece6a070f99f18201a0e2f46cdfd0f9e337efd411745ed9b22/jambo-0.1.7.tar.gz";
      hash = "sha256-34mrggnr33pukiUuySWXnNPTKBG/SoGCqX3DW331j3Q=";
    };
    build-system = [
      hatchling
      hatch-vcs
    ];
    dependencies = [
      email-validator
      jsonschema
      pydantic
    ];
    catchConflicts = false;
    doCheck = false;
    pythonImportsCheck = [ "jambo" ];
  };

  abxbus = mkWheel {
    pname = "abxbus";
    version = "2.5.8";
    url = "https://files.pythonhosted.org/packages/d9/4d/c459e6af90af4eac2aec3a265931e396cfe15b6cade2c038e6b47caee34d/abxbus-2.5.8-py3-none-any.whl";
    hash = "sha256-rEUOTlNCuflN+r1jjTo/PvQRxkyfaWUP2oCBk4YIqLw=";
    dependencies = [
      pydantic
      typing-extensions
      uuid7
    ];
  };

  abxpkg = mkWheel {
    pname = "abxpkg";
    version = "1.11.129";
    url = "https://files.pythonhosted.org/packages/99/f9/1ecb7535cefee7c1af5f3af41aa3788e6277e0292aee243fdaf426ede130/abxpkg-1.11.129-py3-none-any.whl";
    hash = "sha256-f/dOPSzU92imJGl8JdeaE6BfNl2SfQRlUWtBZD/K2LQ=";
    dependencies = [
      pip
      platformdirs
      pydantic
      rich-click
      typing-extensions
    ];
  };

  abx-plugins = mkWheel {
    pname = "abx-plugins";
    version = "1.11.132";
    url = "https://files.pythonhosted.org/packages/7f/31/cc8373054c20b7a7c01738c22d374bd9e762f6d29c7bd527658d194cda0d/abx_plugins-1.11.132-py3-none-any.whl";
    hash = "sha256-7PrGefO4GYeEAAaauOJ5SqlH/iLLRQj4BfV6HFeKBOk=";
    dependencies = [
      abxbus
      abxpkg
      jambo
      rich-click
      uv
    ];
  };

  abx-dl = mkWheel {
    pname = "abx-dl";
    version = "1.11.132";
    url = "https://files.pythonhosted.org/packages/85/61/1b3ac63352bb5be382c099864afd824cecaf5267eb9dc83289429dac1418/abx_dl-1.11.132-py3-none-any.whl";
    hash = "sha256-v6GqsGX6tMN3ZMSOCZNua772MmAODhYCsKwCSDAHP64=";
    dependencies = [
      abx-plugins
      abxbus
      abxpkg
      jambo
      platformdirs
      psutil
      pydantic
      pydantic-settings
      requests
      rich
      rich-click
    ];
  };
in
buildPythonApplication {
  pname = "archivebox";
  version = "0.9.34rc15";
  format = "wheel";
  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/d7/78/d84e760fc63e06d8e0b76b232a9523c51ed085b518bc5f4c2d80cab2c5dd/archivebox-0.9.34rc15-py3-none-any.whl";
    hash = "sha256-UoUMKaVe9lkA36oV7Ox4yVxXEOsNDf7fLQIhZgp1CiI=";
  };
  dependencies = [
    abx-dl
    abx-plugins
    abxbus
    abxpkg
    atomicwrites
    base32-crockford
    click
    croniter
    daphne
    dateparser
    django
    django-admin-data-views
    django-extensions
    django-ninja
    django-object-actions
    django-signal-webhooks
    django-stubs
    django-taggit
    ipython
    platformdirs
    psutil
    py-machineid
    pydantic
    pydantic-settings
    python-statemachine
    requests
    rich
    rich-click
    setuptools
    sonic-client
    supervisor
    tzdata
    uuid7
    w3lib
  ];
  catchConflicts = false;
  doCheck = false;
  pythonImportsCheck = [ ];
  meta = {
    description = "Self-hosted internet archiving solution";
    homepage = "https://archivebox.io/";
    license = lib.licenses.mit;
    mainProgram = "archivebox";
    platforms = [ "x86_64-linux" ];
  };
}
