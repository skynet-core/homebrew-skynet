class AdaptiveCppAT24 < Formula
  desc "Implementation of SYCL and C++ standard parallelism for CPUs and GPUs from all vendors: The independent, community-driven compiler for C++-based heterogeneous programming models. Lets applications adapt themselves to all the hardware in the system - even at runtime!"
  homepage "https://adaptivecpp.github.io/"
  url "https://github.com/AdaptiveCpp/AdaptiveCpp/archive/refs/tags/v24.06.0.tar.gz"
  sha256 "cfa117722fd50295de8b9e1d374a0de0aa2407a47439907972e8e3d9795aa285"
  license "BSD-2-Clause"

  livecheck do
    url :stable
    regex(/v24\.([\.\d]+)tar.gz$/i)
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "llvm@18"
  depends_on "boost@1.86"
  depends_on "openmp@18"

  def install
    ENV.append "CFLAGS", "-I#{Formula["openmp@18"].opt_include}"
    ENV.append "CXXFLAGS", "-I#{Formula["openmp@18"].opt_include}"
    ENV.append "LDFLAGS", "-L#{Formula["openmp@18"].opt_lib}"


    args = %W[
      -DCMAKE_C_COMPILER=#{Formula["llvm@18"].opt_bin/"clang"}
      -DCMAKE_CXX_COMPILER=#{Formula["llvm@18"].opt_bin/"clang++"}
      -DCMAKE_LINKER=#{Formula["llvm@18"].opt_bin/"lld"}
      -DLLVM_DIR=#{Formula["llvm@18"].opt_lib/"llvm/cmake/llvm"}
      -DBOOST_ROOT=#{Formula["boost@1.86"]}
    ]

      system "cmake", "-G", "Ninja", "-S", ".", "-B","build", *(std_cmake_args + args)
      system "cmake", "--build", "build"
      system "cmake", "--build", "build", "--target", "install"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test adaptive-cpp`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system bin/"program", "do", "something"`.
    system "false"
  end
end
