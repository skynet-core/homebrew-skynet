class PoclAT61 < Formula
  desc "Portable Computing Language"
  homepage "https://portablecl.org"
  url "https://github.com/pocl/pocl/archive/refs/heads/release_6_1.tar.gz"
  sha256 "2679f288c72183ec23611c915f87ee0566d01a7bc7000b0e9896bebd1a54b0de"
  license "MIT"
  revision 1

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "opencl-headers" => :build
  depends_on "pkgconf" => :build
  depends_on "python" => :build
  depends_on "hwloc"
  depends_on :linux
  depends_on "llvm@19"
  depends_on "opencl-icd-loader"

  def install
    # Install the ICD into #{prefix}/etc rather than #{etc} as it contains the realpath
    # to the shared library and needs to be kept up-to-date to work with an ICD loader.
    # This relies on `brew link` automatically creating and updating #{etc} symlinks.
    ENV.append "CFLAGS",
               "-march=native"
    ENV.append "CXXFLAGS",
               "-march=native"
    rpaths = [loader_path, rpath(source: lib / "pocl")]
    rpaths << Formula["llvm@19"].opt_lib.to_s
    args = %W[
      -DCMAKE_BUILD_TYPE=Release
      -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON
      -DCMAKE_C_COMPILER=#{Formula["llvm@19"].opt_bin / "clang"}
      -DCMAKE_CXX_COMPILER=#{Formula["llvm@19"].opt_bin / "clang++"}
      -DPOCL_INSTALL_ICD_VENDORDIR=#{prefix}/etc/OpenCL/vendors
      -DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}
      -DENABLE_EXAMPLES=OFF
      -DENABLE_TESTS=OFF
      -DWITH_LLVM_CONFIG=#{Formula["llvm@19"].opt_bin}/llvm-config
      -DLLVM_PREFIX=#{Formula["llvm@19"].opt_prefix}
      -DLLVM_BINDIR=#{Formula["llvm@19"].opt_bin}
      -DLLVM_LIBDIR=#{Formula["llvm@19"].opt_lib}
      -DLLVM_INCLUDEDIR=#{Formula["llvm@19"].opt_include}
    ]
    # Only x86_64 supports "distro" which allows runtime detection of SSE/AVX
    args << "-DKERNELLIB_HOST_CPU_VARIANTS=distro" if Hardware::CPU.intel?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    (pkgshare / "examples").install "examples/poclcc"
  end

  test do
    ENV["OCL_ICD_VENDORS"] = "#{opt_prefix}/etc/OpenCL/vendors" # Ignore any other ICD that may be installed
    cp pkgshare / "examples/poclcc/poclcc.cl", testpath
    system bin / "poclcc", "-o", "poclcc.cl.pocl", "poclcc.cl"
    assert_path_exists testpath / "poclcc.cl.pocl"
    # Make sure that CMake found our OpenCL headers and didn't install a copy
    refute_path_exists include / "OpenCL"
  end
end
