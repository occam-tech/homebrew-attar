class Attar < Formula
  desc "Attar developer toolkit with CLI, compiler, and SDK"
  homepage "https://github.com/occam-tech/attar"
  url "https://github.com/occam-tech/attar-releases/releases/download/v0.1.0-dev.7626.g0415c6dab5ef/attar-0.1.0-dev.7626.g0415c6dab5ef-aarch64-apple-darwin.tar.gz"
  sha256 "24c19690e94fd2ddefe0fa3afea8c6f84e4651bcfaeddf9ed40249a8192d5cbc"
  version "0.1.0-dev.7626.g0415c6dab5ef"

  depends_on arch: :arm64
  depends_on macos: :sequoia
  depends_on "python@3.13"

  def install
    system "/usr/bin/xcrun", "--sdk", "macosx", "--show-sdk-path"
    python = Formula["python@3.13"].opt_bin/"python3.13"
    python_libexec = Formula["python@3.13"].opt_libexec/"bin"
    system python, "-B", "-c", <<~PY
      import sys
      from pathlib import Path

      root = Path(".").resolve()
      sys.path.insert(0, str(root / "tools"))
      from attar_cli import distribution

      installed = distribution.discover(root)
      if installed is None:
          raise SystemExit("Attar bundle manifest is missing")
      valid, detail, remediation = distribution.verify_files(installed)
      if not valid:
          raise SystemExit(f"Attar bundle verification failed: {detail}; {remediation}")
    PY
    libexec.install Dir["*"]
    (bin/"attar").write <<~EOS
      #!/bin/sh
      export PATH="#{python_libexec}:#{python.parent}:$PATH"
      export ATTAR_PYTHON3="#{python}"
      exec "#{libexec}/bin/attar" "$@"
    EOS
  end

  test do
    assert_predicate bin/"attar", :exist?
    system bin/"attar", "--version"
  end
end
