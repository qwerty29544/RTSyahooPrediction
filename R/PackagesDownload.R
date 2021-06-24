packages_vec = cran_settings$packages

for (package_iter in packages_vec) {
  if ((package_iter %in% installed.packages()) == FALSE) {
    install.packages(package_iter, repos = cran_settings$CRAN_Mirror_URL)
  }
}

rm("packages_vec", "package_iter")
