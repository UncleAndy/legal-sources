{
  description = "Python-проект с поддержкой pip и requirements.txt";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pythonEnv = pkgs.python3; # Можно указать конкретную версию, например pkgs.python311
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pythonEnv
            pkgs.python3Packages.virtualenv
            pkgs.gcc # Нужен для компиляции некоторых C-extensions при pip install
          ];

          shellHook = ''
            source ${./nix/prompt.sh}

            # Создаем и активируем virtualenv, если его еще нет
            if [ ! -d ".venv" ]; then
              virtualenv .venv
            fi
            source .venv/bin/activate

            # Автоматическая установка/обновление зависимостей при входе
            if [ -f "requirements.txt" ]; then
              echo "==> Обнаружен requirements.txt, проверяем зависимости..."
              pip install -r requirements.txt
            fi
          '';
        };
      });
}

