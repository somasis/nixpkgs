{ lib
, attrs
, buildPythonPackage
, fetchFromGitHub
, hypothesis
, immutables
, motor
, msgpack
, poetry-core
, pytestCheckHook
, pythonOlder
, pyyaml
, tomlkit
, typing-extensions
, ujson
}:

buildPythonPackage rec {
  pname = "cattrs";
  version = "1.10.0";
  format = "pyproject";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "python-attrs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-VbfQMMDO03eeUHAACxoX6a3DKmzoF9EfLuTpvaY6bWs=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    attrs
  ] ++ lib.optionals (pythonOlder "3.7") [
    typing-extensions
  ];

  checkInputs = [
    hypothesis
    immutables
    motor
    msgpack
    pytestCheckHook
    pyyaml
    tomlkit
    ujson
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "-l --benchmark-sort=fullname --benchmark-warmup=true --benchmark-warmup-iterations=5  --benchmark-group-by=fullname" "" \
      --replace 'orjson = "^3.5.2"' "" \
      --replace "[tool.poetry.group.dev.dependencies]" "[tool.poetry.dev-dependencies]"
    substituteInPlace tests/test_preconf.py \
      --replace "from orjson import dumps as orjson_dumps" "" \
      --replace "from orjson import loads as orjson_loads" ""
  '';

  preCheck = ''
    export HOME=$(mktemp -d);
  '';

  disabledTestPaths = [
    # Don't run benchmarking tests
    "bench/test_attrs_collections.py"
    "bench/test_attrs_nested.py"
    "bench/test_attrs_primitives.py"
    "bench/test_primitives.py"
  ];

  disabledTests = [
    # orjson is not available as it requires Rust nightly features to compile its requirements
    "test_orjson"
  ];

  pythonImportsCheck = [
    "cattr"
  ];

  meta = with lib; {
    description = "Python custom class converters for attrs";
    homepage = "https://github.com/python-attrs/cattrs";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ fab ];
  };
}
