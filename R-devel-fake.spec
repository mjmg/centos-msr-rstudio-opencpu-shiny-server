Name:     R-devel-fake
Version:  1
Release:  1%{?dist}
Summary:  Fakes the installation of the R and R-devel packages
Epoch:    99
License:  BSD

BuildArch: noarch

Provides: R
Provides: R-core
Provides: R-devel
Provides: libR.so()(%{__isa_bits}bit)


%description
Fakes the installation of the R and R-devel packages.
Useful if you have installed Microsoft R Open.

%prep

%build


%install


%files

%changelog