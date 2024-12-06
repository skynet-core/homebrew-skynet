class Openmp < Formula
  desc "The LLVM Project is a collection of modular and reusable compiler and toolchain technologies."
  homepage "http://llvm.org"
  license "Apache-2.0" => { with: "LLVM-exception" }
  head "https://github.com/llvm/llvm-project.git", branch: "main"
  
  stable do
    url "https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.5/llvm-project-19.1.5.src.tar.xz"
    sha256 "bd8445f554aae33d50d3212a15e993a667c0ad1b694ac1977f3463db3338e542"
  end

  livecheck do
    url :stable
    regex(/^llvmorg[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "llvm" => :build
  depends_on "lld" => :build

  def install
    omppath = buildpath/"openmp"
    args = %W[
      -DCMAKE_C_COMPILER=#{Formula["llvm"].opt_bin/"clang"}
      -DCMAKE_CXX_COMPILER=#{Formula["llvm"].opt_bin/"clang++"}
      -DCMAKE_LINKER=#{Formula["llvm"].opt_bin/"lld"}
      -DOPENMP_STANDALONE_BUILD=ON
      -DENABLE_LIBOMPTARGET=ON
    ]

    system "cmake", "-S", omppath, "-B", "build", *(std_cmake_args + args)
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test openmp`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system bin/"program", "do", "something"`.
    system "false"
  end
end
