class RhoeLiquid < Formula
  desc "RhoePlatform Liquid template engine CLI"
  homepage "https://github.com/RhoePlatform/RhoeLiquid"
  url "https://github.com/RhoePlatform/RhoeLiquid/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "98be57fb259bf64582e4a91dbd173465d1528e00456ad37ac1ee59d810a2cf2f"
  license "Apache-2.0"
  head "https://github.com/RhoePlatform/RhoeLiquid.git", branch: "main"

  bottle do
    root_url "https://github.com/RhoePlatform/homebrew-rhoe/releases/download/rhoe-liquid-0.1.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "dd7def3c386b3dfad97e91718cdb3f114bb320611e56fab96415a576edbc6bce"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "21746b126f14dbb20fa9837687389704d52977b3f829829e63cf460b8fe86aea"
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
    swift = ENV["HOMEBREW_RHOE_LIQUID_SWIFT"]
    swift = "swift" if swift.blank?

    if OS.linux?
      ENV.clang
      resource("swift-6.3.2-ubuntu24.04").stage do
        swift = Pathname.pwd/"usr/bin/swift"
        swift_runtime = Pathname.pwd/"usr/lib/swift/linux"
        cd buildpath do
          system swift, "build", "-c", "release", "--product", "liquid", "--disable-sandbox"
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
      system swift, "build", "-c", "release", "--product", "liquid", "--disable-sandbox"
    end

    if OS.linux?
      swift_runtime_rpath = [
        "$ORIGIN",
        Formula["curl"].opt_lib,
        Formula["zlib-ng-compat"].opt_lib,
      ].join(":")
      liquid_rpath = [
        "$ORIGIN/../libexec/swift/linux",
        Formula["curl"].opt_lib,
        Formula["zlib-ng-compat"].opt_lib,
      ].join(":")
      (libexec/"swift/linux").children.each do |library|
        next unless library.basename.to_s.include?(".so")

        system "patchelf", "--force-rpath", "--set-rpath", swift_runtime_rpath, library
      end
      system "patchelf", "--force-rpath", "--set-rpath", liquid_rpath, buildpath/".build/release/liquid"
    end
    bin.install buildpath/".build/release/liquid"

    manpage = buildpath/"Documentation/CLI/man/liquid.1"
    man1.install manpage if manpage.exist?

    bash_completion_path = buildpath/"Documentation/CLI/completions/liquid.bash"
    bash_completion.install bash_completion_path => "liquid" if bash_completion_path.exist?

    zsh_completion_path = buildpath/"Documentation/CLI/completions/liquid.zsh"
    zsh_completion.install zsh_completion_path => "_liquid" if zsh_completion_path.exist?

    fish_completion_path = buildpath/"Documentation/CLI/completions/liquid.fish"
    fish_completion.install fish_completion_path if fish_completion_path.exist?
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/liquid --version")

    (testpath/"context.json").write('{"name":"rhoe"}')
    (testpath/"template.liquid").write("Hello {{ name | upcase }}")
    system bin/"liquid", "render", "template.liquid", "--context", "context.json", "--output", "out.txt"
    assert_equal "Hello RHOE", (testpath/"out.txt").read
  end
end
