# typed: true

class OpenmpAT19 < Formula
  desc "LLVM Project OpenMP Runtime"
  homepage "https://llvm.org"
  url "https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/llvm-project-19.1.7.src.tar.xz"
  sha256 "82401fea7b79d0078043f7598b835284d6650a75b93e64b6f761ea7b63097501"
  license "Apache-2.0" => { with: "LLVM-exception" }
  livecheck do
    url :stable
    regex(%r{/^llvmorg[._-]v?(\d+(?:\.\d+)+)$/}i)
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "llvm@19"
  depends_on :linux
  depends_on "ninja" => :build

  def install
    omppath = buildpath / "openmp"
    args = %W[
      -DCMAKE_C_COMPILER=#{Formula["llvm@19"].opt_bin / "clang"}
      -DCMAKE_CXX_COMPILER=#{Formula["llvm@19"].opt_bin / "clang++"}
      -DCMAKE_LINKER=#{Formula["llvm@19"].opt_bin / "llvm-link"}
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
