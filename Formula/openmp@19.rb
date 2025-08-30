class OpenmpAT19 < Formula
  desc "LLVM Project OpenMP Runtime"
  homepage "https://llvm.org"
  url "https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/llvm-project-19.1.7.src.tar.xz"
  sha256 "82401fea7b79d0078043f7598b835284d6650a75b93e64b6f761ea7b63097501"
  license "Apache-2.0" => "LLVM-exception"
  livecheck do
    url :stable
    regex(%r{/^llvmorg[._-]v?(\d+(?:\.\d+)+)$/}i)
  end

  keg_only :versioned_formula
  LLVM_MAJOR = 19
  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on :linux
  depends_on "llvm@#{LLVM_MAJOR}"
  depends_on "lld@#{LLVM_MAJOR}"

  def install
    set_env
    rpaths = build_rpaths
    omppath = buildpath / "openmp"
    args = cmake_args(rpaths)
    build_and_install(omppath, args)
  end

  def build_and_install(source, args)
    system "cmake", "-S", source, "-B", "build", *(std_cmake_args + args)
    system "cmake", "--build", "build", "--parallel", Hardware::CPU.cores.to_s
    system "cmake", "--install", "build"
  end

  def set_env
    ENV.prepend_path "LD_LIBRARY_PATH", Formula["llvm@#{LLVM_MAJOR}"].opt_lib
  end

  def build_rpaths
    [loader_path, rpath(source: lib / "openmp@#{LLVM_MAJOR}"), Formula["llvm@#{LLVM_MAJOR}"].opt_lib.to_s]
  end

  def cmake_args(rpaths)
    [
      "-DCMAKE_BUILD_TYPE=Release", "-DCMAKE_LINKER_TYPE=LLD",
      "-DCMAKE_CXX_USING_LINKER_LLD=#{Formula["lld@#{LLVM_MAJOR}"].opt_bin / "lld"}",
      "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON", "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
      "-DCMAKE_C_FLAGS=-O3 -march=native -mtune=native", "-DCMAKE_CXX_FLAGS=-O3 -march=native -mtune=native",
      "-DCMAKE_LINKER_FLAGS=-L#{Formula["llvm@#{LLVM_MAJOR}"].opt_lib}",
      "-DCMAKE_C_COMPILER=#{Formula["llvm@#{LLVM_MAJOR}"].opt_bin / "clang"}",
      "-DCMAKE_CXX_COMPILER=#{Formula["llvm@#{LLVM_MAJOR}"].opt_bin / "clang++"}",
      "-DOPENMP_STANDALONE_BUILD=ON", "-DENABLE_LIBOMPTARGET=ON"
    ]
  end

  test do
    system "false"
  end
end
