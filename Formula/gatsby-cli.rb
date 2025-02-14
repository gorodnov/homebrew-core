require "language/node"

class GatsbyCli < Formula
  desc "Gatsby command-line interface"
  homepage "https://www.gatsbyjs.org/docs/gatsby-cli/"
  # gatsby-cli should only be updated every 10 releases on multiples of 10
  url "https://registry.npmjs.org/gatsby-cli/-/gatsby-cli-4.3.0.tgz"
  sha256 "38259b218da21a6050c5b3686b48a04f049a101ff7f5b2ebf3cfbfa4731c0330"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "dde5161966e0a67706f254bde1732097891a0dc72b5c10a6ae42bd6be0ab09a8"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "dde5161966e0a67706f254bde1732097891a0dc72b5c10a6ae42bd6be0ab09a8"
    sha256 cellar: :any_skip_relocation, monterey:       "d3f3a1fbb4cbb72728efb0193abf527b4e3432901f8725473373d356f3229389"
    sha256 cellar: :any_skip_relocation, big_sur:        "d3f3a1fbb4cbb72728efb0193abf527b4e3432901f8725473373d356f3229389"
    sha256 cellar: :any_skip_relocation, catalina:       "d3f3a1fbb4cbb72728efb0193abf527b4e3432901f8725473373d356f3229389"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "b20136194f34bf96c39bd27377622fbf7fad9a1f314655023c7d0cf1d51c7737"
  end

  depends_on "node"

  on_macos do
    depends_on "macos-term-size"
  end

  on_linux do
    depends_on "xsel"
  end

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir[libexec/"bin/*"]

    # Avoid references to Homebrew shims
    rm_f libexec/"lib/node_modules/gatsby-cli/node_modules/websocket/builderror.log"

    term_size_vendor_dir = libexec/"lib/node_modules/#{name}/node_modules/term-size/vendor"
    term_size_vendor_dir.rmtree # remove pre-built binaries
    if OS.mac?
      macos_dir = term_size_vendor_dir/"macos"
      macos_dir.mkpath
      # Replace the vendored pre-built term-size with one we build ourselves
      ln_sf (Formula["macos-term-size"].opt_bin/"term-size").relative_path_from(macos_dir), macos_dir
    end

    clipboardy_fallbacks_dir = libexec/"lib/node_modules/#{name}/node_modules/clipboardy/fallbacks"
    clipboardy_fallbacks_dir.rmtree # remove pre-built binaries
    if OS.linux?
      linux_dir = clipboardy_fallbacks_dir/"linux"
      linux_dir.mkpath
      # Replace the vendored pre-built xsel with one we build ourselves
      ln_sf (Formula["xsel"].opt_bin/"xsel").relative_path_from(linux_dir), linux_dir
    end
  end

  test do
    system bin/"gatsby", "new", "hello-world", "https://github.com/gatsbyjs/gatsby-starter-hello-world"
    assert_predicate testpath/"hello-world/package.json", :exist?, "package.json was not cloned"
  end
end
