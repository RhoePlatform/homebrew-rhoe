class RhoeMarkdown < Formula
  desc "Semantic Markdown compiler and projection engine CLI"
  homepage "https://github.com/RhoePlatform/RhoeMarkdown"
  url "https://github.com/RhoePlatform/RhoeMarkdown/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "531bd6ae16c50b45d2446fd340e803701358019da6366a090bf06cbdfd12f74f"
  license "Apache-2.0"
  head "https://github.com/RhoePlatform/RhoeMarkdown.git", branch: "main"

  bottle do
    root_url "https://github.com/RhoePlatform/homebrew-rhoe/releases/download/rhoe-markdown-0.1.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "1044ff03389748ad12996037582afe632934acad4d4971f6484fcf482196278d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ee858b7ae5bb08b19b7d01fba8fc00dc244831f9337457af1c50bf03ac6d74b1"
  end

  on_macos do
    depends_on xcode: ["26.0", :build]
  end

  on_linux do
    depends_on "patchelf" => :build
    depends_on "swift" => :build
    depends_on "curl"
    depends_on "zlib-ng-compat"
  end

  resource "swift-6.3.2-ubuntu24.04" do
    url "https://download.swift.org/swift-6.3.2-release/ubuntu2404/swift-6.3.2-RELEASE/swift-6.3.2-RELEASE-ubuntu24.04.tar.gz"
    sha256 "827b2e935b52425068729d277148f286b37886231299d71f9136bcffd7084339"
  end

  def system_library_path(library_name)
    Utils.safe_popen_read("ldconfig", "-p").each_line do |line|
      next unless line.include?("#{library_name} ")

      match = line.match(/=>\s+(\S+)/)
      return Pathname.new(match[1]) if match
    end

    nil
  end

  def vendor_linux_library_closure(root_library, destination)
    allowed_system_libraries = [
      /\Ald-linux/,
      /\Alibc\.so/,
      /\Alibdl\.so/,
      /\Alibgcc_s\.so/,
      /\Alibm\.so/,
      /\Alibpthread\.so/,
      /\Alibresolv\.so/,
      /\Alibrt\.so/,
      /\Alibstdc\+\+\.so/,
      /\Alibutil\.so/,
    ]
    pending_libraries = [root_library]
    vendored_libraries = {}

    until pending_libraries.empty?
      library_name = pending_libraries.shift
      next if vendored_libraries[library_name]

      source = system_library_path(library_name)
      odie "Unable to locate #{library_name} for the Linux bottle runtime" if source.nil?

      cp source.realpath, destination/library_name
      vendored_libraries[library_name] = true

      Utils.safe_popen_read("ldd", source).each_line do |line|
        match = line.match(/=>\s+(\S+)/)
        next if match.nil?

        dependency = File.basename(match[1])
        next if allowed_system_libraries.any? { |pattern| dependency.match?(pattern) }
        next if vendored_libraries[dependency]

        pending_libraries << dependency
      end
    end
  end

  def install
    swift = ENV["HOMEBREW_RHOE_MARKDOWN_SWIFT"]
    swift = "swift" if swift.blank?

    if OS.linux?
      ENV.clang
      resource("swift-6.3.2-ubuntu24.04").stage do
        swift = Pathname.pwd/"usr/bin/swift"
        swift_runtime = Pathname.pwd/"usr/lib/swift/linux"
        cd buildpath do
          system swift, "build", "-c", "release", "--product", "rhoemd", "--disable-sandbox"
        end
        %w[
          libBlocksRuntime.so
          libFoundation.so
          libFoundationEssentials.so
          libFoundationInternationalization.so
          libFoundationNetworking.so
          libFoundationXML.so
          lib_FoundationICU.so
          libdispatch.so
          libswift_Builtin_float.so
          libswift_Concurrency.so
          libswift_RegexParser.so
          libswift_StringProcessing.so
          libswiftCore.so
          libswiftDispatch.so
          libswiftGlibc.so
          libswiftSynchronization.so
        ].each do |library|
          (libexec/"swift/linux").install swift_runtime/library
        end
      end
      vendor_linux_library_closure("libxml2.so.2", libexec/"swift/linux")
    else
      system swift, "build", "-c", "release", "--product", "rhoemd", "--disable-sandbox"
    end

    if OS.linux?
      swift_runtime_rpath = [
        "$ORIGIN",
        Formula["curl"].opt_lib,
        Formula["zlib-ng-compat"].opt_lib,
      ].join(":")
      rhoemd_rpath = [
        "$ORIGIN/../libexec/swift/linux",
        Formula["curl"].opt_lib,
        Formula["zlib-ng-compat"].opt_lib,
      ].join(":")
      (libexec/"swift/linux").children.each do |library|
        next unless library.basename.to_s.include?(".so")

        system "patchelf", "--force-rpath", "--set-rpath", swift_runtime_rpath, library
      end
      system "patchelf", "--force-rpath", "--set-rpath", rhoemd_rpath, buildpath/".build/release/rhoemd"
    end
    bin.install buildpath/".build/release/rhoemd"
    bin.install_symlink bin/"rhoemd" => "markdown"
  end

  test do
    assert_match "RhoeMarkdownKit #{version}", shell_output("#{bin}/rhoemd --version")
    assert_match "RhoeMarkdownKit #{version}", shell_output("#{bin}/markdown --version")

    (testpath/"input.md").write("# Hello\n\nThis is **rhoemd**.")
    system bin/"rhoemd", "input.md", "--format", "html", "--output", "output.html"
    assert_match "<strong>rhoemd</strong>", (testpath/"output.html").read

    system bin/"markdown", "input.md", "--format", "html", "--output", "alias.html"
    assert_match "<strong>rhoemd</strong>", (testpath/"alias.html").read
  end
end
