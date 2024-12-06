class OpenmpAT18 < Formula
  desc "The LLVM Project is a collection of modular and reusable compiler and toolchain technologies."
  homepage "http://llvm.org"
  url "https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/llvm-project-18.1.8.src.tar.xz"
  sha256 "0b58557a6d32ceee97c8d533a59b9212d87e0fc4d2833924eb6c611247db2f2a"
  license "Apache-2.0" => { with: "LLVM-exception" }

  livecheck do
    url :stable
    regex(/^llvmorg[._-]v?(18(?:\.\d+)+)$/i)
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "llvm@18" => :build

  keg_only :versioned_formula

  def install
    omppath = buildpath/"openmp"
    args = %W[
      -DCMAKE_C_COMPILER=#{Formula["llvm@18"].opt_bin/"clang"}
      -DCMAKE_CXX_COMPILER=#{Formula["llvm@18"].opt_bin/"clang++"}
      -DCMAKE_LINKER=#{Formula["llvm@18"].opt_bin/"lld"}
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
