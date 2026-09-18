class Attar < Formula
  desc "Attar developer toolkit with CLI, compiler, and SDK"
  homepage "https://github.com/occam-tech/attar"
  url "https://github.com/occam-tech/attar-releases/releases/download/v0.1.0-dev.7620.g57143d8614b3/attar-0.1.0-dev.7620.g57143d8614b3-aarch64-apple-darwin.tar.gz"
  sha256 "dc6b3c5db94d1a8684c4da14b2079c80dcf356b5bb873c63dcce7b9b468979b5"
  version "0.1.0-dev.7620.g57143d8614b3"

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
