set(CTEST_PROJECT_NAME "cpp-boilerplate")
set(CTEST_NIGHTLY_START_TIME "01:00:00 UTC")

set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "my.cdash.org")
set(CTEST_DROP_LOCATION "/submit.php?project=cpp-boilerplate")
set(CTEST_DROP_SITE_CDASH TRUE)

# In case where you don't want to submit your reports to CDash,
# You can :
#   - use CTest in script mode and not call the Submit step
#   - Call the various steps directly from make/ninja (targets are {Mode}{Step})
#     where Mode is Nightly, Continuous, or Experimental
#     and Step is one of Start Update Configure Build Test Coverage MemCheck
#     Check the CTest documentation for more details
#   - Same but using the 'ctest' command line
#   - set(CTestSubmitRetryCount 0) and wait for timeout but this will return an error ?