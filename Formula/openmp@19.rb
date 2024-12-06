class OpenmpAt19 < Formula
  desc "LLVM Project OpenMP Runtime"
  homepage "https://llvm.org"
  url "https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.5/llvm-project-19.1.5.src.tar.xz"
  sha256 "bd8445f554aae33d50d3212a15e993a667c0ad1b694ac1977f3463db3338e542"
  license "Apache-2.0" => { with: "LLVM-exception" }
  head "https://github.com/llvm/llvm-project.git", branch: "main"

  livecheck do
    url :stable
    regex(%r{/^llvmorg[._-]v?(\d+(?:\.\d+)+)$/}i)
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "lld@19" => :build
  depends_on "llvm@19" => :build
  depends_on "ninja" => :build

  def install
    omppath = buildpath/"openmp"
    args = %W[
      -DCMAKE_C_COMPILER=#{Formula["llvm@19"].opt_bin/"clang"}
      -DCMAKE_CXX_COMPILER=#{Formula["llvm@19"].opt_bin/"clang++"}
      -DCMAKE_LINKER=#{Formula["lld@19"].opt_bin/"lld"}
      -DOPENMP_STANDALONE_BUILD=ON
      -DENABLE_LIBOMPTARGET=ON
    ]
    system "cmake", "-S", omppath, "-B", "build", *(std_cmake_args + args)
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system "false"
  end
end